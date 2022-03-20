parasight_catalytic_spore_combust = class({})

function parasight_catalytic_spore_combust:CastFilterResultTarget(target)
    if target:HasModifier('modifier_parasight_catalytic_spore') then
        return UF_SUCCESS
    else
        return UF_FAIL_OTHER
    end
end

function parasight_catalytic_spore_combust:OnSpellStart()
    local target = self:GetCursorTarget()
    local modifier = target:FindModifierByName('modifier_parasight_catalytic_spore')

    if modifier then
        modifier:Combust()
    end
end