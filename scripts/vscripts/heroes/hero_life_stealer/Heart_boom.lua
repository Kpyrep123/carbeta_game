function heartBoom( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local int_caster = caster:GetMaxHealth()
    local int_damage = ability:GetLevelSpecialValueFor("hp_damage", (ability:GetLevel() -1)) 
    if caster:PassivesDisabled() then return end
    if target:IsMagicImmune() then return end
    if caster:IsIllusion() then return end
    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = int_caster * int_damage / 100

    ApplyDamage(damage_table)

end


function heartBoomSmall( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    if caster:PassivesDisabled() then return end
    if target:IsMagicImmune() then return end
    if caster:IsIllusion() then return end
    local int_caster = caster:GetHealth()
    local int_damage = ability:GetLevelSpecialValueFor("hp_damage_small", (ability:GetLevel() -1)) + caster:GetTalentValue("special_bonus_unique_ghoul_1")
    

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = int_caster * int_damage / 100

    ApplyDamage(damage_table)

end

function ULT( keys )
    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    caster:PerformAttack(target, true, true, true, true, false, false, true)

end

function ULTself( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local int_caster = caster:GetMaxHealth()
    local int_damage = ability:GetLevelSpecialValueFor("damage_self", (ability:GetLevel() -1)) 
    

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = caster

    damage_table.damage = int_caster * int_damage / 100

    ApplyDamage(damage_table)

end