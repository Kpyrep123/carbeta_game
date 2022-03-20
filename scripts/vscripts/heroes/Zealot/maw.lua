function Maw( params )
	local target = params.target
	local caster = params.caster
	local ability = params.ability
	local ability_level = ability:GetLevel() - 1
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level) + caster:GetTalentValue("special_bonus_unquie_maw_duration")
	if target:TriggerSpellAbsorb(ability) then
		RemoveLinkens(target)
		return
	else 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_gapping_maw", {Duration = duration*(1 - target:GetStatusResistance())})

	end
end

function maw_modifier( keys )
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local x = target:GetMaxHealth()
	local y = ability:GetLevelSpecialValueFor("pct", ability_level) + caster:GetTalentValue("special_bonus_unquie_maw_damage")
	local amount = x * y / 100
	local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = amount

    ApplyDamage(damage_table)
    caster:Heal(amount, caster)
end

