LinkLuaModifier("modifier_attributes", "attributes.lua", LUA_MODIFIER_MOTION_NONE)
ability_hero_attributes_spike = class({})
ability_hero_attributes_cursed = class({})

function ability_hero_attributes_spike:GetIntrinsicModifierName(  )
	return "modifier_attributes"
end

function ability_hero_attributes_spike:Spawn(  )
	self:SetLevel(1)
end

function ability_hero_attributes_cursed:GetIntrinsicModifierName(  )
	return "modifier_attributes"
end

function ability_hero_attributes_cursed:Spawn(  )
	
	self:SetLevel(1)
end

modifier_attributes = class({})

modifier_attributes = class({})
function modifier_attributes:IsHidden() return true end
function modifier_attributes:IsPurgable() return false end
function modifier_attributes:GetTexture() return end
function modifier_attributes:GetEffectName() return end

function modifier_attributes:OnCreated()
if not IsServer() then return end
self.agility = self:GetAbility():GetSpecialValueFor("agility")
self.strength = self:GetAbility():GetSpecialValueFor("strength")
self.intellect = self:GetAbility():GetSpecialValueFor("intellect")
end

function modifier_attributes:OnRefresh()
if not IsServer() then return end
self.agility = self:GetAbility():GetSpecialValueFor("agility")
self.strength = self:GetAbility():GetSpecialValueFor("strength")
self.intellect = self:GetAbility():GetSpecialValueFor("intellect")
end

function modifier_attributes:DeclareFunctions()
return
	{
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
end

function modifier_attributes:GetModifierBonusStats_Strength(  )
	return self.strength * self:GetCaster():GetLevel()	
end

function modifier_attributes:GetModifierBonusStats_Agility(  )
	-- body
	return self.agility * self:GetCaster():GetLevel()
end

function modifier_attributes:GetModifierBonusStats_Intellect(  )
	return self.intellect * self:GetCaster():GetLevel()	
end