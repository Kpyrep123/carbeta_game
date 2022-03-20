if IsServer() then
	require('abilities/life_in_arena/utils')
end

function LevelUpAbility( keys )
	local caster = keys.caster
	local ability = keys.ability
end

function ScryerProjectiles( keys )
	local caster = keys.caster
	local player = caster:GetPlayerID()
	local ability = keys.ability
	local unit_name = caster:GetUnitName()
	local images_count = ability:GetLevelSpecialValueFor("illusion_count", ability:GetLevel() - 1 ) + caster:GetTalentValue("special_bonus_unique_hildrin_circle_count")
	local duration = ability:GetLevelSpecialValueFor( "fire_bomb_delay", ability:GetLevel() - 1 ) + 0.5
	local outgoingDamage = -100
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_damage_taken", ability:GetLevel() - 1 ) + caster:GetTalentValue("special_bonus_unique_hildrin_circle_in")
	local spawnRadius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local delay = ability:GetLevelSpecialValueFor( "spawn_delay", ability:GetLevel() - 1 )

	local point = keys.target_points[1]
	local casterOrigin = caster:GetAbsOrigin()
	local casterForwardVec = caster:GetForwardVector()
	local rotateVar = 0
	local wave_width = 200
	ability:CreateVisibilityNode(point, spawnRadius, 1)

	-- Setup a table of projectile positions
	local vProjPos = {}
	for i=1, images_count do
		local rotate_distance = point + casterForwardVec * spawnRadius
		local rotate_angle = QAngle(0,rotateVar,0)
		rotateVar = rotateVar + 360/images_count
		local rotate_position = RotatePosition(point, rotate_angle, rotate_distance)

		local distance = (rotate_position - point):Length2D()
		local vector = (rotate_position - point):Normalized()
		local speed = distance / delay
		local projectileTable =
		{
			EffectName = "particles/econ/items/magnataur/shock_of_the_anvil/magnataur_shockanvil.vpcf",
			Ability = ability,
			vSpawnOrigin = point,
			vVelocity = Vector( vector.x * speed, vector.y * speed, 0 ),
			fStartRadius = wave_width,
			fEndRadius = wave_width,
			fDistance = distance,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
		}

		vProjPos[i] = ProjectileManager:CreateLinearProjectile(projectileTable)
	end
end



function CreateScryerIllusions( keys )
	local caster = keys.caster
	local player = caster:GetPlayerID()
	local ability = keys.ability
	local unit_name = caster:GetUnitName()
	local images_count = ability:GetLevelSpecialValueFor("illusion_count", ability:GetLevel() - 1 ) + caster:GetTalentValue("special_bonus_unique_hildrin_circle_count")
	local duration = ability:GetLevelSpecialValueFor( "fire_bomb_delay", ability:GetLevel() - 1 ) + 0.4
	local outgoingDamage = -100
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_damage_taken", ability:GetLevel() - 1 ) + caster:GetTalentValue("special_bonus_unique_hildrin_circle_in")
	local spawnRadius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )

	local point = keys.target_points[1]
	local casterOrigin = caster:GetAbsOrigin()
	local casterForwardVec = caster:GetForwardVector()
	local rotateVar = 0

	-- Setup a table of potential spawn positions
	local vSpawnPos = {}
	for i=1, images_count do
		local rotate_distance = point + casterForwardVec * spawnRadius
		local rotate_angle = QAngle(0,rotateVar,0)
		rotateVar = rotateVar + 360/images_count
		local rotate_position = RotatePosition(point, rotate_angle, rotate_distance)
		table.insert(vSpawnPos, rotate_position)
	end
	

	-- Spawn illusions
	for j=1, images_count do
		local origin = table.remove( vSpawnPos, 1 )
		local illusionForwardVec = (point - origin):Normalized()

		-- handle_UnitOwner needs to be nil, else it will crash the game.
		local illusion = CreateIllusion(caster,caster,origin,outgoingDamage,incomingDamage)
		illusion:SetControllableByPlayer(player, false)

		illusion:SetForwardVector(illusionForwardVec)
		


		-- Set the unit as an illusion
		-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
		illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
		
		-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
		illusion:MakeIllusion()
		-- Sets the illusion to begin channeling Fire Bomb
		local abilitySec = illusion:AddAbility("scryer_fire_bomb")
		abilitySec:SetLevel(ability:GetLevel())
		Timers:CreateTimer( 0.035, function() 
			illusion:CastAbilityOnPosition(point, abilitySec, illusion:GetPlayerID() )
			if caster:HasScepter() then 
					local target_teams = DOTA_UNIT_TARGET_TEAM_FRIENDLY
					local target_types = DOTA_UNIT_TARGET_HERO
					local target_flags = DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED
					local illusion_search_radius = 900
				units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, illusion_search_radius, target_teams, target_types, target_flags, FIND_CLOSEST, false)
				

				for _,unit in ipairs(units) do
				if unit:IsIllusion() and unit:GetPlayerOwnerID() == player then
					-- Do the same thing that we did for the caster
					-- Relocate and set the illusion to face the target
					local abilitySec = unit:AddAbility("scryer_fire_bomb")
					abilitySec:SetLevel(ability:GetLevel())
					-- Add the phased and reality rift modifiers
					unit:AddNewModifier(caster, nil, "modifier_phased", {duration = 0.03})
					unit:CastAbilityOnPosition(point, abilitySec, illusion:GetPlayerID() )
					-- Execute the attack order
					Timers:CreateTimer(3.4, function()
					unit:ForceKill(true)
					caster:FindAbilityByName("scawmar_illusion_line"):ReduceCooldown(21)
					if caster:HasItemInInventory("item_manta") then 
						caster:FindItemInInventory("item_manta"):ReduceCooldown(30)
					end
					end)
					
				end
			end	

			end
		end)
	end
end


function scepter( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor( "fire_bomb_delay", ability:GetLevel() - 1 )
	if caster:HasScepter() then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_scepter_circle", {duration = duration})
	end
end
