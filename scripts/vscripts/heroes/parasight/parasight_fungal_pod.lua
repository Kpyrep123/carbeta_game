parasight_fungal_pod = class({})
LinkLuaModifier("modifier_parasight_fungal_pod", "scripts/vscripts/heroes/parasight/modifier_parasight_fungal_pod.lua", LUA_MODIFIER_MOTION_NONE)

function parasight_fungal_pod:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local ability = self
    local target_location = self:GetCursorPosition()

    caster.podTable = caster.podTable or {}

    local maxPods = ability:GetSpecialValueFor("max_limit")

    -- Check for talent
    local talent = caster:FindAbilityByName("special_bonus_unique_parasight_1")
    if talent and talent:GetLevel() > 0 then
        maxPods = maxPods + talent:GetSpecialValueFor("value")
    end

    -- Create pod
    CreateUnitByNameAsync("npc_parasight_fungal_pod", target_location, false, caster, caster:GetPlayerOwner(), caster:GetTeam(), 
        function(pod)
            -- pod:SetOwner(caster)
            pod:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
            pod:FindAbilityByName("parasight_fungal_pod_combust"):SetLevel(1)
            pod:AddNewModifier(nil,nil,"modifier_phased", {Duration = 0.03})
            --pod:SetOriginalModel("models/items/courier/shroomy/shroomy.vmdl")

            pod:EmitSound("Hero_Parasight.Fungal_Pod")
            -- Spawn callback


            local max_growth_duration = self:GetSpecialValueFor("max_growth_duration")

            -- Check for talent
            local talent = caster:FindAbilityByName("special_bonus_unique_parasight_4")
            if talent and talent:GetLevel() > 0 then
               max_growth_duration = max_growth_duration + talent:GetSpecialValueFor("value")
            end



            -- Add growth modifier
            pod:AddNewModifier(pod, self, "modifier_parasight_fungal_pod", {
                max_growth_duration = max_growth_duration
            })

            -- make invisible
            pod:AddNewModifier(pod, self, "modifier_invisible", {
                fadetime = 0,
                subtle = 1,
                cancelattack = 0
            })

            -- Set duration
            --local duration = self:GetSpecialValueFor("duration")
            --pod:AddNewModifier(pod ,self, "modifier_kill", {Duration = duration})

            -- Add to table, kill last pod if greater than max
            table.insert(caster.podTable, pod)
            if #caster.podTable > maxPods and not caster.podTable[1]:IsNull() then
                caster.podTable[1]:ForceKill(true)
            end

            -- Make activatable
            local activation = pod:AddNewModifier(nil, nil, "modifier_activatable", {
                alliesOnly = true,
                distance = 200,
                cooldown = 5
            })
            -- Set callback
            activation.OnActivate = function(activatee, activator)
                local ability = PlayerResource:GetPlayer(activatee:GetMainControllingPlayer()):GetAssignedHero():FindAbilityByName("parasight_fungal_pod")
                if ability then ability:OnPodActivate(pod, activator) end
            end

            -- Add particle
            local particle = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_parasight/parasight_fungal_pod_ambient.vpcf", PATTACH_ABSORIGIN, pod, caster:GetTeam())
            ParticleManager:ReleaseParticleIndex(particle)

            -- Ramp scale 0 to 1
            local start = GameRules:GetGameTime()
            local ramp_duration = 0.5
            local end_scale = 1.2
            pod:SetModelScale(0.1)

            -- Elastic easing function
            local function ease_out_elastic(t, offset, scale)
                local ts = t*t
                local tc = ts * t
                return offset + scale * (33 * ts * tc - 106 * ts * ts + 126 * tc - 67*ts + 15*t)
            end

            --local changeModel = true

            Timers:CreateTimer(function()
                local time = GameRules:GetGameTime()
                -- Check if done ramping yet
                if time - start > ramp_duration then
                    -- Finish ramp
                    pod:SetModelScale(end_scale)
                    return nil
                end

                -- Calculate intermadiate scale
                local t = (time - start)/ramp_duration
                pod:SetModelScale(ease_out_elastic(t, 0, end_scale))                    

                return 1/30
            end)
        end
    )
end

function parasight_fungal_pod:OnPodActivate(pod, activator)
    if not IsServer() then return end
    
    local HEAL_DURATION = self:GetSpecialValueFor("heal_duration")
    local MIN_HEAL = self:GetSpecialValueFor("min_heal")
    local MAX_HEAL = self:GetSpecialValueFor("max_heal")
    local HEAL_RADIUS = self:GetSpecialValueFor("heal_radius")

    local modifier = pod:FindModifierByName("modifier_parasight_fungal_pod")
    modifier:Stop()

    -- Make visible
    pod:RemoveModifierByName("modifier_invisible")

    -- Play sound
    pod:EmitSound("Hero_Parasight.Fungal_Pod.Restore")

    -- Calculate healing to be done based on modifier
    local heal = MIN_HEAL + (MAX_HEAL - MIN_HEAL) * (modifier:GetStackCount()/100)
    local heal_per_sec = heal/HEAL_DURATION

    -- Check for talent
    local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_parasight_3")
    if talent and talent:GetLevel() > 0 then
        heal = heal + talent:GetSpecialValueFor("value")
    end

    local particle = ParticleManager:CreateParticle("particles/world_shrine/radiant_shrine_active.vpcf", PATTACH_ABSORIGIN, pod)

    -- Get start time
    local start = GameRules:GetGameTime()
    -- Start timer
    Timers:CreateTimer(function()
        if GameRules:GetGameTime() - start > HEAL_DURATION or not pod:IsAlive() then
            ParticleManager:DestroyParticle(particle, false)
            ParticleManager:ReleaseParticleIndex(particle)

            -- Kill pod
            pod:StopSound("Hero_Parasight.Fungal_Pod.Restore")
            pod:ForceKill(false)
            return nil
        end

        -- Search for units to heal
        local units = FindUnitsInRadius(pod:GetTeam(), pod:GetAbsOrigin(), nil, HEAL_RADIUS, DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

        -- Heal all units
        for _, unit in pairs(units) do
            if unit ~= pod then
                unit:Heal(heal_per_sec * FrameTime(), self:GetCaster())
                --unit:GiveMana(heal_per_sec * FrameTime())
            end
        end

        return 0
    end)
end
