--[[Author: TheGreatGimmick
    Date: Jan 19, 2017
    Dust Potion's True Sight debuff
    ]]
    
function DustPotionTrueSight(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    
    target:RemoveModifierByName('modifier_truesight')
    target:AddNewModifier(caster, ability, 'modifier_truesight', {duration = 0.5})
end