LinkLuaModifier("modifier_attributes", "attributes.lua", LUA_MODIFIER_MOTION_NONE)
ability_hero_attributes_spike = class({})
ability_hero_attributes_cursed = class({})
ability_hero_attributes_azura = class({})
ability_hero_attributes_drow_ranger = class({})
hero_attributes_rl = class({})
hero_attributes_tb = class({})
hero_attributes_bs = class({})


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

function hero_attributes_bs:GetIntrinsicModifierName(  )
	return "modifier_attributes"
end

function hero_attributes_bs:Spawn(  )
	
	self:SetLevel(1)
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function ability_hero_attributes_azura:GetIntrinsicModifierName(  )
	return "modifier_attributes"
end

function ability_hero_attributes_azura:Spawn(  )
	
	self:SetLevel(1)
end

function ability_hero_attributes_drow_ranger:GetIntrinsicModifierName(  )
	return "modifier_attributes"
end

function ability_hero_attributes_drow_ranger:Spawn(  )
	
	self:SetLevel(1)
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function hero_attributes_rl:GetIntrinsicModifierName(  )
	return "modifier_attributes"
end

function hero_attributes_rl:Spawn(  )
	
	self:SetLevel(1)
end

function hero_attributes_tb:GetIntrinsicModifierName(  )
	return "modifier_attributes"
end

function hero_attributes_tb:Spawn(  )
	
	self:SetLevel(1)
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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