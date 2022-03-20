modifier_parasight_parasitic_invasion = class({})

-- Orders to be directly forwarded
local forward_orders = {}
local cast_orders = {}
if IsServer() then
    forward_orders = {
        [DOTA_UNIT_ORDER_MOVE_TO_POSITION] = true,
        [DOTA_UNIT_ORDER_MOVE_TO_TARGET] = true,
        [DOTA_UNIT_ORDER_ATTACK_MOVE] = true,
        [DOTA_UNIT_ORDER_ATTACK_TARGET] = true,
        [DOTA_UNIT_ORDER_HOLD_POSITION] = true,
        [DOTA_UNIT_ORDER_PICKUP_ITEM] = true,
        [DOTA_UNIT_ORDER_PICKUP_RUNE] = true,
    }

    -- Orders for ability casts
    cast_orders = {
        [DOTA_UNIT_ORDER_CAST_POSITION] = true,
        [DOTA_UNIT_ORDER_CAST_TARGET] = true,
        [DOTA_UNIT_ORDER_CAST_TARGET_TREE] = true,
        [DOTA_UNIT_ORDER_CAST_NO_TARGET] = true,
        [DOTA_UNIT_ORDER_CAST_TOGGLE] = true,
        [DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO] = true,
    }
end

function modifier_parasight_parasitic_invasion:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
    }
end

function modifier_parasight_parasitic_invasion:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_MUTED] = true
    }
end

function modifier_parasight_parasitic_invasion:RemoveOnDeath()
    return true
end

function modifier_parasight_parasitic_invasion:OnCreated(params)
    if IsServer() then

        self.target = params.target
        self.max_growth_duration = params.max_growth_duration
        self.max_control_duration = params.max_control_duration
        self:StartIntervalThink(0.1)

        -- Set damage limit
        -- self.damageLimit = self:GetAbility():GetSpecialValueFor("damage_threshold")
    end
end

function modifier_parasight_parasitic_invasion:OnIntervalThink()
    if IsServer() then
        -- if self.target and IsValidEntity(self.target) and self.target:HasModifier("modifier_parasight_parasitic_invasion_target") then
        --     FindClearSpaceForUnit(self:GetCaster(),self.target:GetAbsOrigin(),false)
        -- end
        if self:GetElapsedTime() >= self.max_growth_duration then
            -- Set max stack count
            self:SetStackCount(100)
        else
            local percentage = math.floor(100 * self:GetElapsedTime() / self.max_growth_duration)
            self:SetStackCount(percentage)
        end

        

        if self.target and self.target:IsAlive() then
            self:GetParent():SetAbsOrigin(self.target:GetAbsOrigin() - self.target:GetForwardVector())
        else
            self:GetParent():RemoveModifierByName("modifier_parasight_parasitic_invasion_control_buff")
            self:Destroy()
        end
    end
end

function modifier_parasight_parasitic_invasion:SetTarget(target)
    self.target = target

    local parent = self:GetParent()
    parent:AddNoDraw()

    self.particle = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_parasight/parasight_parasitic_invasion_invaded.vpcf", 
        PATTACH_CENTER_FOLLOW, target, parent:GetTeamNumber())

    -- Apply target modifier
    local target_modifier = target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_parasight_parasitic_invasion_target", {})
    target_modifier.invasion_modifier = self

    parent:SetAbsOrigin(target:GetAbsOrigin() + target:GetForwardVector() * -3)
    parent:SetForwardVector(target:GetForwardVector())

    
end

function modifier_parasight_parasitic_invasion:TakeControl()
    local parent = self:GetParent()
    local target = self.target

    local duration = self:GetStackCount() * self.max_control_duration / 100

    parent:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_parasight_parasitic_invasion_control_buff", {duration = duration})
    local control_modifier = self.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_parasight_parasitic_invasion_control", {duration = duration})
    control_modifier.invasion_modifier = self
    

    self.has_control = true
    -- Remove abilities
    self.original_abilities = {}
    self.added_abilities = {}
    self.ability_points = parent:GetAbilityPoints()
    self.parent_level = parent:GetLevel()

    self.original_team = target:GetTeamNumber()
    self.new_team = parent:GetTeamNumber()


    -- Play loop
    parent:EmitSound("Hero_Parasight.Parasitic_Invasion.Loop")
    -- Set enemy team to yours
    target:SetTeam(self.new_team)

    for i=0,parent:GetAbilityCount() -1 do
        local ability = parent:GetAbilityByIndex(i)
        -- Ignore talents
        if ability == nil or string.find(ability:GetAbilityName(), "special_") then
            break
        end

        -- Store ability data
        table.insert(self.original_abilities, {
            name = ability:GetAbilityName(),
            level = ability:GetLevel(),
            cooldown = ability:GetCooldownTimeRemaining()
        })
    end

    -- Remove abilities
    for _, ability in pairs(self.original_abilities) do
        parent:RemoveAbility(ability.name)
    end

    -- Add back the abilities of the target unit
    for i=0,target:GetAbilityCount() -1 do
        local ability = target:GetAbilityByIndex(i)
        -- Ignore talents
        if ability == nil or string.find(ability:GetAbilityName(), "special_") then
            break
        end

        -- Add ability to parent and set level and cooldown
        local parent_ability = parent:AddAbility(ability:GetAbilityName())
        parent_ability:SetLevel(ability:GetLevel())
        if not ability:IsCooldownReady() then
            parent_ability:StartCooldown(ability:GetCooldownTimeRemaining())
        end

        table.insert(self.added_abilities, ability:GetAbilityName())
    end
