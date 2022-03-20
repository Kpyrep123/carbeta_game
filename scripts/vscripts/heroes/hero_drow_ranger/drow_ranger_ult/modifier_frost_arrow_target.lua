modifier_frost_arrow_target = class({})

function modifier_frost_arrow_target:IsHidden()
	return true
end

function modifier_frost_arrow_target:IsDebuff()
	return true
end


function modifier_frost_arrow_target:IsPurchasable()
	return true
end


function modifier_frost_arrow_target:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_frost_arrow_target:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end


function modifier_frost_arrow_target:GetModifierAttackSpeedBonus_Constant()
	return -6
end

function modifier_frost_arrow_target:GetModifierMoveSpeedBonus_Percentage()
	return -3
end