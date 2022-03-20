--[[Handling the stacking of Linas Fiery Soul ability
    Author: Pizzalol
    Date: 30.12.2014.]]
function FierySoul( keys )
    local caster = keys.caster
    local ability = keys.ability
    local maxStack = ability:GetLevelSpecialValueFor("str_max_stacks", (ability:GetLevel() - 1)) + caster:GetTalentValue("spec_jugg_fury")
    local modifierCount = caster:GetModifierCount()
    local currentStack = 0
    local modifierBuffName = "jugg_bonus_str"
    local modifierBuffNameShard = "jugg_bonus_str_shard"
    local modifierStackName = "modifier_fiery_soul_buff_stack_datadriven"
    local modifierName

    -- Always remove the stack modifier
    caster:RemoveModifierByName(modifierStackName) 

    -- Counts the current stacks
    for i = 0, modifierCount do
        modifierName = caster:GetModifierNameByIndex(i)
if caster:HasScepter() then
        if modifierName == modifierBuffNameShard then
            currentStack = currentStack + 1
        end
    else
        if modifierName == modifierBuffName then
            currentStack = currentStack + 1
        end
    end
end
    -- Remove all the old buff modifiers
    for i = 0, currentStack do
        print("Removing modifiers")
        if caster:HasScepter() then
            caster:RemoveModifierByName(modifierBuffNameShard)
            else
        caster:RemoveModifierByName(modifierBuffName)
    end
    end

    -- Always apply the stack modifier 
    ability:ApplyDataDrivenModifier(caster, caster, modifierStackName, {})

    -- Reapply the maximum number of stacks
    if currentStack >= maxStack then
        caster:SetModifierStackCount(modifierStackName, ability, maxStack)

        -- Apply the new refreshed stack
        for i = 1, maxStack do
            if caster:HasScepter() then
                ability:ApplyDataDrivenModifier(caster, caster, modifierBuffNameShard, {})
                else
            ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
        end
        end
    else
        -- Increase the number of stacks
        currentStack = currentStack + 1

        caster:SetModifierStackCount(modifierStackName, ability, currentStack)

        -- Apply the new increased stack
        for i = 1, currentStack do
            if caster:HasScepter() then
                ability:ApplyDataDrivenModifier(caster, caster, modifierBuffNameShard, {})
                else
            ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
        end
        end
    end
end