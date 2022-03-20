LinkLuaModifier("modifier_boo_charges", "heroes/hero_horror/modifiers/modifier_boo_charges.lua", LUA_MODIFIER_MOTION_NONE)

--[[Author: TheGreatGimmick
    Date: March 3, 2017
    Horror's E, Terrify ]]

--Initialize vision checker and charges 
function BooStart( event )
	local caster = event.caster
    local ability = event.ability

    if not caster.levelup_4_checker then caster.levelup_4_checker = 0 end 

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

    --if not caster.neutral_vision_checker then
    	--caster.neutral_vision_checker = CreateUnitByName("eye_of_the_moon_dummy", Vector(0, 0, 0), false, caster, caster, 4)
    --end

    --initialize charges 
    if not caster.boo_charges then
    	if caster:HasScepter() then
            --double charges if he has a scepter
    		caster.boo_charges = 20
    	else
    		caster.boo_charges = 10
    	end
    	caster.boo_charge_counter = 0
        --display charges
        local modifierName = "modifier_boo_charges"
        caster:SetModifierStackCount(modifierName, ability, 0 )
        caster:AddNewModifier(caster, ability, modifierName, {})
        caster:SetModifierStackCount( modifierName, ability, caster.boo_charges )
    end

end

--check if seen, and respond appropriately. 
function BooCheck( event )
	local caster = event.caster

		--print(caster.levelup_4_checker)
	        local talent_name = "special_bonus_levelup_4"
            if caster.levelup_4_checker == 0 and caster:HasAbility(talent_name) then
                local talent_level = caster:FindAbilityByName(talent_name):GetLevel()
                if talent_level > 0 then
                	caster.levelup_4_checker = 1
                    local current_level = caster:GetLevel()
    				local starting_exp = caster:GetCurrentXP()
    
    				for x = 1,4,1 do 
        				if current_level < 25 then
            				local new_level = current_level + 1
            				while current_level < new_level do
                			caster:AddExperience(1, 0, false, false)
                			current_level = caster:GetLevel()
            				end
        				end
    				end
                end
            end
    --make sure the vision checker has been initialized. 
	if caster.vision_checker then
        --Variables
		local charges = caster.boo_charges
		local ability = event.ability
        local modifierName = "modifier_boo_charges"

        --reapply charge display modifier if necessary
        local mod = caster:FindModifierByName(modifierName)
        if mod == nil then
            caster:RemoveModifierByName( modifierName )
            caster:AddNewModifier(caster, ability, modifierName, {} )
            caster:SetModifierStackCount(modifierName, ability, caster.boo_charges )
        end

        --check if within a cold spot
        local cold_spot = 0
        local allallies = FindUnitsInRadius(caster:GetTeamNumber(),
                             caster:GetAbsOrigin(),
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
                cold_spot = 1 --if cold spot dummy unit is within cold spot's radius of the Horror, flag it. 
            end
        end

    	if caster.vision_checker:CanEntityBeSeenByMyTeam(caster) and cold_spot == 0 then
            --if the Horror can be seen... 
    		local boo = 0 --this is a flag so the sound only plays once. 
            --Variables 
    		local damage = ability:GetLevelSpecialValueFor("dmg", (ability:GetLevel() - 1))
            local Bradius = ability:GetLevelSpecialValueFor("baseAoE", (ability:GetLevel() - 1))
            local Cradius = ability:GetLevelSpecialValueFor("chrgAoE", (ability:GetLevel() - 1))

            local talent_name = "special_bonus_unique_horror1"
            if caster:HasAbility(talent_name) then
                local talent_level = caster:FindAbilityByName(talent_name):GetLevel()
                if talent_level > 0 then
                    damage = damage + 5
                end
            end

            --Parameters 
    		local damage = damage*caster.boo_charges
            local AoE = Bradius + Cradius*caster.boo_charges

            --reset charges and display as such
    		caster.boo_charges = 0
            caster:SetModifierStackCount(modifierName, ability, caster.boo_charges )

            --find damage targets 
    		local hero_enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                             caster:GetAbsOrigin(),
                             nil,
                             AoE,
                             DOTA_UNIT_TARGET_TEAM_ENEMY,
                             DOTA_UNIT_TARGET_HERO,
                             DOTA_UNIT_TARGET_FLAG_NONE,
                             FIND_ANY_ORDER,
                             false)

			local creep_enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                             caster:GetAbsOrigin(),
                             nil,
                             AoE,
                             DOTA_UNIT_TARGET_TEAM_ENEMY,
                             DOTA_UNIT_TARGET_BASIC,
                             DOTA_UNIT_TARGET_FLAG_NONE,
                             FIND_ANY_ORDER,
                             false)
            --damage heroes
			for _,unit in pairs(hero_enemies) do

                if damage > 0 then
                    if boo == 0 then
                        --emit sound if has not yet been emitted 
                        caster:EmitSound("Conquest.hallow_scream")
                    end
                    boo = 1

                    local damageTable = {
                    victim = unit,
                    attacker = caster,
                    damage = damage,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    }

                    --the damage has a delay, mostly to sync with the sound
                    Timers:CreateTimer(0.8, function ()
                        ApplyDamage(damageTable)
                    end)
                end

 	   		end

            --do the same for creeps
 	   		for _,unit in pairs(creep_enemies) do

                if damage > 0 then
                    if boo == 0 then
                        caster:EmitSound("Conquest.hallow_scream")
                    end
                    boo = 1

                    local damageTable = {
                    victim = unit,
                    attacker = caster,
                    damage = damage,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    }

                    Timers:CreateTimer(0.8, function ()
                        ApplyDamage(damageTable)
                    end)
                end

 	  		end

   		else
            --if not seen...
   			local max_charges
            --set max charges variables based on whether the Horror has a Scepter
			if caster:HasScepter() then
    			max_charges = 20
    		else
    			max_charges = 10
    		end

    		if charges < max_charges then
                --if not at max charges, increment a counter. 
    			caster.boo_charge_counter = caster.boo_charge_counter + 0.01
                --retrieve the counter value that should trigger a charge increment 
    			local charge_grant = ability:GetLevelSpecialValueFor("chargegrant", (ability:GetLevel() - 1))

                --adjust for cooldown reduction if necessary using 1-second cooldown algorithm
                local transchars = caster:FindAbilityByName("horror_lastspell")
                transchars:EndCooldown()
                transchars:UseResources(false,false,true)
                local cooltest = transchars:GetCooldownTime()
                charge_grant = charge_grant*cooltest

                --if the counter should trigger a charge increment, 
    			if caster.boo_charge_counter >= charge_grant then
                    --reset counter 
    				caster.boo_charge_counter = 0
                    --increment charges 
    				caster.boo_charges = caster.boo_charges + 1
    				--adjust display
                    caster:SetModifierStackCount("modifier_boo_charges", ability, caster.boo_charges )
    			end
    		end
    	end
    else
    	print('Terrify not initalized yet.')
    end
end


