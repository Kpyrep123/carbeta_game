LinkLuaModifier("modifier_slime_trail","heroes/viscous_ooze/viscous_ooze_slime_trail.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slime_puddle","heroes/viscous_ooze/viscous_ooze_slime_trail.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slime_puddle_effect","heroes/viscous_ooze/viscous_ooze_slime_trail.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slime_puddle_bonus","heroes/viscous_ooze/viscous_ooze_slime_trail.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slime_puddle_bonus_effect","heroes/viscous_ooze/viscous_ooze_slime_trail.lua",LUA_MODIFIER_MOTION_NONE)


viscous_ooze_slime_trail = class({})

function viscous_ooze_slime_trail:ProcsMagicStick()
    return false
end

function viscous_ooze_slime_trail:OnToggle()
    if IsServer() then
        local caster = self:GetCaster()
        if self:GetToggleState() then
            self:CreateSlimes(caster:GetAbsOrigin(), self:GetSpecialValueFor("start_radius"), 5)
            caster:AddNewModifier(caster,self,"modifier_slime_trail",{})
        else
            caster:RemoveModifierByName("modifier_slime_trail")
        end
    end
end

function viscous_ooze_slime_trail:CreateSlimes(position, radius, count)
    for i = 0, count do
        self:CreateSlime(position, radius)
    end
end

function viscous_ooze_slime_trail:CreateSlime(position, radius)
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")

    -- Check for talent
    local talent = caster:FindAbilityByName("special_bonus_unique_viscous_ooze_2")
    if talent and talent:GetLevel() > 0 then
        duration = duration + talent:GetSpecialValueFor("value")
    end

    local thinker = CreateModifierThinker(self:GetCaster(), self, "modifier_slime_puddle", {
        Duration = duration, 
        aura_radius = radius,
        positionX = position.x, 
        positionY = position.y, 
        positionZ = position.z
        }, position, self:GetCaster():GetTeamNumber(), false)

    local thinker2 = CreateModifierThinker(self:GetCaster(), self, "modifier_slime_puddle_bonus", {
        Duration = duration,
        aura_radius = radius,
        positionX = position.x, 
        positionY = position.y, 
        positionZ = position.z
        }, position, self:GetCaster():GetTeamNumber(), false)

    thinker:EmitSound("Hero_Viscous_Ooze.Slime_trail")
    if caster:HasModifier("modifier_item_aghanims_shard") then
    self:CreateVisibilityNode(position, 200, self:GetSpecialValueFor("duration"))
    end
    -- local puddles = self.slimePuddles or { }
    -- table.insert(puddles, {
    --     position = position, 
    --     modifier = thinker:entindex()
    -- })
    -- self.slimePuddles = puddles
end

modifier_slime_trail = class({})

function modifier_slime_trail:IsHidden()
    return false
end

-- function modifier_slime_trail:DeclareFunctions()
--     local funcs = {
--         MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
--     }
--     return funcs
-- end

-- function modifier_slime_trail:GetModifierMoveSpeedBonus_Percentage()
--     return self:GetAbility():GetSpecialValueFor("movespeed_bonus")
-- end

function modifier_slime_trail:OnCreated(keys)
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    self.lastPosition = caster:GetAbsOrigin()
    self.Distance = 64
    self.interval = 0.1
    if IsServer() then
        self:StartIntervalThink(self.interval)
    end
end

function modifier_slime_trail:OnIntervalThink()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local distance = (self.lastPosition - caster:GetAbsOrigin()):Length()
    if distance > 500 then 
        self.lastPosition = caster:GetAbsOrigin()
        ability:CreateSlime(caster:GetAbsOrigin(), ability:GetSpecialValueFor("start_radius"))
        
    elseif distance > self.Distance then 
        self.lastPosition = caster:GetAbsOrigin()
        ability:CreateSlime(caster:GetAbsOrigin(), ability:GetSpecialValueFor("start_radius") + distance)
    end

    local selfDamage = self.interval * ability:GetSpecialValueFor("self_damage") * caster:GetMaxHealth() / 100
    if selfDamage > caster:GetHealth() then self:GetAbility():ToggleAbility() end

    ApplyDamage({
        victim = caster,
        attacker = caster,
        ability = ability,
        damage = selfDamage,
        damage_type = DAMAGE_TYPE_PURE,
        damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS
        })

    --caster:EmitSound("Hero_Viscous_Ooze.Slime_trail")

    -- table.foreach(self.slimePuddles, function(k, v)
    --     print(k, v)
    --     print(v.position)
    --     print(v.modifier)
    --     end)

end

modifier_slime_puddle = class({})

