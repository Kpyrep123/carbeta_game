LinkLuaModifier( "modifier_spike_heal", "heroes/spike/modifiers/modifier_spike_heal", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_spike_heal_active", "heroes/spike/modifiers/modifier_spike_heal", LUA_MODIFIER_MOTION_NONE )

modifier_spike_heal = class({})

function modifier_spike_heal:OnCreated()
	self.status_resistance = self:GetAbility():GetSpecialValueFor("status_resist")
	self.heal = self:GetAbility():GetSpecialValueFor("heal_per_sec")
end

function modifier_spike_heal:OnRefresh()
	self.status_resistance = self:GetAbility():GetSpecialValueFor("status_resist")
	self.heal = self:GetAbility():GetSpecialValueFor("heal_per_sec")
end

function modifier_spike_heal:IsHidden()
	return true
end

function modifier_spike_heal:IsDebuff()
	return false
end

function modifier_spike_heal:IsPurgable()
	return false
end

function modifier_spike_heal:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
	}
end

function modifier_spike_heal:GetModifierStatusResistanceStacking()
	if self:GetCaster():PassivesDisabled() then return end
	if self:GetCaster():GetHealthPercent() < (25 + self:GetCaster():GetModifierStackCount("spike_conclusion_lua_talent", self:GetCaster())) or self:GetCaster():HasModifier("modifier_spike_heal_active") then 
	return self.status_resistance * 2 
	else
	return self.status_resistance
	end 
end

function modifier_spike_heal:GetModifierHealthRegenPercentage()
	if self:GetCaster():PassivesDisabled() then return end
	if self:GetCaster():GetHealthPercent() < (25 + self:GetCaster():GetModifierStackCount("spike_conclusion_lua_talent", self:GetCaster())) or self:GetCaster():HasModifier("modifier_spike_heal_active") then 
	return self.heal * 2 
	else
	return self.heal
	end 
end

modifier_spike_heal_active = class({})

function modifier_spike_heal_active:IsHidden()
	return false
end

function modifier_spike_heal_active:IsDebuff()
	return false
end

function modifier_spike_heal_active:GetStatusEffectName()
	return "particles/status_fx/status_effect_grimstroke_ink_swell.vpcf"
	-- body
end

function modifier_spike_heal_active:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_spike_heal_active:GetEffectName()
	return "particles/units/heroes/hero_grimstroke/grimstroke_ink_swell_buff.vpcf"
end