LinkLuaModifier("modifier_split_oozeling_charges","heroes/viscous_ooze/viscous_ooze_split_oozelings.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_toxic_ooze","heroes/viscous_ooze/viscous_ooze_split_oozelings.lua",LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier("modifier_toxic_ooze_effect","heroes/viscous_ooze/viscous_ooze_split_oozelings.lua",LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier("modifier_split_oozeling_strength_modifier","heroes/viscous_ooze/viscous_ooze_split_oozelings.lua",LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_oozeling","heroes/viscous_ooze/viscous_ooze_split_oozelings.lua",LUA_MODIFIER_MOTION_NONE)

viscous_ooze_split_oozelings = class({})

function viscous_ooze_split_oozelings:OnCreated()
end

function viscous_ooze_split_oozelings:GetManaCost(hTarget)
    return self.BaseClass.GetManaCost( self, hTarget ) * self:GetCaster():GetModifierStackCount("modifier_split_oozeling_charges", self:GetCaster())
end

function viscous_ooze_split_oozelings:UpdateManaCost()
    -- Refreshes mana display
    self:SetLevel(self:GetLevel())
end

function viscous_ooze_split_oozelings:GetIntrinsicModifierName()
    return "modifier_split_oozeling_charges"
end

-- function viscous_ooze_split_oozelings:CastFilterResult()
--     if not IsServer() then return end
--     local modifier = self:GetCaster():FindModifierByName("modifier_split_oozeling_charges")
--     local charges = modifier:GetStackCount()
--     if charges < 1 then return UF_FAIL_CUSTOM end

--     return UF_SUCCESS
-- end

-- function viscous_ooze_split_oozelings:GetCustomCastError()
--     return "Requires Charges"
-- end

local START_RADIUS = 50
local KNOCKBACK_DISTANCE = 400
local KNOCKBACK_HEIGHT = 350
local KNOCKBACK_DURATION = 0.6

function viscous_ooze_split_oozelings:OnSpellStart()
    if IsServer() then
        
        --local newHealth = (caster:GetHealth() - healthChange) * caster:GetHealthPercent() / 100
        --caster:Heal((caster:GetHealth() - newHealth), self) 
        
    end
end

function viscous_ooze_split_oozelings:GetSummonPoints(caster, charges)
    if charges < 1 then return end

    local origin = caster:GetAbsOrigin()
    local forward = caster:GetForwardVector()


    local result = { }
    local oozeAngle = 360 / charges

    local angle = 0

    for i = 1, charges do
        local angleQ = QAngle(0, angle, 0)
        local vector = origin + forward * START_RADIUS
        local point = RotatePosition(origin, angleQ, vector)
        table.insert(result, point)
        angle = angle + oozeAngle
    end
    
    return result
end


modifier_split_oozeling_charges = class({})

function modifier_split_oozeling_charges:OnCreated()
    self.damageCounter = 0
    self.currentCharges = 0

    if IsServer() then
        self:StartIntervalThink(0.75)
    end
end

function modifier_split_oozeling_charges:OnIntervalThink()

    if not IsServer() then return end

    local caster = self:GetCaster()
    local ability = self:GetAbility()

    if not caster:IsAlive() then return end

    local modifier = caster:FindModifierByName("modifier_split_oozeling_charges")
    
    local charges = modifier:GetStackCount()
    if charges == 0 then return end

    modifier.currentCharges = 0
    modifier:SetStackCount(0)
    
    ability:StartCooldown(0.75)
    --print(charges)
    local origin = caster:GetAbsOrigin()
    local points = ability:GetSummonPoints(caster,charges)
    local duration = ability:GetSpecialValueFor("oozeling_duration")


    local maxCharges = ability:GetSpecialValueFor("max_charges")
    local movespeed = ability:GetSpecialValueFor("oozeling_speed")
    local strengthLoss = ability:GetSpecialValueFor("ooze_health")

    local speedTalent = caster:FindAbilityByName("special_bonus_unique_viscous_ooze_1")
    if speedTalent and speedTalent:GetLevel() > 0 then
        movespeed = movespeed + speedTalent:GetSpecialValueFor("value")
    end

    table.foreach(points, function(k, v) 
        --DebugDrawSphere(v,Vector(255, 255,255),1, 100, true,10)

        CreateUnitByNameAsync("oozeling_1", v, false, caster, caster:GetPlayerOwner(), caster:GetTeam(), 
        function(oozeling)
            local health = caster:GetHealth()
            oozeling:SetOwner(caster)
            oozeling:SetControllableByPlayer(caster:GetPlayerOwnerID(),false)
            oozeling:AddNewModifier(caster,ability,"modifier_kill",{Duration = duration})
            oozeling:SetBaseMoveSpeed(movespeed)

            local knockbackModifierTable =  {
                should_stun = 0,
                knockback_duration = KNOCKBACK_DURATION,
                duration = KNOCKBACK_DURATION,
                knockback_distance = RandomFloat(KNOCKBACK_DISTANCE * 0.25, KNOCKBACK_DISTANCE * 1.25),
                knockback_height = RandomFloat(KNOCKBACK_HEIGHT * 0.5, KNOCKBACK_HEIGHT * 1.25),
                center_x = origin.x,
                center_y = origin.y,
                center_z = origin.z
            }
            oozeling:EmitSound("Hero_Viscous_Ooze.Split_oozelings")
            oozeling:AddNewModifier( caster, nil, "modifier_knockback", knockbackModifierTable )
            oozeling:AddNewModifier(caster,ability,"modifier_toxic_ooze",{})
            oozeling:AddNewModifier(caster,ability,"modifier_invulnerable",{Duration = knockbackModifierTable.duration})
        end)
        --healthChange = healthChange + 100
     end)        
end

function modifier_split_oozeling_charges:IsHidden()
    return false
end

function modifier_split_oozeling_charges:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end


function modifier_split_oozeling_charges:OnTakeDamage(keys)
    if IsServer() then
        if keys.unit ~= self:GetParent() then return end
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local damage = keys.damage

        if caster:PassivesDisabled() then return end
        local maxhp = self:GetCaster():GetMaxHealth()
        local threshold = ability:GetSpecialValueFor("threshold") + self:GetCaster():GetTalentValue("special_bonus_unique_viscous_ooze_3")
        local max_charges = 6
        --if caster:HasScepter() then max_charges = max_charges + 4 end
        
        self.damageCounter = self.damageCounter + damage
        while (self.damageCounter > threshold) do
            if self.currentCharges < max_charges then
                self.currentCharges = self.currentCharges + 1
                --local digits = string.len(self.currentCharges) + 1

                self:IsHidden(false)
                self:SetStackCount(self.currentCharges)
            end
            self.damageCounter = self.damageCounter - (threshold * maxhp / 100)
        end
        
    end
end

-- modifier_split_oozeling_strength_modifier = class({})

-- function modifier_split_oozeling_strength_modifier:IsHidden()
--     return true
-- end

-- function modifier_split_oozeling_strength_modifier:OnCreated(keys)
--     if IsServer() then 
--         self.interval = self:GetDuration() / keys.stacks
--         self:SetStackCount(keys.stacks)
--         self:StartIntervalThink(self.interval)
--     end
-- end
-- function modifier_split_oozeling_strength_modifier:OnIntervalThink()
--     if IsServer() then 
--         if self:GetStackCount() > 0 then
--             self:DecrementStackCount()
--             self:GetParent():CalculateStatBonus(true)
--         end
--     end
-- end


-- function modifier_split_oozeling_strength_modifier:GetAttributes()
--     return MODIFIER_ATTRIBUTE_MULTIPLE
-- end

-- function modifier_split_oozeling_strength_modifier:DeclareFunctions()
--     local funcs = {
--         MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
--     }
--     return funcs
-- end

-- function modifier_split_oozeling_strength_modifier:GetModifierBonusStats_Strength()
--     return -self:GetStackCount()
-- end


modifier_toxic_ooze = class({})

function modifier_toxic_ooze:OnCreated()
    if not IsServer() then return end

    self:StartIntervalThink(0.2)
end

function modifier_toxic_ooze:IsHidden()
    return false
end

function modifier_toxic_ooze:OnIntervalThink()
    if not IsServer() then return end

    local ooze = self:GetParent()
    if not ooze:HasModifier("modifier_knockback") then
        local ability = self:GetAbility()
        local contact_radius = ability:GetLevelSpecialValueFor("contact_radius", (ability:GetLevel() - 1))
        local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
        local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
        local target_flags = DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

        -- Find the valid units in the trigger radius
        local units = FindUnitsInRadius(ooze:GetTeamNumber(), ooze:GetAbsOrigin(), nil, contact_radius, target_team, target_types, target_flags, FIND_CLOSEST, false)

        if #units > 0 then
            ooze:StartGesture(ACT_DOTA_CAST_ABILITY_1)
            Timers:CreateTimer(0.3, function()
                ooze:ForceKill(true)
            end)
        end
    end
end

function modifier_toxic_ooze:OnDestroy()
    if not IsServer() then return end

    local ooze = self:GetParent()
    if not ooze:IsAlive() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local particleName = "particles/units/heroes/hero_viscous_ooze/viscous_ooze_toxic_ooze.vpcf"
        local soundEventName = "Ability.SandKing_CausticFinale"
        
        local fxIndex = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, self:GetParent() )
        StartSoundEvent( soundEventName, self:GetParent() )

        local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
        local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
        local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
        local radius = ability:GetSpecialValueFor("toxic_radius")

        local units = FindUnitsInRadius(ooze:GetTeamNumber(), ooze:GetAbsOrigin(), nil, radius, target_team, target_types, target_flags, FIND_CLOSEST, false)


        local slimeTrail = caster:FindAbilityByName("viscous_ooze_toxic_slime")
        local slimeDuration = 0
        local txdmg = ability:GetLevelSpecialValueFor("toxic_damage", ability:GetLevel() - 1) + caster:GetTalentValue("special_bonus_unquie_oozeling_dmg")
        if slimeTrail and slimeTrail:GetLevel() > 0 then
            slimeTrail:CreateSlimes(ooze:GetAbsOrigin(), radius, 2)
            slimeDuration = slimeTrail:GetSpecialValueFor("slime_duration")
                
            -- Check for talent
            local talent = caster:FindAbilityByName("special_bonus_unique_viscous_ooze_4")
            if talent and talent:GetLevel() > 0 then
                slimeDuration = slimeDuration + talent:GetSpecialValueFor("value")
            end
        end


        for k, unit in pairs(units) do 
            if slimeTrail then 
                unit:AddNewModifier(caster, slimeTrail, "modifier_toxic_slime_effect", {Duration = slimeDuration})
            end

            ApplyDamage({
                victim = unit,
                attacker = self:GetCaster(),
                damage = txdmg,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self:GetAbility()
            })
        end
        if caster:HasScepter() then
            local slimeTrail = caster:FindAbilityByName("viscous_ooze_slime_trail")
            if slimeTrail and slimeTrail:GetLevel() > 0 then
                slimeTrail:CreateSlimes(ooze:GetAbsOrigin(), radius, 3)
            end
            
        end
    end
end

-- modifier_toxic_ooze_effect = class({})

-- function modifier_toxic_ooze_effect:OnCreated(keys)
--     if not IsServer() then return end

--     self.damage = keys.Damage
--     self.slow = keys.Slow

--     self:StartIntervalThink(1)
-- end

-- function modifier_toxic_ooze_effect:IsHidden()
--     return false
-- end

-- function modifier_toxic_ooze_effect:GetAttributes()
--     return MODIFIER_ATTRIBUTE_MULTIPLE
-- end

-- function modifier_toxic_ooze_effect:GetEffectName()
--     return "particles/units/heroes/hero_batrider/batrider_stickynapalm_debuff.vpcf"
-- end

-- function modifier_toxic_ooze_effect:GetEffectAttachType()
--     return PATTACH_ABSORIGIN_FOLLOW
-- end


-- function modifier_toxic_ooze_effect:GetStatusEffectName()
--     return "particles/status_fx/status_effect_stickynapalm.vpcf"
-- end

-- function modifier_toxic_ooze_effect:StatusEffectPriority()
--     return 10
-- end

-- function modifier_toxic_ooze_effect:DeclareFunctions()
--     local funcs = {
--         MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
--     }
--     return funcs
-- end

-- function modifier_toxic_ooze_effect:GetModifierMoveSpeedBonus_Percentage()
--     return self.slow or 0
-- end

-- function modifier_toxic_ooze_effect:OnIntervalThink()
--     if not IsServer() then return end

--     ApplyDamage({
--         victim = self:GetParent(),
--         attacker = self:GetCaster(),
--         damage = self.damage or 0,
--         damage_type = DAMAGE_TYPE_MAGICAL,
--         ability = self:GetAbility()
--         })
-- end