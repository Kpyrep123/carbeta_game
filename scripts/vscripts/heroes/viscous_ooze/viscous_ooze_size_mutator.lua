LinkLuaModifier("modifier_size_mutator","heroes/viscous_ooze/viscous_ooze_size_mutator.lua",LUA_MODIFIER_MOTION_NONE)


viscous_ooze_size_mutator = class({})

function viscous_ooze_size_mutator:GetIntrinsicModifierName()
	return "modifier_size_mutator"
end

modifier_size_mutator = class({})

function modifier_size_mutator:IsHidden()
	return true
end

function modifier_size_mutator:IsPermanent()
	return true
end

function modifier_size_mutator:DeclareFunctions(  )
	local funcs = 
	{
		MODIFIER_PROPERTY_MODEL_SCALE
	}
	return funcs
end

function modifier_size_mutator:GetModifierModelScale()
	return (self:GetParent():GetStrength() / 5) - 10
end