if arbalest == nil then
	arbalest = class({})
end
LinkLuaModifier( "arbalest_attack_dummy", "heroes/hero_skoros/modifiers/arbalest_attack_dummy.lua" ,LUA_MODIFIER_MOTION_NONE )


--[[function SwapSpells (keys)
	local caster = keys.caster
	caster.spellowner = caster
	local ability = keys.ability
	mainability = ability:GetAbilityName()
	sub_ability_name = keys.sub_ability_name
	caster.spellowner:SwapAbilities(mainability, sub_ability_name, false, true)
end

function SwapSpellsBack (keys)
	local caster = keys.target
	caster.spellowner:Stop()
	caster.spellowner:SwapAbilities(mainability, sub_ability_name, true, false)
end]]


--[[function CreateMarker(keys)
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability
	global_point = point
	ability:EndCooldown()

	local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)	
	for _,unit in pairs(units) do
		if unit and unit:GetUnitName() == caster:GetUnitName() and unit:GetPlayerID() == caster:GetPlayerID() then
			if unit:HasModifier("arbalest_dummy") then
				unit:RemoveModifierByName("arbalest_dummy")
			end
		end
	end

	if not caster:HasModifier("Arbalest") and not caster:HasModifier("nexus_super_illusion") then
		ability:ApplyDataDrivenModifier(caster, caster, "Arbalest", {Duration = ability:GetDuration()})
	end
	if not caster:HasModifier("arbalest_dummy") then
		ability:ApplyDataDrivenModifier(caster, caster, "arbalest_dummy", {Duration = ability:GetDuration()})
	end

	if arbalest_mark then 
		if caster:HasModifier("Arbalest") then
			arbalest_mark:SetAbsOrigin(global_point)
		end
	else
		arbalest_mark = CreateModifierThinker( caster, nil, "modifier_arbalest_mark", {Duration = ability:GetDuration()}, global_point, caster:GetTeamNumber(), true)
	end
	Timers:CreateTimer(0.1, function() 
		if particle then ParticleManager:DestroyParticle(particle,true) end
		if arbalest_mark then
			particle = ParticleManager:CreateParticleForPlayer("particles/newplayer_fx/npx_moveto_arrow.vpcf",PATTACH_OVERHEAD_FOLLOW, arbalest_mark, PlayerResource:GetPlayer( caster:GetPlayerID() ))
		end
	end)
end]]

--[[function CheckAttack(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local arbalest_attack = caster:FindAbilityByName("skoros_Arbalest_Attack")
	if arbalest_attack then
		local penalty = (ability:GetSpecialValueFor("attackspeed_penalty")/100) + 1
		arbalest_attack:SetOverrideCastPoint(penalty)
	end
	if arbalest_mark and arbalest_attack:IsCooldownReady() and result_angle < 90 then
		ability:ApplyDataDrivenModifier(caster, caster, "arbalest_attack_animation", {Duration = 0.2})
		caster:CastAbilityOnPosition(global_point, arbalest_attack, caster:GetPlayerID())
	end
end]]

function ApplyArbalestDummy(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local charges = ability:GetSpecialValueFor("charges")

	if caster:HasModifier("Arbalest") then
		caster:SetModifierStackCount("Arbalest",ability,charges)
	end

	local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)	
	for _,unit in pairs(units) do
		if unit:GetUnitName() == caster:GetUnitName() and unit:GetPlayerID() == caster:GetPlayerID() and unit:HasModifier("nexus_super_illusion") then
			ability:ApplyDataDrivenModifier(unit,unit,"Arbalest",{})
			unit:SetModifierStackCount("Arbalest",ability,charges)
			ability:ApplyDataDrivenModifier(unit,unit,"arbalest_dummy",{})
		end
	end
end

function RemoveArbalestDummy(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if not caster:IsAlive() then return end

	local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)	
	for _,unit in pairs(units) do
		if unit:GetUnitName() == caster:GetUnitName() and unit:GetPlayerID() == caster:GetPlayerID() then
			unit:RemoveModifierByName("Arbalest")
			unit:RemoveModifierByName("arbalest_dummy")
		end
	end
end

function ArbalestCooldown(keys)
	local caster = keys.caster
	local ability = keys.ability
	local attackSpeed = caster:GetSecondsPerAttack()

	local penalty = (ability:GetLevelSpecialValueFor("attackspeed_penalty", ability:GetLevel() - 1)/100) + 1

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_arbalest_timer", {Duration = attackSpeed * penalty})
end

--[[function RemoveArbalest(keys)
	local caster = keys.caster
	local ability = keys.ability

	if arbalest_mark then 
		arbalest_mark:RemoveSelf()
		arbalest_mark = nil
	end
	if particle then ParticleManager:DestroyParticle(particle,true) end
	local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)	
	for _,unit in pairs(units) do
		if unit:GetUnitName() == caster:GetUnitName() and unit:GetPlayerID() == caster:GetPlayerID() then
			if unit:HasModifier("arbalest_dummy") then
				unit:RemoveModifierByName("arbalest_dummy")
			end
			if unit:HasModifier("Arbalest") then
				unit:RemoveModifierByName("Arbalest")
			end
		end
	end
	ability:StartCooldown(ability:GetCooldown(ability:GetLevel() - 1))
end]]

function projectilehit (keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local vision = ability:GetSpecialValueFor("target_vision_radius")
	local duration = ability:GetSpecialValueFor("target_vision_duration")

	caster:PerformAttack( target, true, true, true, false, false )
	AddFOWViewer(caster:GetTeamNumber(),target:GetAbsOrigin(), vision , duration, true)
end

function DONTATTACK (keys)
	local caster = keys.caster
	local ability = caster:FindAbilityByName("skoros_Arbalest_Attack")
	local target = keys.target
	local modifier = caster:FindModifierByName("skoros_Arbalest")
	caster:Stop()
end

function arbalest( filterTable )
	local units = filterTable["units"]
	local issuer = filterTable["issuer_player_id_const"]
	local order_type = filterTable["order_type"]
	local abilityIndex = filterTable["entindex_ability"]
	local ability = EntIndexToHScript(abilityIndex)
	local targetIndex = filterTable["entindex_target"]


	local attacker = EntIndexToHScript(units["0"])
	if not IsValidEntity(attacker) then return false end

	if order_type == DOTA_UNIT_ORDER_ATTACK_MOVE then
		local arbalest_attack = attacker:FindAbilityByName("skoros_Arbalest_Attack_lua")
		if arbalest_attack and attacker:HasModifier("arbalest_dummy") and arbalest_attack:IsCooldownReady() and attacker:AttackReady() and not attacker:IsDisarmed() then
			filterTable["order_type"] = DOTA_UNIT_ORDER_CAST_POSITION
			filterTable["entindex_ability"] = arbalest_attack:entindex()
		end
	elseif order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
		local target = EntIndexToHScript(targetIndex)
		local distance = (target:GetAbsOrigin() - attacker:GetAbsOrigin()):Length2D() - 64
		
		local arbalest_attack = attacker:FindAbilityByName("skoros_Arbalest_Attack_lua")
		if arbalest_attack and attacker:HasModifier("arbalest_dummy") and arbalest_attack:IsCooldownReady() and attacker:AttackReady() and not attacker:IsDisarmed() and distance > attacker:GetAttackRange() then
			if not target:IsBuilding() then 
				filterTable["order_type"] = DOTA_UNIT_ORDER_CAST_TARGET
				filterTable["entindex_ability"] = arbalest_attack:entindex()
			end
		end
	end

	return true
end