if arbalest_attack_dummy == nil then
	arbalest_attack_dummy = class({})
end




function arbalest_attack_dummy:IsHidden()
	return true
end

function arbalest_attack_dummy:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
	}
 
	return funcs
end
