xartoth_brutality = class({})
LinkLuaModifier( "xartoth_brutality_buff", "heroes/xartoth/xartoth_brutality.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "xartoth_brutality_stacks", "heroes/xartoth/xartoth_brutality.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "xartoth_brutality_proc", "heroes/xartoth/xartoth_brutality.lua" ,LUA_MODIFIER_MOTION_NONE )

function xartoth_brutality:OnSpellStart(kv)
	EmitSoundOn("Xartoth.Brutality", self:GetCaster())
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "xartoth_brutality_buff", {duration = self:GetSpecialValueFor("damage_duration")})
end

function xartoth_brutality:GetIntrinsicModifierName()
	return "xartoth_brutality_stacks"
end

function xartoth_brutality:GetAbilityTextureName()
	local stacks = self:GetCaster():GetModifierStackCount("xartoth_brutality_stacks", self:GetCaster())
	if stacks == self:GetSpecialValueFor("max_stacks") then
			return "selfmade/xartoth_brutality_proc"
	else
		return "selfmade/xartoth_brutality"
	end
	
	return "selfmade/xartoth_brutality"
end

xartoth_brutality_buff = class({})

function xartoth_brutality_buff:GetTexture()
	return "selfmade/xartoth_brutality"
end

function xartoth_brutality_buff:IsPurgable() return false end

function xartoth_brutality_buff:IsDebuff() return false end

function xartoth_brutality_buff:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
	return funcs
end


function xartoth_brutality_buff:OnAttackLanded(kv)
	if kv.attacker == self:GetParent() then
	 local stacks = self:GetParent():GetModifierStackCount("xartoth_brutality_stacks", self:GetParent())
	 local ability = self:GetAbility()
	 local subab = self:GetCaster():FindAbilityByName("Battle_fury")
	  if stacks < self:GetAbility():GetSpecialValueFor("max_stacks") then
		self:GetParent():RemoveModifierByName("xartoth_brutality_buff")
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "xartoth_brutality_stacks", {})
		self:GetParent():SetModifierStackCount("xartoth_brutality_stacks", self:GetParent(), stacks + 1)
		ParticleManager:SetParticleControl(ability.particle, 1, Vector(0,(stacks + 1),0))
	  else
	   self:GetParent():RemoveModifierByName("xartoth_brutality_buff")
	   self:GetParent():SetModifierStackCount("xartoth_brutality_stacks", self:GetParent(), 0)
	   EmitSoundOn("DOTA_Item.SkullBasher", kv.target)
	   kv.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_stunned", {duration = (self:GetAbility():GetSpecialValueFor("stun_duration") + self:GetCaster():GetTalentValue("special_bonus_unquie_brutality_stun")) * (1 - kv.target:GetStatusResistance())})
	   self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "xartoth_brutality_proc", {duration = self:GetAbility():GetSpecialValueFor("buff_duration")})

	   ParticleManager:SetParticleControl(ability.particle, 1, Vector(0,0,0))
	  end
	end
end

function xartoth_brutality_buff:GetEffectName()
	return "particles/xartothattackbuff_particles/xartoth_attack_buff.vpcf"
end

function xartoth_brutality_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

xartoth_brutality_stacks = class({})

function xartoth_brutality_stacks:IsDebuff() return false end

function xartoth_brutality_stacks:IsPurgable() return false end

function xartoth_brutality_stacks:IsHidden() return true end

function xartoth_brutality_stacks:GetTexture()
	return "xartoth_brutality"
end

function xartoth_brutality_stacks:OnCreated(kv)
	local ability = self:GetAbility()
	if IsServer() then
		if not ability.particle then
		ability.particle = ParticleManager:CreateParticle("particles/xartothcounter_particles/xartoth_counter_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(ability.particle, 1, Vector(0,0,0))
		end
	end
end

function xartoth_brutality_stacks:DeclareFunctions()
	local funcs = {
	MODIFIER_EVENT_ON_DEATH,
	MODIFIER_EVENT_ON_RESPAWN,
	}
	return funcs
end

function xartoth_brutality_stacks:OnDeath(kv)
	if kv.unit == self:GetParent() then
		self:GetParent():SetModifierStackCount("xartoth_brutality_stacks", self:GetParent(), 0)
		ParticleManager:DestroyParticle(self:GetAbility().particle, false)
	end
end

function xartoth_brutality_stacks:OnRespawn(kv)
	if kv.unit == self:GetParent() then
		self:GetAbility().particle = ParticleManager:CreateParticle("particles/xartothcounter_particles/xartoth_counter_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self:GetAbility().particle, 1, Vector(0,0,0))
	end
end

xartoth_brutality_proc = class({})

function xartoth_brutality_proc:IsPurgable() return false end

function xartoth_brutality_proc:GetTexture()
	return "xartoth_brutality_proc"
end

function xartoth_brutality_proc:IsDebuff() return false end

function xartoth_brutality_proc:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return funcs
end

function xartoth_brutality_proc:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attackspeed_buff")
end

function xartoth_brutality_buff:GetModifierPreAttack_BonusDamage()
	local damage_arm = self:GetAbility():GetSpecialValueFor("bonus_damage")
	local damage_tal = self:GetAbility():GetSpecialValueFor("dmg_tal")
	if self:GetCaster():HasTalent("special_bonus_unquie_brutality_dmg") then 
		return damage_tal
	else
	return damage_arm
end
end
