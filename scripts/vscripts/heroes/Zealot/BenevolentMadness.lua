function selfdamage( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local int_caster = target:GetMaxHealth()
    local int_damage = ability:GetLevelSpecialValueFor("pct", (ability:GetLevel() -1)) + caster:GetTalentValue("special_bonus_unquie_madness")
    

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = int_caster * int_damage / 1000

    ApplyDamage(damage_table)
    if caster:HasShard() then
    	target:Purge(false, true, false, true, false)
    end
end

function SpellImunity( keys )
        local target = keys.target
        local caster = keys.caster
        local ability = keys.ability
        local ability_level = ability:GetLevel() - 1

        if caster:HasTalent("special_bonus_unquie_madness_bkb") then
            ability:ApplyDataDrivenModifier(caster, target, "midifier_spell_imunity_madness", {Duration = 1.75})
        end
end