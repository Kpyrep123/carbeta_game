--[[Handling the stacking of Linas Fiery Soul ability
    Author: Pizzalol
    Date: 30.12.2014.]]
function FierySoul( keys )
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local maxStack = ability:GetLevelSpecialValueFor("max_stacks", (ability:GetLevel() - 1))
    local modifierCount = target:GetModifierCount()
    local currentStack = 0
    local modifierBuffName = "bos_stacks"
    local modifierStackName = "modifier_bos_slow"
    local modifierName

    -- Always remove the stack modifier
    target:RemoveModifierByName(modifierStackName) 

    -- Counts the current stacks
    for i = 0, modifierCount do
        modifierName = target:GetModifierNameByIndex(i)

        if modifierName == modifierBuffName then
            currentStack = currentStack + 1
        end
    end

    -- Remove all the old buff modifiers
    for i = 0, currentStack do
        print("Removing modifiers")
        target:RemoveModifierByName(modifierBuffName)
    end

    -- Always apply the stack modifier 
    ability:ApplyDataDrivenModifier(target, target, modifierStackName, {})

    -- Reapply the maximum number of stacks
    if currentStack >= maxStack then
        target:SetModifierStackCount(modifierStackName, ability, maxStack)

        -- Apply the new refreshed stack
        for i = 1, maxStack do
            ability:ApplyDataDrivenModifier(target, target, modifierBuffName, {})
        end
    else
        -- Increase the number of stacks
        currentStack = currentStack + 1

        target:SetModifierStackCount(modifierStackName, ability, currentStack)

        -- Apply the new increased stack
        for i = 1, currentStack do
            ability:ApplyDataDrivenModifier(target, target, modifierBuffName, {})
        end
    end
end


