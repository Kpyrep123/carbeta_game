--[[
		By: AtroCty
		Date: 17.05.2017
		Updated:  17.05.2017
	]]
-------------------------------------------
--			AETHER LENS
-------------------------------------------
LinkLuaModifier("modifier_imba_aether_lens_passive", "components/items/item_aether_lens.lua", LUA_MODIFIER_MOTION_NONE)
-------------------------------------------

item_imba_aether_lens = item_imba_aether_lens or class({})
-------------------------------------------
function item_imba_aether_lens:GetIntrinsicModifierName()
	return "modifier_imba_aether_lens_passive"
end

function item_imba_aether_lens:GetAbilityTextureName()
	return "custom/souls/vision"
end

-------------------------------------------
modifier_imba_aether_lens_passive = modifier_imba_aether_lens_passive or class({})

function modifier_imba_aether_lens_passive:IsHidden()		return true end
function modifier_imba_aether_lens_passive:IsPurgable()		return false end
function modifier_imba_aether_lens_passive:RemoveOnDeath()	return false end
function modifier_imba_aether_lens_passive:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_aether_lens_passive:OnDestroy()
	self:CheckUnique(false)
end

function modifier_imba_aether_lens_passive:OnCreated()
    if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
    
	local item = self:GetAbility()
	self.parent = self:GetParent()
	if self.parent:IsHero() and item then
		self.cast_range_bonus = item:GetSpecialValueFor("cast_range_bonus")
		self:CheckUnique(true)
	end

	if not IsServer() then return end
end

function modifier_imba_aether_lens_passive:OnDestroy()
	if not IsServer() then return end
	
    for _, mod in pairs(self:GetParent():FindAllModifiersByName(self:GetName())) do
        mod:GetAbility():SetSecondaryCharges(_)
    end
end

function modifier_imba_aether_lens_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
	}
end

function modifier_imba_aether_lens_passive:GetModifierCastRangeBonusStacking()
	return self:CheckUniqueValue(self.cast_range_bonus, {"modifier_imba_elder_staff","modifier_item_imba_aether_specs"})
end
