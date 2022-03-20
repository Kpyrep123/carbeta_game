modifier_parasight_sporocarp_truesight = class({})

function modifier_parasight_sporocarp_truesight:IsAura() return true end
----------------------------------------------------------------------------------------------------------
function modifier_parasight_sporocarp_truesight:GetModifierAura()  return "modifier_truesight" end
----------------------------------------------------------------------------------------------------------
function modifier_parasight_sporocarp_truesight:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
----------------------------------------------------------------------------------------------------------
function modifier_parasight_sporocarp_truesight:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
----------------------------------------------------------------------------------------------------------
function modifier_parasight_sporocarp_truesight:GetAuraRadius() return self.radius end

function modifier_parasight_sporocarp_truesight:OnCreated(params) 
	self.radius = params.Radius or 0
end