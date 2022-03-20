modifier_sobek_voracious_appetite_buff = class({})

function modifier_sobek_voracious_appetite_buff:OnCreated(params)
    self.strength_steal = params.strength_stolen or 0

    if IsServer() then
        self:SetStackCount(self.strength_steal)
        self:GetParent():CalculateStatBonus(true)
    end
end

function modifier_sobek_voracious_appetite_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_sobek_voracious_appetite_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
    }
end

function modifier_sobek_voracious_appetite_buff:GetModifierBonusStats_Strength()
    return self.strength_steal
end

