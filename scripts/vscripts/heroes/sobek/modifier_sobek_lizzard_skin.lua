modifier_sobek_lizzard_skin = class({})


function modifier_sobek_lizzard_skin:IsHidden()
	return self:GetStackCount()==0
end

function modifier_sobek_lizzard_skin:IsDebuff()
	return false
end

function modifier_sobek_lizzard_skin:IsPurgable()
	return false
end

function modifier_sobek_lizzard_skin:DestroyOnExpire()
	return false
end

function modifier_sobek_lizzard_skin:OnCreated( kv )

	local ability_level = self:GetAbility():GetLevel() - 1
	local res_tal = self:GetCaster():FindAbilityByName("special_bonus_unquie_magic_res")
	self.bonus = self:GetAbility():GetLevelSpecialValueFor("bonus_magic_resistance", ability_level)
	self.regen = self:GetAbility():GetLevelSpecialValueFor("hp_regen", ability_level)
	self.resist = self:GetAbility():GetLevelSpecialValueFor("bonus_armor", ability_level)
	self.max_stacks = self:GetAbility():GetLevelSpecialValueFor("max_stacks", ability_level) + self:GetCaster():GetTalentValue("special_bonus_unquie_hp_reg")
	duration = self:GetAbility():GetLevelSpecialValueFor("duration", ability_level) + self:GetCaster():GetTalentValue("special_bonus_unquie_skin_dur")
	if not IsServer() then return end
end

function modifier_sobek_lizzard_skin:OnRefresh( kv )

	local ability_level = self:GetAbility():GetLevel() - 1
	local res_tal = self:GetCaster():FindAbilityByName("special_bonus_unquie_magic_res")
	self.bonus = self:GetAbility():GetLevelSpecialValueFor("bonus_magic_resistance", ability_level)
	self.regen = self:GetAbility():GetLevelSpecialValueFor("hp_regen", ability_level)
	self.resist = self:GetAbility():GetLevelSpecialValueFor("bonus_armor", ability_level)
	self.max_stacks = self:GetAbility():GetLevelSpecialValueFor("max_stacks", ability_level) + self:GetCaster():GetTalentValue("special_bonus_unquie_hp_reg")
	duration = self:GetAbility():GetLevelSpecialValueFor("duration", ability_level) + self:GetCaster():GetTalentValue("special_bonus_unquie_skin_dur")

end

function modifier_sobek_lizzard_skin:OnRemoved()
end

function modifier_sobek_lizzard_skin:OnDestroy()
end

function modifier_sobek_lizzard_skin:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}

	return funcs
end


function modifier_sobek_lizzard_skin:GetModifierMagicalResistanceBonus( params )
	if not self:GetParent():PassivesDisabled() then
		return self.bonus
	end
end

function modifier_sobek_lizzard_skin:OnAttacked( params )
	if params.target == self:GetParent() then
	if self:GetParent():PassivesDisabled() then return end


	if self:GetStackCount()<self.max_stacks then
		self:IncrementStackCount()
	end

	-- refresh duration
	self:SetDuration( duration + self:GetCaster():GetTalentValue("special_bonus_unquie_skin_dur"), true )
	self:StartIntervalThink( duration + self:GetCaster():GetTalentValue("special_bonus_unquie_skin_dur") )
end
end

function modifier_sobek_lizzard_skin:OnIntervalThink()
	-- Expire
	self:StartIntervalThink( -1 )
	self:SetStackCount( 0 )
end


function modifier_sobek_lizzard_skin:GetModifierConstantHealthRegen()
	if not self:GetParent():PassivesDisabled() then 
		return self.regen * self:GetStackCount()
	end
end


function modifier_sobek_lizzard_skin:GetModifierPhysicalArmorBonus()
	if not self:GetParent():PassivesDisabled() then return self.resist * self:GetStackCount() end
end