--[[Glaives of Wisdom intelligence to damage
    Author: chrislotix
    Date: 10.1.2015.]]

function IntToDamage( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    if caster:HasTalent("special_bonus_lanaya_unquie") then
    local int_caster = caster:GetMaxMana()
    local int_damage = ability:GetLevelSpecialValueFor("intellect_damage_pct", (ability:GetLevel() -1)) 
    

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
function IntToDamage_stomp( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1)) + caster:GetTalentValue("special_bonus_titan_spec_titan_ult_dur")
    local int_caster = caster:GetIntellect()
    local int_damage = ability:GetLevelSpecialValueFor("intellect_damage_pct", (ability:GetLevel() -1)) + caster:GetTalentValue("special_bonus_titan_spec_1")
    

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = int_caster * int_damage / 100 + 200

    ApplyDamage(damage_table)
    if caster:HasScepter() then 
        local modwithscepter = "Doom_soul"
        ability:ApplyDataDrivenModifier(caster, target, modwithscepter, { Duration = duration })
else
        local modwithoutscepter = "Soul_Shattering"
        ability:ApplyDataDrivenModifier(caster, target, modwithoutscepter, { Duration = duration })
    end
end

function sting( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local int_caster = caster:GetAgility()
    local int_damage = ability:GetSpecialValueFor("agi_damage") 
    

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = int_caster * int_damage / 100

    ApplyDamage(damage_table)

end

function stuff( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local int_caster = caster:GetIntellect()
    local int_damage = ability:GetSpecialValueFor("int_damage") 
    

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = int_caster * int_damage / 100

    ApplyDamage(damage_table)

end

function skull( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local int_caster = caster:GetStrength()
    local int_damage = ability:GetSpecialValueFor("str_damage") 
    

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = int_caster * int_damage / 100

    ApplyDamage(damage_table)

end

function razor( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local int_caster = caster:GetAttackDamage()
    local int_damage = ability:GetSpecialValueFor("damage_pct") 
    

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = int_caster * int_damage / 100
    if not target:IsBuilding() and not caster:IsIllusion() then
    ApplyDamage(damage_table)
end

end


function resonance( keys )
    local caster = keys.caster
    local ability = keys.ability
    local maxStack = ability:GetSpecialValueFor("resonance_max_stacks")
    local modifierCount = caster:GetModifierCount()
    local currentStack = 0
    local modifierBuffName = "modifier_resonence"
    local modifierStackName = "modifier_resonance_buff"
    local modifierName

    -- Always remove the stack modifier
    caster:RemoveModifierByName(modifierStackName) 

    -- Counts the current stacks
    for i = 0, modifierCount do
        modifierName = caster:GetModifierNameByIndex(i)

        if modifierName == modifierBuffName then
            currentStack = currentStack + 1
        end
    end

    -- Remove all the old buff modifiers
    for i = 0, currentStack do
        print("Removing modifiers")
        caster:RemoveModifierByName(modifierBuffName)
    end

    -- Always apply the stack modifier 
    ability:ApplyDataDrivenModifier(caster, caster, modifierStackName, {})

    -- Reapply the maximum number of stacks
    if currentStack >= maxStack then
        caster:SetModifierStackCount(modifierStackName, ability, maxStack)

        -- Apply the new refreshed stack
        for i = 1, maxStack do
            ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
        end
    else
        -- Increase the number of stacks
        currentStack = currentStack + 1

        caster:SetModifierStackCount(modifierStackName, ability, currentStack)

        -- Apply the new increased stack
        for i = 1, currentStack do
            ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
        end
    end
end

function shroud( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local int_caster = target:GetMaxHealth()
    local int_damage = ability:GetLevelSpecialValueFor("hp_damage", (ability:GetLevel() -1)) + caster:GetTalentValue("spec_puppet_healdamage")
    

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = int_caster * int_damage / 1000
 if target:IsRoshan() then
    return nil
else
    ApplyDamage(damage_table)
end

end


function shroud_shard( keys )

    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local attacker = keys.attacker
    
    local Heal_Factor = ability:GetLevelSpecialValueFor("hp_damage", (ability:GetLevel() -1)) + caster:GetTalentValue("spec_puppet_healdamage")
    local healAmount = target:GetMaxHealth() * Heal_Factor / 1000
    caster:Heal(healAmount,caster)

end

function shroud_apply( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1)) + caster:GetTalentValue("spec_puppet_shroud_dur")
    local shroud_shard_aura = "modifier_shroud_puppet_shard"
    local shroud_aura = "modifier_shroud_puppet"
    if caster:HasModifier("modifier_item_aghanims_shard") then
        ability:ApplyDataDrivenModifier(caster, target, shroud_shard_aura, { Duration = duration } )
        ability:ApplyDataDrivenModifier(caster, target, shroud_aura, { Duration = duration } )
    else
        ability:ApplyDataDrivenModifier(caster, target, shroud_aura, { Duration = duration } )
    end
end 