function modifier_slime_puddle:OnCreated(keys)

    --print(keys.aura_radius)
    self.currentRadius = 0
    self.maxRadius = 50

    self.interval = 0.25
    self.maxTime = 1
    self.time = 0 

    if IsServer() then
        self.currentRadius = keys.aura_radius
        self.maxRadius = self:GetAbility():GetSpecialValueFor("max_radius")
        self.position = Vector(keys.positionX, keys.positionY, keys.positionZ)
        self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_viscous_ooze/viscous_ooze_slime_trail.vpcf", PATTACH_WORLDORIGIN ,nil)
        self:AddParticle(self.particle, false, false, -1, false, false )
        self:LoadParticle(self.position)
        self:StartIntervalThink(self.interval)
    end
end

function modifier_slime_puddle:OnDestroy()
    -- ParticleManager:ReleaseParticleIndex(self.particle)
end

function modifier_slime_puddle:IsAura() return true end
----------------------------------------------------------------------------------------------------------
function modifier_slime_puddle:GetModifierAura()  return "modifier_slime_puddle_effect" end
----------------------------------------------------------------------------------------------------------
function modifier_slime_puddle:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
----------------------------------------------------------------------------------------------------------
function modifier_slime_puddle:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
----------------------------------------------------------------------------------------------------------
function modifier_slime_puddle:GetAuraRadius() return self.currentRadius or 1 end
----------------------------------------------------------------------------------------------------------
function modifier_slime_puddle:OnIntervalThink()
    if IsServer() then
        local caster = self:GetCaster()
        if self:GetAbility():GetToggleState() then 
            local distance = (self.position - caster:GetAbsOrigin()):Length() - 64
            
            if distance < self.currentRadius then
                local ability = self:GetAbility()
                local damageTaken = self.interval * caster:GetMaxHealth() * ability:GetSpecialValueFor("self_damage") / 100
                --local addRadius = damageTaken * (self.currentRadius - distance) / self.currentRadius * (self.maxRadius / (self.currentRadius * 2))
                local addRadius = damageTaken
                local newRadius = self.currentRadius + addRadius
                if newRadius < self.maxRadius then
                    self.currentRadius = newRadius
                    self.radiusGrowth = addRadius * self.interval
                    self:LoadParticle(self.position)
                    self.time = 0
                    --self:GetAbility():CreateSlime(self.position, newRadius)
                    --self:Destroy()
                else
                    self.currentRadius = self.maxRadius
                    self:LoadParticle(self.position)
                    self:StartIntervalThink(-1)
                end
            end
        end

        self.time = self.time + self.interval

        if self.time > self.maxTime then
            self:LoadParticle(self.position)
            self:StartIntervalThink(-1)
        end
    end
end

function modifier_slime_puddle:LoadParticle(position)
    -- if self.particle then 
    --     ParticleManager:DestroyParticle(self.particle, false) 
    --     ParticleManager:ReleaseParticleIndex(self.particle)
    -- end

    -- local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_viscous_ooze/viscous_ooze_slime_trail.vpcf", PATTACH_WORLDORIGIN ,nil)
    local particle = self.particle
    ParticleManager:SetParticleControl(particle, 0, GetGroundPosition(position, nil))
    ParticleManager:SetParticleControl(particle, 1, Vector(self.currentRadius, 1, 1))
    ParticleManager:SetParticleControl(particle, 2, Vector(self.currentRadius / 2, self.currentRadius / 2, 1))
    ParticleManager:SetParticleControl(particle, 3, Vector(self.currentRadius * self.currentRadius / 30000, 1, 1))
    ParticleManager:SetParticleControl(particle, 4, Vector(self.radiusGrowth, 1, 1))
    --Rainbow puddles
    --ParticleManager:SetParticleControl(particle, 15, Vector(RandomFloat(0,255), RandomFloat(0,255), RandomFloat(0,255)))
    ParticleManager:SetParticleControl(particle, 15, Vector(RandomFloat(15,45), RandomFloat(55,135), 0))
    ParticleManager:SetParticleControl(particle, 16, Vector(1, 0, 0))
    ParticleManager:SetParticleAlwaysSimulate(particle)

    self.particle = particle
    

    -- local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_viscous_ooze/viscous_ooze_slime_puddle.vpcf", PATTACH_WORLDORIGIN ,nil)
    -- ParticleManager:SetParticleControl(particle2, 0, position)

    -- ParticleManager:SetParticleControl(particle2, 1, Vector(self.currentRadius, 1, 1))
    -- --Rainbow puddles
    -- --ParticleManager:SetParticleControl(particle2, 15, Vector(RandomFloat(0,255), RandomFloat(0,255), RandomFloat(0,255)))
    -- ParticleManager:SetParticleControl(particle2, 15, Vector(RandomFloat(15,65), RandomFloat(55,120), 0))
    -- ParticleManager:SetParticleControl(particle2, 16, Vector(1, 0, 0))

    -- self:AddParticle( particle2, false, false, -1, false, false )
    
end

modifier_slime_puddle_bonus = class({})

