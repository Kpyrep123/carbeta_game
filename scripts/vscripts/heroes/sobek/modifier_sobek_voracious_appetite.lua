modifier_sobek_voracious_appetite = class({})

function modifier_sobek_voracious_appetite:IsDebuff() return false end
function modifier_sobek_voracious_appetite:IsPurgable() return false end
function modifier_sobek_voracious_appetite:IsPurgeException() return false end
function modifier_sobek_voracious_appetite:IsHidden() return false end
function modifier_sobek_voracious_appetite:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_sobek_voracious_appetite:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MODEL_SCALE
	}
end

function modifier_sobek_voracious_appetite:GetModifierBonusStats_Strength()
	return self:GetStackCount()
end

function modifier_sobek_voracious_appetite:GetModifierModelScale()
	return math.min(2 * self:GetStackCount(), 100)
end