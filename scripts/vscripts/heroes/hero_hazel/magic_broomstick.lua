--[[Author: TheGreatGimmick
    Date: Jan 15, 2017
    Allows exceeding the movement speed cap and removes Magic Broomstick if Hazel takes too much damage.]]

-- Allow Hazel to exceed movement the speed cap. Initialize health-checker variable. 
function ExceedMoveCap( event )
    -- Variables
    local caster = event.caster


    caster:AddNewModifier(caster, nil, "modifier_bloodseeker_thirst", { duration = 90 })

    local health = (caster:GetHealth())/(caster:GetMaxHealth())
    caster.health_1 = health

    if caster.broomstick and not caster.broomstick:IsNull() then 
    	caster.broomstick:RemoveSelf()
    	--caster.broomstick = nil 
    end 
    local position = caster:GetAbsOrigin()
    caster.broomstick = CreateUnitByName("hazel_broom", position, false, caster, caster, caster:GetTeam())
    caster.broomstick:FindAbilityByName("hazel_broom_passive"):SetLevel(1)

end

--Check if Hazel has taken too much damage, and if so, remove Magic Broomstick and breifly stun her.
function KnockOff(event)
    local caster = event.caster
    local ability = event.ability

    local health_prcnt = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() - 1))
    local health_2 = (caster:GetHealth())/(caster:GetMaxHealth())
    local health_1 = caster.health_1
    local max_health = caster:GetMaxHealth()

    local point = caster:GetAbsOrigin()

    if (health_1-health_2) > (health_prcnt/100) then
        caster:RemoveModifierByName("modifier_bloodseeker_thirst")
        caster:RemoveModifierByName("modifier_flying_broom")
        caster:AddNewModifier(caster, nil, "modifier_stunned", { duration = 0.6 })
    else
    	local vision = 800

    	local talent_name = "special_bonus_unique_hazel"
    	if caster:HasAbility(talent_name) then
    		local talent_level = caster:FindAbilityByName(talent_name):GetLevel()
    		if talent_level > 0 then
    			vision = vision + 600
    		end
    	end

        AddFOWViewer(caster:GetTeamNumber(), point, vision, 0.01, false)
        if not caster.broomstick:IsNull() then 
        	local fv = (caster:GetForwardVector())
        	caster.broomstick:SetAbsOrigin((point + Vector(0,0,225))-fv*60)
        	caster.broomstick:SetForwardVector(fv*-1)

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
	        local see_caster = caster.vision_checker:CanEntityBeSeenByMyTeam(caster)
	        if not see_caster then
	        	ability:ApplyDataDrivenModifier(caster, caster.broomstick, "modifier_invisible_broom", { duration = 0.01 })
	        end

    	end 
    end

    caster.health_1 = health_2

end

function BroomShed(event)
	local caster = event.caster
	if caster.broomstick then 
		caster.broomstick:RemoveSelf()
    end 
end