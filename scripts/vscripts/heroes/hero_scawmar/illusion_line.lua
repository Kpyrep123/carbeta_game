if IsServer() then
	require('abilities/life_in_arena/utils')
end
function CreateIllusions( keys )
	local caster = keys.caster
	local ability = keys.ability
	local player = caster:GetPlayerID()
	local point = keys.target_points[1]
	
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1 ) + caster:GetTalentValue("special_bonus_unique_hildrin_ill_dur")
	local delay = ability:GetLevelSpecialValueFor("illusion_delay", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor("incoming_damage", ability:GetLevel() - 1 ) + caster:GetTalentValue("special_bonus_unique_hildrin_ill_in")
	local outgoingDamage = ability:GetLevelSpecialValueFor("outgoing_damage", ability:GetLevel() - 1 ) + caster:GetTalentValue("special_bonus_unique_hildrin_ill_out")
	
	local origin = caster:GetAbsOrigin()
	local forwardVec = caster:GetForwardVector()
	local distance = (point - origin):Length2D()
	local location = origin + forwardVec * distance
	local sideVec = caster:GetRightVector()

	local randomPos = RandomInt(1,5)
	if caster:HasModifier("modifier_spirit_realm") then randomPos = 0 end

	local vec = {}

	vec[0] = origin
	vec[1] = location + sideVec * 350
	vec[2] = location + sideVec * 175
	vec[3] = location
	vec[4] = location + sideVec * -175
	vec[5] = location + sideVec * -350

	local casterVec = vec[randomPos]

	ProjectileManager:ProjectileDodge(caster)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_fire_spawn", {})

	local projectiles = {}

	for i = 1, 5 do
		distance = (vec[i] - origin):Length2D() + 0.1
		vector = (vec[i] - origin):Normalized()
		speed = distance / delay
		local projectileTable =
		{
			EffectName = "particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant_trail.vpcf",
			Ability = ability,
			vSpawnOrigin = origin,
			vVelocity = Vector( vector.x * speed, vector.y * speed, 0 ),
			fDistance = distance,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
		}

		projectiles[i] = ProjectileManager:CreateLinearProjectile(projectileTable)

	end


	caster:AddNoDraw()
	caster:AddNewModifier(caster, ability, "modifier_disabled_invulnerable", {Duration = delay})
	caster:AddNewModifier(caster, ability, "modifier_disarmed", {Duration = delay})

	FindClearSpaceForUnit(caster, casterVec, false) 

	local illusion = {}

	Timers:CreateTimer(delay, function()
		caster:RemoveNoDraw()
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_fire_spawn", {})
		if not caster:IsChanneling() then
			caster:MoveToPositionAggressive(casterVec)
		end
		
		for j = 1, 5 do
			if randomPos ~= j then
				illusion[j] = CreateIllusion(caster,caster,origin,duration,outgoingDamage,incomingDamage)
				illusion[j]:SetControllableByPlayer(player, true)
				FindClearSpaceForUnit(illusion[j], vec[j], false) 
				illusion[j]:SetForwardVector(forwardVec)
				ability:ApplyDataDrivenModifier(caster, illusion[j], "modifier_fire_spawn", {})


				-- Set the skill points to 0 and learn the skills of the caster

				illusion[j]:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
				ability:ApplyDataDrivenModifier(caster, illusion[j], "modifier_fire_spawn", {})
				if caster:HasTalent("special_bonus_unique_hildrin_control_dur") then 
					ability:ApplyDataDrivenModifier(caster, illusion[j], "modifier_not_collsiion", {})
				end
				illusion[j]:MakeIllusion()

				illusion[j]:EmitSound("Hero_Jakiro.LiquidFire")
			end
		end

	end)
end

function purge( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	target:Purge(true,false,false,false,false)
end