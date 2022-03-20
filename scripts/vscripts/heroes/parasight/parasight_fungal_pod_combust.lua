parasight_fungal_pod_combust = class({})

function parasight_fungal_pod_combust:OnSpellStart()
    local pod = self:GetCaster()
    local owner = pod:GetOwner()
    local ability = owner:FindAbilityByName("parasight_fungal_pod")

    local HEAL_DURATION = ability:GetSpecialValueFor("heal_duration")
    local MIN_HEAL = ability:GetSpecialValueFor("min_heal")
    local MAX_HEAL = ability:GetSpecialValueFor("max_heal")
    local HEAL_RADIUS = ability:GetSpecialValueFor("heal_radius")

    -- Get growth modifier
    local modifier = pod:FindModifierByName("modifier_parasight_fungal_pod")
    modifier:Stop()

    -- Calculate damage to be done based on modifier
    local damage = MIN_HEAL + (MAX_HEAL - MIN_HEAL) * (modifier:GetStackCount()/100)

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_parasight/parasight_fungal_pod_combust.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, pod:GetAbsOrigin() + Vector(0,0,50))
    ParticleManager:ReleaseParticleIndex(particle)

    -- Search for units to damage
    local units = FindUnitsInRadius(pod:GetTeam(), pod:GetAbsOrigin(), nil, HEAL_RADIUS, DOTA_UNIT_TARGET_TEAM_ENEMY, 
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

    -- Damage targets in radius
    for _, unit in pairs(units) do
        ApplyDamage({
            victim = unit,
            attacker = owner,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = ability
        })
    end

    -- Kill pod
    pod:RemoveSelf()
end