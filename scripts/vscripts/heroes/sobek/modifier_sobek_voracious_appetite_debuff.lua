modifier_sobek_voracious_appetite_debuff = class({})

function modifier_sobek_voracious_appetite_debuff:IsDebuff() return false end
function modifier_sobek_voracious_appetite_debuff:IsPurgable() return false end
function modifier_sobek_voracious_appetite_debuff:IsPurgeException() return false end
function modifier_sobek_voracious_appetite_debuff:IsHidden() return false end
function modifier_sobek_voracious_appetite_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_sobek_voracious_appetite_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_sobek_voracious_appetite_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow_amount")
end