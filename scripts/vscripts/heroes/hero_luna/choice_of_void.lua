
function choice_of_void( keys )
 local caster = keys.caster
 local target = keys.target
 local ability = keys.ability
 local abs = target:GetAbsOrigin()
local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1)) + caster:GetTalentValue("special_bonus_unquie_astral_dur")
    if target:TriggerSpellAbsorb(ability) then
        RemoveLinkens(target)
        return
    else 

        if target:HasModifier("modifier_void_hit") then
            ability:ApplyDataDrivenModifier(caster, target, "modifier_astral_imprisonment_datadriven", {duration = duration* (1- target:GetStatusResistance())})
            target:RemoveModifierByName("modifier_void_hit")
        else
            ability:ApplyDataDrivenModifier(caster, target, "modifier_etherial", {duration = duration* (1- target:GetStatusResistance())})

        end
    end
end

function astral_damage( keys )
     local caster = keys.caster
     local target = keys.target
     local ability = keys.ability
     local ability_level = ability:GetLevel() - 1
     local count = caster:GetModifierStackCount("modifier_warpath_datadriven_counter", caster) * (ability:GetLevelSpecialValueFor("damage_per_stack", ability_level) + caster:GetTalentValue("special_bonus_unquie_astral_damage"))
    local base_damage = ability:GetLevelSpecialValueFor("base_damage", ability_level)
    if caster:HasModifier("modifier_warpath_datadriven_counter") then

     local damage_table = {}


    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = count + base_damage

    ApplyDamage(damage_table)
    local stackssb = caster:FindModifierByName("modifier_warpath_datadriven_counter")
    local x = caster:GetModifierStackCount("modifier_warpath_datadriven_counter", ability)
    caster:SetModifierStackCount("modifier_warpath_datadriven_counter", ability, x * 0.8)
else
        local damage_table = {}
    
        damage_table.attacker = caster
        damage_table.damage_type = ability:GetAbilityDamageType()
        damage_table.ability = ability
        damage_table.victim = target
    
        damage_table.damage = base_damage
    
        ApplyDamage(damage_table)
end
end