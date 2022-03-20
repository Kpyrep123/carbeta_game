parasight_sporocarp = class({})
LinkLuaModifier("modifier_parasight_sporocarp", "scripts/vscripts/heroes/parasight/modifier_parasight_sporocarp.lua", LUA_MODIFIER_MOTION_NONE)

function parasight_sporocarp:GetIntrinsicModifierName()
    return "modifier_parasight_sporocarp"
end