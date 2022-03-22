
modifier_status_bleed = class({})
function modifier_status_bleed:IsHidden() return false end
function modifier_status_bleed:IsPurgable() return false end
function modifier_status_bleed:GetTexture() return end
function modifier_status_bleed:GetEffectName() return end
function modifier_status_bleed:GetAttributes()	
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_status_bleed:OnCreated()
if not IsServer() then return end
	self.count = 0
	self.count_max = 7
	self:StartIntervalThink(0.5)
	self:OnIntervalThink()
end

function modifier_status_bleed:OnRefresh()
if not IsServer() then return end
end

function modifier_status_bleed:DeclareFunctions()
	 local funcs = 	{
		MODIFIER_EVENT_ON_ATTACK,
	}
return funcs
end

function modifier_status_bleed:OnIntervalThink(  )
	if self:GetCaster():IsIllusion() then self:Destroy() end
	self.count = self.count + 1
	print(self.count)
	if self.count >= self.count_max then 
		self:Destroy()
	end
	local damage = self:GetCaster():GetAttackDamage() * 0.35
		ApplyDamage({
		    victim = self:GetParent(),
		    attacker = self:GetCaster(),
		    damage = damage,
		    damage_type = DAMAGE_TYPE_MAGICAL,
		    damage_flags = DOTA_DAMAGE_FLAG_NONE,
		    ability = self:GetAbility()
	  	})
end