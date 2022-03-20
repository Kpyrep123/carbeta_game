--LinkLuaModifier("modifier_slow_motion", "heroes/hero_zip/modifiers/modifier_slow_motion.lua", LUA_MODIFIER_MOTION_NONE)

--[[Author: TheGreatGimmick
    Date: May 31, 2017
    Zip's R, Light Speed]]

function Beam(event)
    print("")
    print("Preparing Beam")
    local caster = event.caster
    local ability = event.ability
    local point = event.target_points[1]

    --initialize unit-tracker for Beam
    if not caster.light_speed_victims then caster.light_speed_victims = {} end

    --initialize ability parameters
    local damage_percent = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() - 1))
    local radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() - 1))
    local MS = caster:GetIdealSpeed()
    local position = caster:GetAbsOrigin()

    local damage_total = (damage_percent / 100) * MS
    print(damage_total)
    local direction = (point - position):Normalized()

    --figure out world coordinates
    xMax = GetWorldMaxX()
    yMax = GetWorldMaxY()
    xMin = GetWorldMinX()
    yMin = GetWorldMinY()
    print("X: "..xMin.." - "..xMax)
    print("Y: "..yMin.." - "..yMax)

    --Begin Beam propagation
    local check = 0
    local last_point = position
    local sound_check = 0 
    for c = 0,1500,1 do
    	--next Beam waypoint
        local current_point = position + direction*c*100

        if current_point.x > xMin and current_point.x < xMax and current_point.y > yMin and current_point.y < yMax then
            --print("Propagating Beam")
            --add vision
            AddFOWViewer(caster:GetTeam(), current_point, radius, 0.2, false)

            sound_check = sound_check + 1
            if sound_check >= 15 then
                sound_check = 0
                local soundblast = CreateUnitByName("eye_of_the_moon_dummy", current_point, false, caster, caster, caster:GetTeam())
                soundblast:EmitSound("Hero_Puck.Waning_Rift")
                --Timers:CreateTimer(0.1, function ()
                    soundblast:RemoveSelf()
                --end)
            end
            --add any relevant targets to unit tracker
            local victims = FindUnitsInRadius(caster:GetTeamNumber(),
                             current_point,
                             nil,
                             radius,
                             DOTA_UNIT_TARGET_TEAM_ENEMY,
                             DOTA_UNIT_TARGET_ALL, --DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC,
                             DOTA_UNIT_TARGET_FLAG_NONE,
                             FIND_ANY_ORDER,
                             false)
            for _,unit in pairs(victims) do
                if not unit:IsBuilding() then
                    table.insert(caster.light_speed_victims, unit)
                end
            end
            --last_point = current_point
        else
        	--out-of-bounds
            if check == 0 then
                print("Ending Beam")
                check = 1
                --print(last_point)
                local last_point = current_point - direction*100*100
                local endpoint = Vector(last_point.x, last_point.y, last_point.z)
                AddFOWViewer(caster:GetTeam(), endpoint, radius, 100, false)

                --print(endpoint)

                local laser_distance = (endpoint - position):Length2D()
                local laser_speed = laser_distance*10
                --particle voodoo
                caster.light_speed_flash_point = CreateUnitByName("eye_of_the_moon_dummy", endpoint, false, caster, caster, caster:GetTeam())
                local info = {
                    Target = caster.light_speed_flash_point,
                    Source = caster,
                    Ability = ability,
                    EffectName = "particles/units/heroes/hero_tinker/tinker_laser.vpcf",
                    bDodgeable = false,
                    bProvidesVision = false,
                    iMoveSpeed = laser_speed,
                    iVisionRadius = 0,
                    iVisionTeamNumber = caster:GetTeamNumber(),
                    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2 --DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
                    }
                ProjectileManager:CreateTrackingProjectile( info )
                
                Timers:CreateTimer(10, function ()
                    caster.light_speed_flash_point:RemoveSelf()
                end)
            end
            --]]
        end
    end

    --iterate through unit-tracker
    local targets2 = caster.light_speed_victims or {}
    for _,unit4 in pairs(targets2) do
    	--initialize damage checker; dont want to damage same unit twice
        unit4.has_taken_damage_from_this_light_speed = 0
    end
    for _,unit4 in pairs(targets2) do
        local damageTable = {
            victim = unit4,
            attacker = caster,
            damage = damage_total,
            damage_type = DAMAGE_TYPE_MAGICAL,
            }
        --deal damage if not already
        if unit4.has_taken_damage_from_this_light_speed == 0 and not unit4:IsNull() then
            print("Damaging "..unit4:GetName())
            ApplyDamage(damageTable)

            local laser_distance = ((unit4:GetAbsOrigin()) - position):Length2D()
            local laser_speed = laser_distance*10
            --more particle shennigans
            local info = {
                    Target = unit4,
                    Source = caster,
                    Ability = ability,
                    EffectName = "particles/units/heroes/hero_tinker/tinker_laser.vpcf",
                    bDodgeable = false,
                    bProvidesVision = false,
                    iMoveSpeed = laser_speed,
                    iVisionRadius = 0,
                    iVisionTeamNumber = caster:GetTeamNumber(),
                    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2 --DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
                    }
            ProjectileManager:CreateTrackingProjectile( info )
            --Scepter blinds affected units; and stuns, apparently (might remove that)
            if caster:HasScepter() then
                unit4:AddNewModifier(caster, ability, "modifier_stunned", { duration = 0.2 })
                unit4:AddNewModifier(caster, ability, "modifier_tinker_laser_blind", { duration = 5.2 })
            end
            unit4.has_taken_damage_from_this_light_speed = 1
        end
    end
    caster.light_speed_victims = {}

--[[
    local info = {
                    Target = caster.light_speed_endpoint,
                    Source = caster,
                    Ability = ability,
                    EffectName = "particles/units/heroes/hero_tinker/tinker_laser.vpcf",--"particles/econ/items/tidehunter/tidehunter_divinghelmet/tidehunter_gush_diving_helmet.vpcf",
                    bDodgeable = false,
                    bProvidesVision = false,
                    iMoveSpeed = 150000,
                    iVisionRadius = 0,
                    iVisionTeamNumber = caster:GetTeamNumber(),
                    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2 --DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
                }
    ProjectileManager:CreateTrackingProjectile( info )
    caster.light_speed_endpoint:RemoveSelf()
    ]]
end