end

function modifier_parasight_parasitic_invasion:OnDestroy()
    if IsServer() then
        local parent = self:GetParent()
        FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), false)
        self.target:RemoveModifierByNameAndCaster("modifier_parasight_parasitic_invasion_target", self:GetCaster())
        ParticleManager:DestroyParticle(self.particle, false)
        parent:RemoveNoDraw()
        parent:StopSound("Hero_Parasight.Parasitic_Invasion.Loop")
        parent:EmitSound("Hero_Parasight.Parasitic_Invasion.End")

        if self.has_control then
            -- Return to original team
            self.target:SetTeam(self.original_team)


            -- Remove target modifier

            -- Remove added abilities
            for _, abilityName in pairs(self.added_abilities) do
                parent:RemoveAbility(abilityName)
            end

            -- Add back original abilities
            for _, abilityData in pairs(self.original_abilities) do
                local ability = parent:AddAbility(abilityData.name)
                ability:SetLevel(abilityData.level)
                if abilityData.cooldown - self:GetElapsedTime() > 0 then
                    ability:StartCooldown(abilityData.cooldown - self:GetElapsedTime())
                end
            end

            -- Restore ability points
            parent:SetAbilityPoints(self.ability_points + (parent:GetLevel() - self.parent_level))
        end
    end
end

-- Apply 1.5x dmg to parent
function modifier_parasight_parasitic_invasion:OnTakeDamage(event)
    if event.unit == self.target then
        local damage = 1.5 * event.damage
        ApplyDamage({
            victim = self:GetParent(),
            attacker = event.attacker,
            damage = damage,
            damage_type = DAMAGE_TYPE_PURE,
            damage_flags = DOTA_DAMAGE_FLAG_HPLOSS,
            ability = event.ability
        })

        -- -- Subtract from damage threshold
        -- self.damageLimit = self.damageLimit - damage

        -- -- If dmg limit below 0 end ult
        -- if self.damageLimit <= 0 then
        --     self:Destroy()
        -- end
    end
end

-- Propagate cooldowns from target to parent
function modifier_parasight_parasitic_invasion:OnAbilityExecuted(event)
    if event.unit == self.target then
        -- Get ability cooldown
        local cooldown = event.ability:GetCooldown(event.ability:GetLevel())
        local abilityName = event.ability:GetAbilityName()

        local parent_ability = self:GetParent():FindAbilityByName(abilityName)
        if parent_ability then
            parent_ability:UseResources(false,false,true)
        end
    end
end

function modifier_parasight_parasitic_invasion:GetTexture() 
    return "parasight_parasitic_invasion" 
end

function modifier_parasight_parasitic_invasion:OrderFilter(order)
    if forward_orders[order.order_type] then
        -- Simply forward the order in its entirety
        ExecuteOrderFromTable({
            UnitIndex = self.target:GetEntityIndex(),
            OrderType = order.order_type,
            TargetIndex = order.entindex_target,
            AbilityIndex = order.entindex_ability,
            Position = Vector(order.position_x, order.position_y, order.position_x),
            Queue = order.queue
        })

        -- Cancel the original order
        return false
    end

    if cast_orders[order.order_type] then
        -- Unit that is invaded
        local invadee = self.target

        -- Get ability
        local abilityname = EntIndexToHScript(order.entindex_ability):GetAbilityName()

        -- Get actual ability
        local ability = invadee:FindAbilityByName(abilityname)

        -- Get target
        local target = order.entindex_target

        -- if order.order_type == DOTA_UNIT_ORDER_CAST_TARGET then
        --     local valid_targets = FindUnitsInRadius(invadee:GetTeamNumber(), invadee:GetAbsOrigin(), nil, 1000,
        --         ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)

        --     -- If no target found just throw away the order
        --     if #valid_targets == 0 then
        --         return false
        --     else
        --         -- Otherwise set a random valid target as target
        --         target = valid_targets[RandomInt(1,#valid_targets)]:GetEntityIndex()
        --     end
        -- end

        -- Create new order
        ExecuteOrderFromTable({
            UnitIndex = invadee:GetEntityIndex(),
            OrderType = order.order_type,
            TargetIndex = target,
            AbilityIndex = ability:GetEntityIndex(),
            Position = Vector(order.position_x, order.position_y, order.position_x),
            Queue = order.queue
        })

        -- Cancel original order
        return false
    end

    --Just let all other orders go through
    return true
end

modifier_parasight_parasitic_invasion_control_buff = class({})

function modifier_parasight_parasitic_invasion_control_buff:IsBuff() 
    return true 
end

function modifier_parasight_parasitic_invasion_control_buff:GetTexture() 
    return "parasight_parasitic_invasion" 
end