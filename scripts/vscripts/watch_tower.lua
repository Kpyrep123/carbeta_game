ability_red_soul = class({})
LinkLuaModifier("modifier_red_soul", "watch_tower.lua", LUA_MODIFIER_MOTION_NONE)
function ability_red_soul:GetIntrinsicModifierName(  )
	return "modifier_red_soul"
end

function ability_red_soul:Spawn()
	if not IsServer() then return end 
		self:SetLevel(1)
end

modifier_red_soul = class({})
function modifier_red_soul:IsHidden() return true end
function modifier_red_soul:IsPurgable() return false end
function modifier_red_soul:GetEffectName() return "particles/watch_tower_red.vpcf" end

function modifier_red_soul:GetOverrideAnimation()
	return ACT_DOTA_CAPTURE
	
end

function modifier_red_soul:GetEffectAttachType(  )
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_red_soul:OnCreated()

end

function modifier_red_soul:OnRefresh()

end

function modifier_red_soul:DeclareFunctions()
 local funcs = {

 }
return funcs
end

function modifier_red_soul:CheckState(  )
	if not IsServer() then return end
	local state = {
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_FAKE_ALLY] = true,
			}

	return state
end