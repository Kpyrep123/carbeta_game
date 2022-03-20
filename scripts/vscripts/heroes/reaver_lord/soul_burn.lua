function SoulBurnStart( keys )
	local caster 		= keys.caster 
	local target 		= keys.target
	local damage 		= keys.Damage 
	local damage_pct 	= keys.DamagePct / 100

	local damage = damage_pct * target:GetMaxHealth()

	ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE })	
end
