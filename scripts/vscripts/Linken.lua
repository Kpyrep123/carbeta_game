function ApplyerLinkaLanayaSilence( keys )
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier = keys.modifier
	local duration = ability:GetLevelSpecialValueFor("debuff_duration", ability_level)
	local duration_tal = ability:GetLevelSpecialValueFor("duration", ability_level)

		if target:TriggerSpellAbsorb(ability) then
			RemoveLinkens(target)
			return
		end
		if caster:HasTalent("special_bonus_unquie_lanaya_fast") then 
			ability:ApplyDataDrivenModifier(caster, target, "modifier_last_word_disarm_datadriven", {duration = duration_tal})
		else
		ability:ApplyDataDrivenModifier(caster, target, modifier, {duration = duration})
	end
end
