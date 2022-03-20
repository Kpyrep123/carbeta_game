LinkLuaModifier("modifier_sticky_membrane_passive","heroes/viscous_ooze/viscous_ooze_sticky_membrane.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sticky_membrane_disarm","heroes/viscous_ooze/viscous_ooze_sticky_membrane.lua",LUA_MODIFIER_MOTION_NONE)


viscous_ooze_sticky_membrane = class({})

function viscous_ooze_sticky_membrane:GetIntrinsicModifierName()
	return "modifier_sticky_membrane_passive"
end

function viscous_ooze_sticky_membrane:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local ability = self

    local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
    local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    local radius = ability:GetSpecialValueFor("trigger_radius")

    local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, target_team, target_types, target_flags, FIND_CLOSEST, false)
    caster:EmitSound("Hero_Bane.Enfeeble.Cast")
    for _, unit in pairs(units) do

        local disarmDuration = ability:GetSpecialValueFor("active_disarm_duration")
        local modifier = unit:AddNewModifier(caster, ability, "modifier_sticky_membrane_disarm", {Duration = disarmDuration})

        local projTable = {
            Target = caster,
            Source = unit,
            Ability = ability,
            EffectName = "particles/units/heroes/hero_rubick/rubick_spell_steal.vpcf",
            bDodgeable = false,
            bProvidesVision = false,
            iMoveSpeed = 800, 
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, 
            vSpawnOrigin = unit:GetAbsOrigin()
        }
        ProjectileManager:CreateTrackingProjectile( projTable )

        local heal = unit:GetAttackDamage() * ability:GetSpecialValueFor("absorb_heal_pct") / 100
        caster:Heal(heal,ability)
    end
end

modifier_sticky_membrane_passive = class({})

function modifier_sticky_membrane_passive:IsHidden()
	return true
end

function modifier_sticky_membrane_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACKED
	}
	return funcs
end

function modifier_sticky_membrane_passive:OnAttacked(keys)
	if not IsServer() then return end
    if keys.target == self:GetParent() and not self:GetParent():PassivesDisabled() then
        local caster = self:GetParent()
    	local attacker = keys.attacker
    	local ability = self:GetAbility()
    	local triggerChange = ability:GetSpecialValueFor("trigger_chance")

    	local rng = RollPercentage(triggerChange)
        if rng == true then 
            local distance = (caster:GetAbsOrigin() - attacker:GetAbsOrigin()):Length2D()
            local triggerRadius = ability:GetSpecialValueFor("trigger_radius")

            if distance <= triggerRadius and not attacker:IsMagicImmune() and not attacker:IsBuilding() then
                local disarmDuration = ability:GetSpecialValueFor("disarm_duration")
                local modifier = attacker:AddNewModifier(caster, ability, "modifier_sticky_membrane_disarm", {Duration = disarmDuration})

                local projTable = {
                    Target = caster,
                    Source = attacker,
                    Ability = ability,
                    EffectName = "particles/units/heroes/hero_rubick/rubick_spell_steal.vpcf",
                    bDodgeable = false,
                    bProvidesVision = false,
                    iMoveSpeed = 800, 
                    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, 
                    vSpawnOrigin = attacker:GetAbsOrigin()
                }
                ProjectileManager:CreateTrackingProjectile( projTable )

                -- local particle = ParticleManager:CreateParticle("", PATTACH_OVERHEAD_FOLLOW, attacker)
                -- if modifier then modifier:AddParticle(particle, false, true, 1, false, true) end
                -- local heal = keys.damage + keys.damage * ability:GetSpecialValueFor("absorb_heal_pct") / 100
                -- caster:Heal(heal,ability)

            end
    	end
    end
end

modifier_sticky_membrane_disarm = class({})


function modifier_sticky_membrane_disarm:IsHidden()
    return false
end


function modifier_sticky_membrane_disarm:OnCreated()
    if not IsServer() then return end
    self:GetParent():EmitSound("Hero_Bane.Enfeeble.Cast")
end

function modifier_sticky_membrane_disarm:GetEffectName()
    return "particles/units/heroes/hero_viscous_ooze/viscous_ooze_sticky_disarm.vpcf"
end

function modifier_sticky_membrane_disarm:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_sticky_membrane_disarm:CheckState()
    local states = {
        [MODIFIER_STATE_DISARMED] = true
    }
    return states
end