--[[Glaives of Wisdom intelligence to damage
    Author: chrislotix
    Date: 10.1.2015.]]

function DtD( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    if caster:HasAbility("special_bonus_lanaya_unquie_1") and caster:FindAbilityByName("special_bonus_lanaya_unquie_1"):GetLevel() > 0 then
    local int_caster = caster:GetAttackDamage()
    local int_damage = ability:GetLevelSpecialValueFor("Attack_damage", (ability:GetLevel() -1)) 
    
    

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = int_caster * int_damage / 100

    ApplyDamage(damage_table)

else 
    return nil
end
end