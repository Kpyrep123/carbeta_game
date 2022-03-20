--[[Glaives of Wisdom intelligence to damage
    Author: chrislotix
    Date: 10.1.2015.]]

function IntToDamage( keys )
  
    local ability = keys.ability
    local caster = keys.caster
    local mana = caster:GetMana()
    local target = keys.target
      if not caster:HasScepter() then 
    local int_caster = caster:GetMana()
    local int_damage = ability:GetLevelSpecialValueFor("intellect_damage_pct", (ability:GetLevel() -1)) + caster:GetTalentValue("special_bonus_wisdom_attack")

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = mana * int_damage / 100

    ApplyDamage(damage_table)

else
        local ability = keys.ability
    local caster = keys.caster
    local mana = caster:GetMaxMana()
    local target = keys.target
    local int_caster = caster:GetIntellect()
    local int_damage = ability:GetLevelSpecialValueFor("intellect_damage_pct", (ability:GetLevel() -1)) + caster:GetTalentValue("special_bonus_wisdom_attack")

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = mana * int_damage / 100

    ApplyDamage(damage_table)
end
    
end
 