function modifier_slime_puddle_bonus:OnCreated(keys)

    --print(keys.aura_radius)
    self.currentRadius = 0
    self.maxRadius = 50

    self.interval = 0.25
    self.maxTime = 1
    self.time = 0 

    if IsServer() then
        self.currentRadius = keys.aura_radius
        self.maxRadius = self:GetAbility():GetSpecialValueFor("max_radius")
        self.position = Vector(keys.positionX, keys.positionY, keys.positionZ)
        self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_viscous_ooze/viscous_ooze_slime_trail.vpcf", PATTACH_WORLDORIGIN ,nil)
        self:AddParticle(self.particle, false, false, -1, false, false )
        self:StartIntervalThink(self.interval)
    end
end

function modifier_slime_puddle_bonus:OnDestroy()
    -- ParticleManager:ReleaseParticleIndex(self.particle)
end

function modifier_slime_puddle_bonus:IsAura() return true end
----------------------------------------------------------------------------------------------------------
function modifier_slime_puddle_bonus:GetModifierAura()  return "modifier_slime_puddle_bonus_effect" end
----------------------------------------------------------------------------------------------------------
function modifier_slime_puddle_bonus:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
----------------------------------------------------------------------------------------------------------
function modifier_slime_puddle_bonus:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
----------------------------------------------------------------------------------------------------------
function modifier_slime_puddle_bonus:GetAuraRadius() return self.currentRadius or 1 end
----------------------------------------------------------------------------------------------------------
function modifier_slime_puddle_bonus:GetAuraEntityReject(target)
    return self:GetCaster():GetPlayerOwner() ~= target:GetPlayerOwner()
end
----------------------------------------------------------------------------------------------------------
function modifier_slime_puddle_bonus:OnIntervalThink()
    if IsServer() then
        local caster = self:GetCaster()
        if self:GetAbility():GetToggleState() then 
            local distance = (self.position - caster:GetAbsOrigin()):Length() - 64
            
            if distance < self.currentRadius then
                local ability = self:GetAbility()
                local damageTaken = self.interval * caster:GetMaxHealth() * ability:GetSpecialValueFor("self_damage") / 100
                --local addRadius = damageTaken * (self.currentRadius - distance) / self.currentRadius * (self.maxRadius / (self.currentRadius * 2))
                local addRadius = damageTaken
                local newRadius = self.currentRadius + addRadius
                if newRadius < self.maxRadius then
                    self.currentRadius = newRadius
                    self.radiusGrowth = addRadius * self.interval
                    self.time = 0
                    --self:GetAbility():CreateSlime(self.position, newRadius)
                    --self:Destroy()
                else
                    self.currentRadius = self.maxRadius
                    self:StartIntervalThink(-1)
                end
            end
        end

        self.time = self.time + self.interval

        if self.time > self.maxTime then
            self:StartIntervalThink(-1)
        end
    end
end
---------------------------------------------------------------------------------------------------------- 
modifier_slime_puddle_effect = class({})

function modifier_slime_puddle_effect:IsHidden() 
    return self.hidden or false
end

function modifier_slime_puddle_effect:IsBuff()
    return false
end

function modifier_slime_puddle_effect:OnCreated()
    self.interval = 0.5
    if IsServer() then
        self:StartIntervalThink(self.interval)
        --self:EmitSound("Hero_Viscous_Ooze.Slime_trail")
    end
end


function modifier_slime_puddle_effect:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_slime_puddle_effect:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow")
end

----------------------------------------------------------------------------------------------------------
function modifier_slime_puddle_effect:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
    local totalDamage = self.interval * self:GetAbility():GetSpecialValueFor("damage") + (self.interval * self:GetStackCount() * self:GetAbility():GetSpecialValueFor("dps_increase"))
    local totalDamageShard = self.interval * ((self:GetAbility():GetSpecialValueFor("damage") + (self:GetCaster():GetStrength() * self:GetAbility():GetSpecialValueFor("str_to_damage") / 100)) + (self.interval * self:GetStackCount() * self:GetAbility():GetSpecialValueFor("dps_increase")))
    if caster:HasModifier("modifier_item_aghanims_shard") then
    ApplyDamage({ 
        victim = self:GetParent(), 
        attacker = self:GetCaster(), 
        damage = totalDamageShard,
        damage_type = DAMAGE_TYPE_MAGICAL 
        })
        else
    ApplyDamage({ 
        victim = self:GetParent(), 
        attacker = self:GetCaster(), 
        damage = totalDamage,
        damage_type = DAMAGE_TYPE_MAGICAL 
        })
end
    self:IncrementStackCount()
end


modifier_slime_puddle_bonus_effect = class({})

function modifier_slime_puddle_bonus_effect:IsHidden()
    return false
end

function modifier_slime_puddle_bonus_effect:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function modifier_slime_puddle_bonus_effect:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed_bonus")
end

function modifier_slime_puddle_bonus_effect:CheckState()
    local states = {
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
    return states
end

