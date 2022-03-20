function CreatePillar( keys )
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local point = ability:GetCursorPosition()
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)

	local pillar = CreateUnitByName("stolb_1", point, false, caster, caster, caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(caster, pillar, "gemini_abyssal_vortex_mod", {Duration = duration})
	ability:ApplyDataDrivenModifier(caster, pillar, "modifier_damage", {Duration = duration})
end