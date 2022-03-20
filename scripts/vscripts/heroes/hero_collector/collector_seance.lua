--[[Author: TheGreatGimmick
    Date: Mar 18, 2017
    Collector's R, Seance
 ]]

-- Revive the most recently dead allied hero, and apply the leash modifier 
function Revive( event )
	local caster = event.caster
	local ability = event.ability 

	local origin = caster:GetAbsOrigin()
	local point = event.target_points[1]

	local castteam = caster:GetTeamNumber()
	local spirit = caster:FindModifierByName("modifier_collector_lastdeath"):RequestLastDeath()

	print("SPIRIT")
	print(spirit)
	print("SPIRIT")

--[[
	if castteam == 2 then
		spirit = _G.RadiantMostRecentDeath
		print("Summoning Radiant hero")
    else
    	if castteam == 3 then
    		spirit = _G.DireMostRecentDeath
    		print("Summoning Radiant hero")
        end
    end
]]
    if spirit --[[and spirit ~= caster]] then
    	caster.seance_summon = spirit
    	if spirit:IsAlive() then
    		caster.seance_respawn_start = 0
    		caster.seance_time_start = GameRules:GetGameTime()
    		--teleport to location
    		spirit:SetAbsOrigin(point) --We move the summon instantly to the location
    		FindClearSpaceForUnit(spirit, point, false) --This makes sure our caster does not get stuck
    		--apply leash modifier
    		ability:ApplyDataDrivenModifier(caster, spirit, "modifier_seance_spirit", {})
    		--play teleport sound

    	else
    		--get respawn time remaining
    		Timers:CreateTimer(0.1, function ()
    			caster.seance_respawn_start = spirit:GetTimeUntilRespawn()
    		end)
    		--get time of seance cast
    		caster.seance_time_start = GameRules:GetGameTime()
    		--respawn
			spirit:RespawnHero(false, false, false)
			EmitGlobalSound("Conquest.Stinger.HulkCreep")
    		--teleport to location
    		spirit:SetAbsOrigin(point) --We move the summon instantly to the location
    		FindClearSpaceForUnit(spirit, point, false) --This makes sure our caster does not get stuck
    		--apply leash modifier
    		ability:ApplyDataDrivenModifier(caster, spirit, "modifier_seance_spirit", {})
    		--play revival sound

    	end
    else
    	caster:EmitSound("lich_lich_ability_failure_05")
    	print("Not my best work!")
    	caster:AddNewModifier(caster, nil, "modifier_stunned", { duration = 0.01 })
    end
end

--Manage respawn times and death/life of Seance-spawned Hero
function RIP( event )
	local caster = event.caster
	caster:AddNewModifier(caster, nil, "modifier_stunned", { duration = 0.01 })

	local spirit = caster.seance_summon

	if spirit then 
		local respawn_remaining = caster.seance_respawn_start
		local respawn_time = caster.seance_time_start

		local current_time = GameRules:GetGameTime()

		local elapsed_time = current_time - respawn_time
		local time_until_respawn = respawn_remaining - elapsed_time

		spirit:RemoveModifierByName("modifier_seance_spirit")

		if time_until_respawn > 0 then
			spirit:SetTimeUntilRespawn(time_until_respawn)
			spirit:ForceKill(true)
		end
	end
end

--Manage Seance leash
function Leash( event )
	local caster = event.caster
	local ability = event.ability 

	local spirit = caster.seance_summon

	local seance_center = caster:GetAbsOrigin()
	local spirit_location = spirit:GetAbsOrigin()

	local leash_radius = ability:GetLevelSpecialValueFor("leash", (ability:GetLevel() - 1))

	local dist_check = seance_center - spirit_location
	dist_check = dist_check:Length2D()

	if dist_check > leash_radius then
    	local leash_point = seance_center + (spirit_location - seance_center):Normalized() * leash_radius
    	spirit:SetAbsOrigin(leash_point) --We move the summon instantly to the location
    	FindClearSpaceForUnit(spirit, leash_point, false) --This makes sure our caster does not get stuck
    end
end

--Aghs cooldown functionality
function AghsDeath( event )
	local caster = event.caster
	if caster:HasScepter() then 
		for c = 0, 15, 1 do
			local ability = caster:GetAbilityByIndex(c)
	   	  	if ability then
	   	  		ability:EndCooldown()
	   	  	end
	   	end

	   	for i = 0, 14, 1 do
	        local current_item = caster:GetItemInSlot(i)
	        if current_item then
	   	  		current_item:EndCooldown()
	   	  	end
	   	end
	end
end

