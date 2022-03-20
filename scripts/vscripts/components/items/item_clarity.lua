item_imba_clarity = item_imba_clarity or class({})

LinkLuaModifier("modifier_imba_clarity", "components/items/item_clarity", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_clarity_mana_reserves", "components/items/item_clarity", LUA_MODIFIER_MOTION_NONE)

----------------
--  CLARITY   --
----------------

function item_imba_clarity:OnSpellStart() 
	-- Ability properties
	local caster = self:GetCaster() 
	local ability = self
	local target = self:GetCursorTarget() 
	local cast_sound = "DOTA_Item.ClarityPotion.Activate"
	local modifier_regen = "modifier_imba_clarity"

	-- Emit sound
	EmitSoundOn(cast_sound, target) 

	-- Give the target the modifier
	if target:HasModifier(modifier_regen) then 
		target:FindModifierByName(modifier_regen):IncrementStackCount()
	else
	target:AddNewModifier(caster, ability, modifier_regen, {})
	target:FindModifierByName(modifier_regen):SetStackCount(1)
end

	-- Reduce a charge, or destroy the item if no charges are left
	ability:SpendCharge()
end


----------------------------------
-- CLARITY MANA REGEN MODIFIER  --
----------------------------------

modifier_imba_clarity = modifier_imba_clarity or class({})

function modifier_imba_clarity:IsHidden() return false end
function modifier_imba_clarity:IsDebuff() return false end
function modifier_imba_clarity:IsPurgable() return true end
function modifier_imba_clarity:IsPermanent() return true end

function modifier_imba_clarity:GetTexture()
	return "item_royal_jelly"
end

function modifier_imba_clarity:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end

	-- Ability properties
	self.caster = self:GetCaster() 
	self.ability = self:GetAbility()
	self.parent = self:GetParent()	
	self.modifier_mana_reserves = "modifier_imba_clarity_mana_reserves"

	-- Ability specials
	self.mana_regen = self.ability:GetSpecialValueFor("mana_regen")
	self.hp_reg = self.ability:GetSpecialValueFor("health_regen")

end

function modifier_imba_clarity:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
					 MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} 
	return decFuncs
end

function modifier_imba_clarity:GetModifierConstantManaRegen()
	return self.mana_regen * self:GetStackCount()
end

function modifier_imba_clarity:GetModifierConstantHealthRegen()
	return self.hp_reg * self:GetStackCount()
end

