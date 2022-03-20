

function IntToDamage( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local int_caster = caster:GetStrength()
    local str_damage = ability:GetLevelSpecialValueFor("str_damage_pct", (ability:GetLevel() -1)) 
        
    if caster:HasScepter() then

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = int_caster * str_damage / 100

    ApplyDamage(damage_table)

    else
    return nil
end
end