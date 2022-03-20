LinkLuaModifier("modifier_troy_rage", "heroes/troy/troy_rage.lua", LUA_MODIFIER_MOTION_NONE)

troy_rage = class({})

function troy_rage:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Hero_Axe.BerserkersCall.Start")

	return true
end

function troy_rage:OnSpellStart()
	local ability = self
	local caster = self:GetCaster()

	local duration = ability:GetTalentSpecialValueFor("duration")

	caster:EmitSound("Hero_Axe.Berserkers_Call")

	caster:AddNewModifier(caster, ability, "modifier_troy_rage", {duration = duration, current_health = caster:GetHealth()})

	if caster:HasModifier("modifier_item_aghanims_shard") then
		caster:Purge(false, true, false, true, true)
	end
end

function troy_rage:GetBehavior()
	if IsClient() then return DOTA_ABILITY_BEHAVIOR_NO_TARGET end

	local shard = self:GetCaster():HasModifier("modifier_item_aghanims_shard")

	if not shard then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
	end
end

function troy_rage:GetCastPoint()
	if IsServer() then
		if self:GetCaster():HasTalent("special_bonus_troy_rage_cast_time") then
			return 0
		end
	end

	return 0.4
end
-------------------------------

modifier_troy_rage = class({})

function modifier_troy_rage:IsHidden() return false end
function modifier_troy_rage:IsDebuff() return false end
function modifier_troy_rage:IsPurgable() return false end

function modifier_troy_rage:OnCreated(keys)
	self.parent = self:GetParent()
	self.self_dps = self:GetAbility():GetSpecialValueFor("self_dps")
	self.damage_percent = self:GetAbility():GetSpecialValueFor("damage_gained_from_health_percent")
	self.tick_rate = 0.2
	self.damage_per_tick = self.self_dps * self.tick_rate

	--self:SetHasCustomTransmitterData(true)

	if IsServer() then
		self:StartIntervalThink(self.tick_rate)

		-- Adjust health
		Timers:CreateTimer(0.01, function()
			self.parent:SetHealth(keys.current_health + self:GetAbility():GetSpecialValueFor("max_hp_boost"))
		end)
	end
end

function modifier_troy_rage:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		local health_bonus = self:GetAbility():GetSpecialValueFor("max_hp_boost")

		local current_health = parent:GetHealth()
		local max_health = parent:GetMaxHealth()

		local previous_health = current_health * (max_health + health_bonus) / max_health

		parent:SetHealth(math.min(previous_health, max_health))
	end
end

function modifier_troy_rage:OnIntervalThink()
	if IsServer() then
		ApplyDamage({
			victim = self.parent,
			attacker = self.parent,
			damage = self.damage_per_tick,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
		})

		self.current_damage = self.parent:GetHealth() * self.damage_percent * 0.01
		
		if self.parent:HasTalent("special_bonus_troy_rage_double_damage") then
			self.current_damage = self.current_damage * 2
		end

		self:SetStackCount(self.current_damage)
	end
end

function modifier_troy_rage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MODEL_SCALE
	}

	return funcs
end

function modifier_troy_rage:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("max_hp_boost")
end

function modifier_troy_rage:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end

function modifier_troy_rage:GetModifierModelScale()
	return 50
end
