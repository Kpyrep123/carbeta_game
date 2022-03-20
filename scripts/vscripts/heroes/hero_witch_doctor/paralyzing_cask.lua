--[[Author: YOLOSPAGHETTI
	Date: March 15, 2016
	Controls the coconut and its interactions with other entities (borrowed from chain frost)]]
function ParalyzingCask(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local bounce_range = ability:GetLevelSpecialValueFor("bounce_range", (ability:GetLevel() -1))
	local bounce_delay = ability:GetLevelSpecialValueFor("bounce_delay", (ability:GetLevel() -1))
	local speed = ability:GetLevelSpecialValueFor("speed", (ability:GetLevel() -1))
	local hero_duration = ability:GetLevelSpecialValueFor("hero_duration", (ability:GetLevel() -1)) + caster:GetTalentValue("special_bonus_unquie_cask_stun_dur")
	local creep_duration = ability:GetLevelSpecialValueFor("creep_duration", (ability:GetLevel() -1)) + caster:GetTalentValue("special_bonus_unquie_cask_stun_dur")
	local hero_damage = ability:GetLevelSpecialValueFor("hero_damage", (ability:GetLevel() -1)) + caster:GetTalentValue("spec_bolt_damage")
	local creep_damage = ability:GetLevelSpecialValueFor("creep_damage", (ability:GetLevel() -1)) + caster:GetTalentValue("spec_bolt_damage")
		if target:TriggerSpellAbsorb(ability) then
			RemoveLinkens(target)
			return
		end
	-- Determines the number of bounces the cask has left
	if ability.bounces_left == nil then
		ability.bounces_left = ability:GetLevelSpecialValueFor("bounces", (ability:GetLevel() -1)) + caster:GetTalentValue("spec_bolt_bounces")
	else
		ability.bounces_left = ability.bounces_left - 1
	end
	
	-- Apply the stun to the current target
	if target:IsHero() then
		target:AddNewModifier(target, ability, "modifier_stunned", {Duration = hero_duration * (1 - target:GetStatusResistance())})
		ApplyDamage({victim = target, attacker = caster, damage = hero_damage, damage_type = ability:GetAbilityDamageType()})
	else
		target:AddNewModifier(target, ability, "modifier_stunned", {Duration = creep_duration * (1 - target:GetStatusResistance())})
		ApplyDamage({victim = target, attacker = caster, damage = creep_damage, damage_type = ability:GetAbilityDamageType()})
	end
	
	-- If the cask has bounces left, it finds a new target to bounce to

	if ability.bounces_left > 0 then
		-- We wait on the delay
		Timers:CreateTimer(bounce_delay,
		function()
			-- Finds all units in the area
			local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, bounce_range, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, 0, false)
			-- Go through the target_enties table, checking for the first one that isn't the same as the target
			local target_to_jump = nil
			for _,unit in pairs(units) do
				if unit ~= target and not target_to_jump then
					target_to_jump = unit
				end
			end
		
			-- If there is a new target to bounce to, we create the a projectile
			if target_to_jump then
				-- Create the next projectile
				local info = {
				Target = target_to_jump,
				Source = target,
				Ability = ability,
				EffectName = keys.particle,
				bDodgeable = true,
				bProvidesVision = false,
				iMoveSpeed = speed,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
				}
				ProjectileManager:CreateTrackingProjectile( info )
			else
				ability.bounces_left = nil
			end	
		end)
	else
		ability.bounces_left = nil
	end
	if caster:HasShard() then
		target:Purge(true,false,false,false,false)
		else
			return nil
		end
end
