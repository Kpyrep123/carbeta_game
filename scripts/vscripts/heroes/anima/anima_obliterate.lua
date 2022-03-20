function ShootProjectiles(keys)
	local caster = keys.caster
	local ability = keys.ability
	local search_range = ability:GetSpecialValueFor("search_range")
	local impact_damage = ability:GetSpecialValueFor("hit_damage")
	local projectiles_shot = ability:GetSpecialValueFor("projectiles_per_tick")
	
	local targetTeam = ability:GetAbilityTargetTeam()
	local targetType = ability:GetAbilityTargetType()
	local targetFlag = DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
	
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, search_range, targetTeam, targetType, targetFlag, FIND_CLOSEST, false
	)
	
	-- Seek out target
	local count = 0
	for k, v in pairs( units ) do
		if count < projectiles_shot then
			local projTable = {
				Target = v,
				Source = caster,
				Ability = ability,
				EffectName = "particles/animasearchobliterate_particles/anima_search_obliterate.vpcf",
				bDodgeable = true,
				bProvidesVision = false,
				iMoveSpeed = 800, 
				--iSourceAttachment = "attach_origin",
				vSpawnOrigin = caster:GetAbsOrigin()
			}
			ProjectileManager:CreateTrackingProjectile( projTable )
			count = count + 1
		else
			break
		end
	end
end