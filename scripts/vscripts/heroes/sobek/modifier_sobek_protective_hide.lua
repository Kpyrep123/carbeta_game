modifier_sobek_protective_hide = class({})

function modifier_sobek_protective_hide:OnCreated(kv)
    self.magic_resistance = self:GetAbility():GetSpecialValueFor("magic_resistance")
    if IsServer() then
		self:GetParent():CalculateStatBonus(true)
        self:StartIntervalThink( 0.1 )
	end
end

function modifier_sobek_protective_hide:OnRefresh(kv)
    self.magic_resistance = self:GetAbility():GetSpecialValueFor("magic_resistance")
    if IsServer() then
		self:GetParent():CalculateStatBonus(true)
	end
end

function modifier_sobek_protective_hide:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
end

function modifier_sobek_protective_hide:GetModifierMagicalResistanceBonus()
    return self:GetStackCount() * self.magic_resistance
end

function modifier_sobek_protective_hide:OnIntervalThink()
	if IsServer() then
        -- (100-45 = 55), 55 / 10 = 5.5, floor(5.5) = 5
		self:SetStackCount(math.floor((100 - self:GetCaster():GetHealthPercent()) / 10))
	end
end