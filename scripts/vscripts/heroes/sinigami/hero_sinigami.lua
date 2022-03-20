function SoulSteal( keys )
	-- body
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local target_hp = target:GetHealth()
	local dmg_pct = ability:GetLevelSpecialValueFor("damage", ability_level) + caster:GetTalentValue("special_bonus_unquie_abba_soul_steal")
	local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = target_hp * dmg_pct / 100

    ApplyDamage(damage_table)
    local heal = target_hp * dmg_pct / 100
    if target:IsRealHero() then
    caster:Heal(heal, caster)
else
	local creep_heal = heal * 0.5
	caster:Heal(creep_heal, caster)
end
end


function SoulStealScepter( keys )
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability

	local ability_level = ability:GetLevel() - 1
		if caster:HasScepter() then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_pter", {Duration = 0.0001})
		end
end

function SoulPTER( keys )
	-- body
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local target_hp = target:GetHealth()
	local dmg_pct = ability:GetLevelSpecialValueFor("damage", ability_level) + caster:GetTalentValue("special_bonus_unquie_abba_soul_steal")
	local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = target_hp * dmg_pct / 2 / 100

    ApplyDamage(damage_table)
    local heal = target_hp * dmg_pct / 2 / 100
    if target:IsRealHero() then
    	caster:Heal(heal, caster)
	else
		local creep_heal = heal * 0.5
		caster:Heal(creep_heal, caster)
	end
end
