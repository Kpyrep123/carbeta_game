
--[[Author: TheGreatGimmick
    Date: May 27, 2017
    Zip's E, Slow Motion]]

--Place the barrier.
function SetBarrier(event)
    print("")
    print("Preparing Barrier")
    local caster = event.caster
    local ability = event.ability
    local point = event.target_points[1]

    local barrier_length = ability:GetLevelSpecialValueFor("length", (ability:GetLevel() - 1))
    local origin = caster:GetAbsOrigin()

    local line_between = (point - origin)
    local barrier_line_left = Vector(-line_between.y, line_between.x, 0):Normalized()
    local barrier_line_right = Vector(line_between.y, -line_between.x, 0):Normalized()

    if not caster.sound_barrier then caster.sound_barrier = {} end
    local targets = caster.sound_barrier or {}
    for _,unit in pairs(targets) do 
        if unit and IsValidEntity(unit) then
            unit:RemoveSelf()
        end
    end
    --create individual barrier units, starting with left side then with right
    for c = 1,10,1 do
       -- print("Creating pair "..c.." of sound barriers.")
        --left
        local position = point + c*(barrier_length/20)*barrier_line_left

        AddFOWViewer(caster:GetTeam(), position, 300, 0.2, false)
        local barrier = CreateUnitByName("sound_barrier_dummy", position, false, caster, caster, caster:GetTeam())
        barrier:FindAbilityByName("zip_sound_barrier_passive_a"):SetLevel(1)
        barrier:FindAbilityByName("zip_sound_barrier_passive_b"):SetLevel(1)
        barrier:SetForwardVector((position-point)*-1)
        barrier:SetOwner(caster)
        barrier:AddNewModifier(caster, ability, "modifier_kill", { duration = 10 })
        table.insert(caster.sound_barrier, barrier)

        --right
        local position = point + c*(barrier_length/20)*barrier_line_right

        AddFOWViewer(caster:GetTeam(), position, 300, 0.2, false)
        local barrier = CreateUnitByName("sound_barrier_dummy", position, false, caster, caster, caster:GetTeam())
        barrier:FindAbilityByName("zip_sound_barrier_passive_a"):SetLevel(1)
        barrier:FindAbilityByName("zip_sound_barrier_passive_b"):SetLevel(1)
        barrier:SetForwardVector((position-point)*-1)
        barrier:SetOwner(caster)
        barrier:AddNewModifier(caster, ability, "modifier_kill", { duration = 10 })
        table.insert(caster.sound_barrier, barrier)
    end
end

--Block units from passing the barrier, and shatter it when necessary.
function UnitBlock(event)
    local caster = event.caster
    local ability = event.ability

    local block_aoe = ability:GetLevelSpecialValueFor("AOE_B", (ability:GetLevel() - 1))
    local shatter_aoe = ability:GetLevelSpecialValueFor("AOE", (ability:GetLevel() - 1))
    	--get units contacting the barrier
        local all_units = FindUnitsInRadius(caster:GetTeamNumber(),
                             caster:GetAbsOrigin(),
                             nil,
                             block_aoe,
                             DOTA_UNIT_TARGET_TEAM_BOTH,
                             DOTA_UNIT_TARGET_ALL, --DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC,
                             DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                             FIND_ANY_ORDER,
                             false)

    --check speed of unit contacting barrier
    for _,unit1 in pairs(all_units) do
        if not unit1:IsNull() and not caster:IsNull() then
            local MS = unit1:GetIdealSpeed()
            local zip = caster:GetOwner()

            if MS > 550 then
            	--shatter barrier
                unit1:EmitSound("Hero_Terrorblade.Sunder.Target") --unit1:EmitSound("Hero_Terrorblade.Sunder.Cast")
                if zip then
                    print("")
                    local ability = zip:FindAbilityByName("zip_sound_barrier")

                    local level_damage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() - 1))
                    local stun_duration = ability:GetLevelSpecialValueFor("stun", (ability:GetLevel() - 1))

                    local targets = zip.sound_barrier or {}

                    for _,unit2 in pairs(targets) do 
                        if unit2 and IsValidEntity(unit2) then
                            print("Shatter")
                            print(shatter_aoe)
                            print(unit1:GetTeamNumber())
                            print(unit2:GetAbsOrigin())

                            local enemies = FindUnitsInRadius(unit1:GetTeamNumber(),
                                   unit2:GetAbsOrigin(),
                                    nil,
                                    shatter_aoe,
                                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                                    DOTA_UNIT_TARGET_ALL,
                                    DOTA_UNIT_TARGET_FLAG_NONE,
                                    FIND_ANY_ORDER,
                                    false)

                            if not zip.sound_barrier_victims then zip.sound_barrier_victims = {} end
                            for _,unit3 in pairs(enemies) do
                                if unit3 and IsValidEntity(unit3) and unit3:GetName() ~= "npc_dota_ward_base" and not unit3:IsBuilding() then
                                    table.insert(zip.sound_barrier_victims, unit3)
                                    print("Target aquired: "..unit3:GetName())
                                end
                            end

                            local particleName = "particles/units/heroes/hero_magnataur/magnataur_reverse_polarity.vpcf"
                            local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, unit2)
                            ParticleManager:SetParticleControl( particle, 3, unit2:GetAbsOrigin() )
                            --ParticleManager:SetParticleControl( particle, 6, unit2:GetAbsOrigin() )

                            unit2:RemoveSelf()
                        end
                    end
                    zip.sound_barrier = {}

                    local targets2 = zip.sound_barrier_victims or {}

                    for _,unit4 in pairs(targets2) do
                        unit4.has_taken_damage_from_this_sound_barrier = 0
                    end
                    for _,unit4 in pairs(targets2) do
                        local damageTable = {
                            victim = unit4,
                            attacker = unit1,
                            damage = level_damage,
                            damage_type = DAMAGE_TYPE_MAGICAL,
                            }
                        if unit4 ~= unit1 and unit4.has_taken_damage_from_this_sound_barrier == 0 and not unit4:IsNull() then
                            print("Damaging and stunning"..unit4:GetName())
                            ApplyDamage(damageTable)
                            unit4:AddNewModifier(unit1, ability, "modifier_stunned", { duration = stun_duration })
                            unit4.has_taken_damage_from_this_sound_barrier = 1
                        end
                    end
                    zip.sound_barrier_victims = {}
                end
            else
            	--block passage of units 
                if zip and not zip:IsNull() and not unit1:IsBuilding() then
            
                    local targets = zip.sound_barrier or {}
                    local pos = unit1:GetAbsOrigin()
                    local min_length = 1000000000
                    local chosen_barrier = caster

                    --find barrier closest to current checked unit
                    for _,unit in pairs(targets) do
                        if not unit:IsNull() then
                            local pos_b = unit:GetAbsOrigin()
                            local length = (pos - pos_b):Length2D()
                            if length < min_length then
                                min_length = length
                                chosen_barrier = unit
                            end
                        end
                    end

                    --force unit back to simulate passage being blocked
                    local pos_b = chosen_barrier:GetAbsOrigin()
                    local orient = (pos - pos_b):Normalized()
                    local dist = block_aoe + 25

                    local block_point = pos_b + orient*dist

                    local check = unit1:FindAbilityByName("zip_sound_barrier_passive_b")
                    if not check then
                        chosen_barrier:EmitSound("Hero_Clinkz.SearingArrows.Impact.Layer")
                    end
                    unit1:SetAbsOrigin(block_point)
                    FindClearSpaceForUnit(unit1, block_point, false)
                end
            end
        end
    end
end