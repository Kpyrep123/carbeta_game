modifier_drow_attckrange = class({})

function ability_drow_ult:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_drow_attckrange", {duration = duration})

	caster:EmitSound("Hero_Slardar.Sprint")
end

function modifier_drow_attckrange:IsHidden()
	return false
end

function modifier_drow_attckrange:IsDebuff()
	return false
end


function modifier_drow_attckrange:IsPurchasable()
	return false
end


function modifier_drow_attckrange:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_drow_attckrange:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_STATE_CANNOT_MISS,
	}
	return funcs
end


function modifier_drow_attckrange:GetModifierAttackRangeBonus()
	return 400 550 700
end
