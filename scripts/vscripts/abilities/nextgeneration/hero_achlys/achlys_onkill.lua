function arckosaghanim( keys )
	local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local manabonus = "Modifier_epty"
    if caster:HasScepter() then
	ability:ApplyDataDrivenModifier( caster, caster, manabonus, {} )
	else
		return nil
	end
end


function Stacks( keys )
    local caster = keys.caster
    local ability = keys.ability
    if caster:HasScepter() then
    local maxStack = ability:GetLevelSpecialValueFor("max_stacks", (ability:GetLevel() - 1))
    local modifierCount = caster:GetModifierCount()
    local currentStack = 0
    local modifierBuffName = "modifier_bonus_mana"
    local modifierStackName = "modifier_dummy"
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
        currentStack = currentStack + 50

        caster:SetModifierStackCount(modifierStackName, ability, currentStack)

        -- Apply the new increased stack
        for i = 1, currentStack do
            ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
        end
    end
else 
	return nil
end
end