function damage_absorb ( keys )
	local caster = keys.caster
	caster:ApplyDataDrivenModifier(caster, caster, "damage_absorb", {})

end

function damage_absorb_modifier:GetModifierIncomingDamage_Percentage()
	local ability = keys.ability
	local caster = keys.caster
	return ability:GetSpecialValueFor("damage_absorb") + caster:GetTalentValue("secial_bonus_resist")
end
