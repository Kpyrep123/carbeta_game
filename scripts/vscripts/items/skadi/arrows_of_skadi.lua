function modifier_item_arrows_of_skadi(keys)
    if keys.caster:IsRangedAttacker() then
        keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "Modifier_item_arrow_of_skadi_range", {duration = -1})
    end
end

function modifier_item_arrows_of_skadi_remove ( keys )
    local ability = keys.ability
    local caster = keys.caster
    local modifier = "Modifier_item_arrow_of_skadi_range"
    caster:RemoveModifierByName("Modifier_item_arrow_of_skadi_range")
    print ("Removing stats")
end