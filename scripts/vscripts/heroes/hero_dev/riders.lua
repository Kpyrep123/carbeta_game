if IsServer() then
	require('abilities/life_in_arena/utils')
end
--Author: Pizzalol, Noya, Ractidous
function SpawnIllusions( keys )
	local caster = keys.caster
	local player = caster:GetPlayerID()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level) + caster:GetTalentValue("special_bonus_unquie_apoc_ride_dur")
	local unit_name = caster:GetUnitName()
	local images_count = ability:GetLevelSpecialValueFor( "illusions_count", ability_level ) + caster:GetTalentValue("spec_ck_ill_count")
	local outgoingDamage = ability:GetLevelSpecialValueFor( "illusions_damage_out", ability_level ) + caster:GetTalentValue("spec_ck_ill_dmg")
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusions_damage_in", ability_level )
	local casterOrigin = caster:GetAbsOrigin()
	local casterAngles = caster:GetAngles()
	if not caster.phantasm_illusions then
		caster.phantasm_illusions = {}
	end
	caster:Stop()
	local vRandomSpawnPos = {
		Vector( 0, 200, 0 ),
		Vector( 0, -200, 0 ),
		Vector( 0, 400, 0 ),
		Vector( 0, -400, 0 ),
		Vector( 0, 600, 0 ),
		Vector( 0, -600, 0 ),
		Vector( 200, 200, 0 ),
		Vector( -200, 200, 0 ),
		Vector( 200, -200, 0 ),
		Vector( 400, 400, 0 ),
		Vector( 400, -400, 0 ),
		Vector( -400, 400, 0 ),
	}
	for i=#vRandomSpawnPos, 2, -1 do	-- Simply shuffle them
		local j = RandomInt( 1, i )
		vRandomSpawnPos[i], vRandomSpawnPos[j] = vRandomSpawnPos[j], vRandomSpawnPos[i]
	end
	table.insert( vRandomSpawnPos, RandomInt( 1, images_count+1 ), Vector( 0, 0, 0 ) )
	FindClearSpaceForUnit( caster, casterOrigin + table.remove( vRandomSpawnPos, 1 ), true )
	for i=1, images_count do
		local origin = casterOrigin + table.remove( vRandomSpawnPos, 1 )
		local illusion = CreateIllusion(caster,caster,origin,duration,outgoingDamage,incomingDamage)
		illusion:SetAngles( casterAngles.x, casterAngles.y, casterAngles.z )
		illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
		local run = illusion:FindAbilityByName("discord_reality_rift")
		if run then
			run:EndCooldown()
			illusion:CastAbilityNoTarget(run, player)
			StartAnimation(illusion, {duration= duration, activity=ACT_DOTA_RUN, rate=1.0})
		end
	end
end

function Ride(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier
	local ability_level = ability:GetLevel() - 1
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level) + 1 + caster:GetTalentValue("special_bonus_unquie_apoc_ride_dur")
	ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
end