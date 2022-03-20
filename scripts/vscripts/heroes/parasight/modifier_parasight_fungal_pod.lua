LinkLuaModifier("modifier_parasight_fungal_pod_combust", "scripts/vscripts/heroes/parasight/modifier_parasight_fungal_pod.lua", LUA_MODIFIER_MOTION_NONE)

modifier_parasight_fungal_pod = class({})

function modifier_parasight_fungal_pod:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MODEL_SCALE
    }
end

function modifier_parasight_fungal_pod:GetModifierModelScale()
    return 1.3 * self:GetStackCount()
end

function modifier_parasight_fungal_pod:OnCreated(params)
    self.growth_duration = params.max_growth_duration
    self.growth_start = GameRules:GetGameTime()

    local ability = self:GetAbility()
    self.explodeDuration = ability:GetSpecialValueFor("heal_duration")
    self.min_damage = ability:GetSpecialValueFor("min_heal")
    self.max_damage = ability:GetSpecialValueFor("max_damage")
    self.radius = ability:GetSpecialValueFor("heal_radius")
    -- Start thinking
    self:StartIntervalThink(0)
end

function modifier_parasight_fungal_pod:OnIntervalThink()
    if IsServer() then
        local time = GameRules:GetGameTime()
        local fraction = (time - self.growth_start)/self.growth_duration

        self:SetStackCount(math.floor(fraction * 100))

        -- Stop thinking if fully grown
        if fraction >= 1 then
            self:SetStackCount(100)
            self:StartIntervalThink(-1)
        end
    end
end

function modifier_parasight_fungal_pod:Stop()
    self:StartIntervalThink(-1)
end

function modifier_parasight_fungal_pod:Combust()
    if IsServer() then
        local pod = self:GetCaster()
        local player = PlayerResource:GetPlayer(pod:GetMainControllingPlayer())
        local owner = player:GetAssignedHero()

        local DURATION
        local MIN_DAMAGE
        local MAX_DAMAGE
        local DAMAGE_RADIUS

        local ability = owner:FindAbilityByName("parasight_fungal_pod")
        if ability then
            DURATION = ability:GetSpecialValueFor("heal_duration")
            MIN_DAMAGE = ability:GetSpecialValueFor("min_heal")
            MAX_DAMAGE = ability:GetSpecialValueFor("max_damage")
            DAMAGE_RADIUS = ability:GetSpecialValueFor("heal_radius")
        else
            DURATION = self.explodeDuration
            MIN_DAMAGE = self.min_damage
            MAX_DAMAGE = self.max_damage
            DAMAGE_RADIUS = self.radius
        end
        -- Check for talent
        local talent = owner:FindAbilityByName("special_bonus_unique_parasight_2")
        if talent and talent:GetLevel() > 0 then
            MAX_DAMAGE = MAX_DAMAGE + talent:GetSpecialValueFor("value")
        end

        --pod:EmitSound("Hero_Parasight.Fungal_Pod.Combust")

        -- Get growth modifier
        local modifier = pod:FindModifierByName("modifier_parasight_fungal_pod")
        modifier:Stop()

        -- Fire sound
        pod:EmitSoundParams("Hero_Parasight.Fungal_Pod.Combust", 2.5 - (modifier:GetStackCount() / 50), 1 + (modifier:GetStackCount() / 50), 0)

        -- Calculate damage to be done based on modifier
        local damage = MIN_DAMAGE + (MAX_DAMAGE - MIN_DAMAGE) * (modifier:GetStackCount()/100)

        


        -- Creates a thinker that deals damage in an area
        local position = pod:GetAbsOrigin()
        local thinker = CreateModifierThinker(owner,ability,"modifier_parasight_fungal_pod_combust",{
            Duration = DURATION,
            Damage = damage / DURATION,
            Radius = DAMAGE_RADIUS,
            x = position.x,
            y = position.y,
            z = position.z
        },pod:GetAbsOrigin(),owner:GetTeamNumber(),false)

        -- local particle = ParticleManager:CreateParticle('particles/neutral_fx/black_dragon_fireball.vpcf', PATTACH_WORLDORIGIN, self:GetCaster())
        -- ParticleManager:SetParticleControl(particle, 0, pod:GetAbsOrigin())
        -- ParticleManager:SetParticleControl(particle, 1, pod:GetAbsOrigin() + Vector(0, 0, 128))


        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_parasight/parasight_fungal_pod_combust.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particle, 0, pod:GetAbsOrigin() + Vector(0,0,50))
        Timers:CreateTimer(DURATION, function() 
            ParticleManager:DestroyParticle(particle, false)
            ParticleManager:ReleaseParticleIndex(particle)
            end)

        -- Kill pod
        pod:ForceKill(false)
    end
end

function modifier_parasight_fungal_pod:OnDestroy()
    if not IsServer() then return end
    self:RemovePodFromTable(self:GetParent())
end

function modifier_parasight_fungal_pod:RemovePodFromTable(unit)
    if IsServer() then
        local owner = PlayerResource:GetPlayer(unit:GetMainControllingPlayer()):GetAssignedHero()
        -- print(#owner.podTable)
        if owner.podTable then
            for i = 1, #owner.podTable do
                if owner.podTable[i] == unit then
                    table.remove(owner.podTable, i)
                    break
                end
            end
        end
    end
end




-- RAMP SCALE PERCENTAGE (100 - scale)% min, (100 + scale)% max
local ramp_scale = 50

modifier_parasight_fungal_pod_combust = class({})

function modifier_parasight_fungal_pod_combust:OnCreated(params)
    self.interval = 0.5
    self.radius = params.Radius
    self.duration = params.Duration

    self.position = Vector(params.x, params.y, params.z)
    if IsServer() then
        self.base_damage = params.Damage * self.interval
        self:StartIntervalThink(self.interval)

    end
end

function modifier_parasight_fungal_pod_combust:OnIntervalThink()
    if IsServer() then
        local caster = self:GetCaster()
        local position = self.position
        -- Search for units to damage
        local units = FindUnitsInRadius(caster:GetTeam(), position, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        
        -- Calculate damage, ramps up over time
        self.damage = self.base_damage * (100 - (ramp_scale * (self:GetRemainingTime() * 2 - self.duration) / self.duration)) / 100
        -- Deal damage in 0.5 second intervals
        for _, unit in pairs(units) do
            ApplyDamage({
                victim = unit,
                attacker = self:GetCaster(),
                damage = self.damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                damage_flags = DOTA_DAMAGE_FLAG_NONE,
                ability = self:GetAbility()
            })
        end
    end
end

