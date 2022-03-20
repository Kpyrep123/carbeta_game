function ApplyModf(keys)
	local ability = keys.ability
	local caster = keys.caster
	local modifier = keys.modifier
	local illusions_duration = 30.0
	local illusion_modifier = keys.illusion_modifier
	local duration = 3.0
	if caster:HasModifier("modifier_illusion") == false then
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
	else
		ability:ApplyDataDrivenModifier(caster, caster, illusion_modifier, {duration = illusions_duration})
	end

end

function RandomStun(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local stun_min = keys.min_stun
	local stun_max = keys.max_stun
	local stun = RandomFloat(stun_min, stun_max)
	local modifier = "modifier_reality_rift_stun"
	if target:HasModifier(modifier) == false then
		ability:ApplyDataDrivenModifier(caster, target, modifier, {duration = stun*(1 - target:GetStatusResistance())})
	end
end

function Run(keys)
	local ability = keys.ability
	local caster = keys.caster
	local ability_level = ability:GetLevel() - 1
	local speedPct = caster:GetIdealSpeed()
	local speedMult = ability:GetLevelSpecialValueFor("speed_multiplier", ability_level)
	local speed = ((speedPct * speedMult) + caster:GetTalentValue("special_bonus_unquie_rift_speed")) / 10000
	caster:SetAbsOrigin(caster:GetAbsOrigin() + caster:GetForwardVector() * speed)
	caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
end

function RandomDamage(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local ability_level = ability:GetLevel() - 1
	local speedPct = caster:GetIdealSpeed()
	local speedMult = ability:GetLevelSpecialValueFor("speed_multiplier", ability_level) / 100
	local speedNow = speedPct * speedMult
	local dmgmin = ability:GetLevelSpecialValueFor("dmg_min", ability_level) + caster:GetTalentValue("spec_ride_dmg")
	local dmgmax = ability:GetLevelSpecialValueFor("dmg_max", ability_level) + caster:GetTalentValue("spec_ride_dmg")
	local speedminMult = speedNow * (dmgmin / 100)
	local speedmaxMult = speedNow * (dmgmax / 100)
	local damage_min = speedminMult
	local damage_max = speedmaxMult
	local damage = RandomInt(damage_min, damage_max)
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage_type = ability:GetAbilityDamageType(), damage = damage})
	SendOverheadEventMessage(target, OVERHEAD_ALERT_DAMAGE, target, damage, caster)
end