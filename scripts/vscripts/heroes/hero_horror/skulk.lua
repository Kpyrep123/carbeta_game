--[[Author: TheGreatGimmick
    Date: March 1, 2017
    Checks for and executes Skulk teleportation.]]

function Skulk(event)
    --Variables
    local caster = event.caster
    local point = event.target_points[1]
    local ability = event.ability

    --initialize the vision-checking dummy if it has not been already
    if not caster.vision_checker then
        local team = caster:GetTeamNumber()
        local panic = 0
        --set vision dummy to the opposite team. If there are more than two teams, do not spawn a vision dummy. 
        if team == 2 then
            team = 3
        else
            if team == 3 then
                team = 2
            else
                panic = 1
            end
        end
        --create vision dummy if there are just two teams. 
        if panic == 0 then
            caster.vision_checker = CreateUnitByName("eye_of_the_moon_dummy", Vector(0, 0, 0), false, caster, caster, team)
            print("Vision checker made by "..caster:GetName().." created on team "..team..".")
        else
            print("Vision checker has failed due to the team being '"..team.."'.")
        end
    end


    local starting_point = caster:GetAbsOrigin() --current location
    --calculate distance between current and targeted locations. 
    local distance = point - starting_point 
    distance = distance:Length2D()
    print("")
    print('Distance: '..distance)

    --calculate mana cost based on distance. 
    local mana_cost = ability:GetLevelSpecialValueFor("manacost", (ability:GetLevel() - 1))
    local cost = mana_cost*(distance/100)
    print('Mana cost: '..cost)

    local mana_pool = caster:GetMana() --current mana
    print('Caster mana: '..mana_pool)

	local teleport_dummy = CreateUnitByName("skulk_dummy", point, true, caster, caster, caster:GetTeam())

    if mana_pool >= cost then
        --if the caster has enough mana to cast the spell: 

        --create a dummy at the targeted location. 
        

        --use the vision-checking dummy on the target-location dummy and the caster to see if either can be seen. 
        local see_caster = caster.vision_checker:CanEntityBeSeenByMyTeam(caster)
        local see_target = caster.vision_checker:CanEntityBeSeenByMyTeam(teleport_dummy)

        --check if caster is within a cold spot
        local cold_spot = 0
        local allallies = FindUnitsInRadius(caster:GetTeamNumber(),
                             teleport_dummy:GetAbsOrigin(),
                             nil,
                             325,
                             DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                             DOTA_UNIT_TARGET_ALL,
                             DOTA_UNIT_TARGET_FLAG_NONE,
                             FIND_ANY_ORDER,
                             false)
        for _,unit in pairs(allallies) do
            local innate_ability = unit:FindAbilityByName("cold_spot_dummy_passive")
            if innate_ability then
                cold_spot = 1
            end
        end


        if not see_caster then
            if ( not see_target ) or cold_spot == 1 then
                --if both the caster and the target cannot be seen:

                caster:SetAbsOrigin(point) --We move the caster instantly to the location
                FindClearSpaceForUnit(caster, point, false) --This makes sure our caster does not get stuck

                caster:SetMana(mana_pool - cost) --apply mana cost

                --apply cooldown
                local cooldown_ratio = ability:GetLevelSpecialValueFor("cd", (ability:GetLevel() - 1))

                --apply cooldown reduction. Currently bugged for Rubick for some reason. 
                local transchars = caster:FindAbilityByName("horror_lastspell")
                if transchars then
                    transchars:EndCooldown()
                    transchars:UseResources(false,false,true)
                    local cooltest = transchars:GetCooldownTime()
                    cooldown_ratio = cooldown_ratio*cooltest
                    print('rubick should not do this')
                end

                --apply cooldown 
                caster.skulk_cooldown = cooldown_ratio*(distance/100)
                ability:StartCooldown(caster.skulk_cooldown)

                --debugging stuff
                --local cooldown_storage = caster:FindAbilityByName("horror_lastspell")
                --local cd_check = ability:GetCooldownTimeRemaining()
                --print('Skulk reported cooldown: '..cd_check)
                --cooldown_storage:StartCooldown(cd_check)

                caster:EmitSound("Conquest.hallow_laughter") --play sound

            else
                --apply penaty cooldown if the targeted location can be seen. 
                print('The target can be seen.')
                ability:StartCooldown(ability:GetLevelSpecialValueFor("fail", (ability:GetLevel() - 1)))
            end
            --remove target-location dummy 
        else
            --if the caster can be seen, do nothing 
            print('The Skulk caster can be seen.')
        end
    else
        --if the caster lacks the necessary mana, do nothing except refund the 20 base mana cost. 
        print('Not enough mana.')
        caster:SetMana(mana_pool + 20)
        caster:EmitSound("life_stealer_lifest_nomana_07")
    end

    teleport_dummy:RemoveSelf()
    
end