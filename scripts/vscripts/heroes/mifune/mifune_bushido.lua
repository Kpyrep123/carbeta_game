mifune_bushido = class({})

LinkLuaModifier("modifier_bushido","heroes/mifune/mifune_bushido",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bushido_active","heroes/mifune/mifune_bushido",LUA_MODIFIER_MOTION_NONE)



function mifune_bushido:GetIntrinsicModifierName()
	return "modifier_bushido"
end

function mifune_bushido:GetCooldown(level)
	local cooldown = self.BaseClass.GetCooldown(self, level)
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_bushido") then
		cooldown = cooldown - caster:GetModifierStackCount("modifier_bushido", caster)
	end

	return cooldown
end

function mifune_bushido:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_bushido_active", {duration = self:GetSpecialValueFor("duration")})
	caster:EmitSound("Hero_Mifune.BushidoStart")
end



modifier_bushido = class({})

function modifier_bushido:IsDebuff() return false end
function modifier_bushido:IsHidden() return true end
function modifier_bushido:IsPurgable() return false end
function modifier_bushido:AllowIllusionDuplicate() return true end

function modifier_bushido:OnCreated(keys)
	if IsServer() then
		self.talent_listener = ListenToGameEvent("dota_player_learned_ability", Dynamic_Wrap(modifier_bushido, "OnPlayerLearnedAbility" ), self)
	end
end

function modifier_bushido:OnPlayerLearnedAbility(keys)
	if IsServer() then
		if keys.abilityname and keys.abilityname == "special_bonus_mifune_8" then
			self:SetStackCount(self:GetParent():GetTalentValue("special_bonus_mifune_8"))
			StopListeningToGameEvent(self.talent_listener)
		end
	end
end

function modifier_bushido:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_FAIL
	}
	return funcs
end

function modifier_bushido:OnAttackFail(keys)
	if IsServer() and keys.target == self:GetParent() then

		-- Particle
		local slash_pfx = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_slash_tgt.vpcf", PATTACH_CUSTOMORIGIN, keys.attacker)
		ParticleManager:SetParticleControl(slash_pfx, 0, keys.attacker:GetAbsOrigin())
		ParticleManager:SetParticleControl(slash_pfx, 1, keys.attacker:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(slash_pfx)

		-- Attack
		keys.target:PerformAttack(keys.attacker, true, true, true, false, false, false, false)
	end
end



modifier_bushido_active = class({})

function modifier_bushido_active:IsDebuff() return false end
function modifier_bushido_active:IsHidden() return false end
function modifier_bushido_active:IsPurgable() return true end
function modifier_bushido_active:AllowIllusionDuplicate() return true end

function modifier_bushido_active:GetEffectName()
	return "particles/units/heroes/hero_mifune/bushido_unit.vpcf"
end

function modifier_bushido_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_bushido_active:OnCreated(keys)
	if IsServer() then
		self.evasion = self:GetAbility():GetSpecialValueFor("evasion") + self:GetParent():GetTalentValue("special_bonus_mifune_4")
		self.move_speed = self:GetParent():GetTalentValue("special_bonus_mifune_6")
		self:SetHasCustomTransmitterData(true)
	end
end

function modifier_bushido_active:AddCustomTransmitterData()
	return {
		evasion = self.evasion,
		move_speed = self.move_speed
	}
end

function modifier_bushido_active:HandleCustomTransmitterData(keys)
	self.evasion = keys.evasion
	self.move_speed = keys.move_speed
end

function modifier_bushido_active:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_bushido_active:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_bushido_active:GetModifierMoveSpeedBonus_Constant()
	return self.move_speed
end