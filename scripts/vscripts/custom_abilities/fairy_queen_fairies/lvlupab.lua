lvlupab = class({})
LinkLuaModifier( "lvlupab", "custom_abilities/fairy_queen_fairies/modifier_lvlupab", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
function lvlupab:GetIntrinsicModifierName()
	return "modifier_lvlupab"
end
-- Init ability
function lvlupab:Spawn()
	if not IsServer() then return end
	self:SetLevel(1)
end