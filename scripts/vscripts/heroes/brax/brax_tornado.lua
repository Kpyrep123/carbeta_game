--	Thunderboar's Tornado
--	Concept by Brax
--	Implementation by Firetoad, 2018.09.03

LinkLuaModifier("modifier_brax_tornado_passive", "heroes/brax/brax_tornado.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_brax_tornado_movement_speed_talent", "heroes/brax/brax_tornado.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_brax_tornado_counter", "heroes/brax/brax_tornado.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_brax_tornado_state", "heroes/brax/brax_tornado.lua", LUA_MODIFIER_MOTION_NONE)

brax_tornado = class({})

-------------------------------

function brax_tornado:GetIntrinsicModifierName()
	return "modifier_brax_tornado_passive"
end

function brax_tornado:OnSpellStart()
	if IsServer() then
		if self:GetCaster():FindModifierByName("modifier_brax_tornado_counter"):GetStackCount() > 0 then
			self:ConsumeLastTornado()
		end
	end
end

function brax_tornado:SpawnTornado(position)
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration") + caster:GetTalentValue("special_bonus_brax_1")
		local max_counter = self:GetSpecialValueFor("max_units") + caster:GetTalentValue("special_bonus_brax_5")
		local counter_modifier = caster:FindModifierByName("modifier_brax_tornado_counter")

		self:SetActivated(true)

		local pup = CreateUnitByName("npc_dota_brax_tornado_tornado", position, false, caster, nil, caster:GetTeam())
		pup:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
		pup:AddNewModifier(caster, self, "modifier_brax_tornado_state", {})
		table.insert(self.pup_table, pup)

		-- Tornado consuming
		if counter_modifier then
			counter_modifier:SetStackCount(counter_modifier:GetStackCount() + 1)

			if counter_modifier:GetStackCount() > max_counter then
				self:ConsumeLastTornado()
			end
		end
	end
end

function brax_tornado:ConsumeLastTornado()
	local oldest_pup = nil

	-- Consume tornado
	for i, pup in pairs(self.pup_table) do
		if IsValidEntity(pup) and pup:IsAlive() then
			if oldest_pup == nil then
				oldest_pup = pup
			end

			if pup:HasModifier("modifier_kill") and oldest_pup:HasModifier("modifier_kill") then
				if pup:FindModifierByName("modifier_kill"):GetRemainingTime() < oldest_pup:FindModifierByName("modifier_kill"):GetRemainingTime() then
					oldest_pup = pup
				end
			end
		else
			table.remove(self.pup_table, i)
		end
	end

	if oldest_pup then
		oldest_pup:ForceKill(false)
	end
end

-------------------------------

modifier_brax_tornado_passive = class({})

function modifier_brax_tornado_passive:IsHidden() return true end
function modifier_brax_tornado_passive:IsDebuff() return false end
function modifier_brax_tornado_passive:IsPurgable() return false end
function modifier_brax_tornado_passive:RemoveOnDeath() return false end
function modifier_brax_tornado_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_brax_tornado_passive:OnCreated(keys)
	if IsServer() then
		self:GetAbility():SetActivated(false)
		self:GetAbility().pup_table = {}
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_brax_tornado_counter", {})
		self:StartIntervalThink(0.1)
	end
end

function modifier_brax_tornado_passive:OnIntervalThink()
	if IsServer() then
		local talent_ability = self:GetParent():FindAbilityByName("special_bonus_brax_2")
		if talent_ability and talent_ability:GetLevel() > 0 and not self:GetParent():HasModifier("modifier_brax_tornado_movement_speed_talent") then
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_brax_tornado_movement_speed_talent", {})
		end
	end
end

function modifier_brax_tornado_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function modifier_brax_tornado_passive:OnDeath(keys)
	if IsServer() then
		if keys.attacker == self:GetParent() then
			--for i = 1, 2 do
				self:GetAbility():SpawnTornado(keys.unit:GetAbsOrigin())
			--end
		end

		if keys.unit == self:GetParent() then
			for _, pup in pairs(self:GetAbility().pup_table) do
				if IsValidEntity(pup) then
					pup:ForceKill(false)
				end
			end

			self:GetAbility().pup_table = {}
		end
	end
end

-------------------------------

modifier_brax_tornado_movement_speed_talent = class({})

function modifier_brax_tornado_movement_speed_talent:IsHidden() return true end
function modifier_brax_tornado_movement_speed_talent:IsDebuff() return false end
function modifier_brax_tornado_movement_speed_talent:IsPurgable() return false end

-------------------------------

modifier_brax_tornado_counter = class({})

function modifier_brax_tornado_counter:IsHidden() return (self:GetStackCount() <= 0) end
function modifier_brax_tornado_counter:IsDebuff() return false end
function modifier_brax_tornado_counter:IsPurgable() return false end
function modifier_brax_tornado_counter:RemoveOnDeath() return false end
function modifier_brax_tornado_counter:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_brax_tornado_counter:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_brax_tornado_counter:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_brax_tornado_counter:OnIntervalThink()
	if self:GetStackCount() > 0 then
		local damage = (self:GetAbility():GetSpecialValueFor("dps") * self:GetStackCount()) * 0.5
		local radius = self:GetAbility():GetSpecialValueFor("radius")

		-- Shock
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			ApplyDamage({victim = enemy, attacker = self:GetCaster(), ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
		end

		if #enemies > 0 then
			self:GetParent():EmitSound("Brax.ThunderpupAttack")
		end
	end
end

function modifier_brax_tornado_counter:GetModifierMoveSpeedBonus_Percentage()
	if self:GetParent():HasModifier("modifier_brax_tornado_movement_speed_talent") then
		return 2 * self:GetStackCount()
	else
		return 0
	end
end

-------------------------------

modifier_brax_tornado_state = class({})

function modifier_brax_tornado_state:IsHidden() return true end
function modifier_brax_tornado_state:IsDebuff() return false end
function modifier_brax_tornado_state:IsPurgable() return false end

function modifier_brax_tornado_state:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_brax_tornado_state:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_MOVESPEED_MAX
	}
	return funcs
end

function modifier_brax_tornado_state:GetModifierMoveSpeed_Absolute()
	return self:GetAbility():GetSpecialValueFor("tornado_speed")
end

function modifier_brax_tornado_state:GetModifierMoveSpeed_Max()
	return self:GetAbility():GetSpecialValueFor("tornado_speed")
end

function modifier_brax_tornado_state:CheckState()
	if IsServer() then
		local state = {
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
		}
		return state
	end
end

function modifier_brax_tornado_state:OnCreated()
	if IsServer() then
		self:GetParent():EmitSound("Brax.ThunderpupSpawn")
		self:StartIntervalThink(0.5)

		self.aura_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_thunderboar/thunderpups.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.aura_pfx, 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.aura_pfx, 2, Vector(80, 0, 0))
		
	end
end

function modifier_brax_tornado_state:OnDestroy()
	if IsServer() then
		local modifier_count = self:GetCaster():FindModifierByName("modifier_brax_tornado_counter")
		if modifier_count then
			local heal = self:GetAbility():GetSpecialValueFor("heal")
			self:GetCaster():Heal(heal, self:GetAbility())
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self:GetCaster(), heal, nil)
			self:GetParent():EmitSound("Brax.ThunderpupHeal")
			local heal_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_thunderboar/thunderpups_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControl(heal_pfx, 0, self:GetCaster():GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(heal_pfx)
			modifier_count:SetStackCount(modifier_count:GetStackCount() - 1)

			if modifier_count:GetStackCount() <= 0 then
				self:GetAbility():SetActivated(false)
			end
		end

		ParticleManager:DestroyParticle(self.aura_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.aura_pfx)
	end
end

function modifier_brax_tornado_state:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local tornado = self:GetParent()
		local tornado_radius = self:GetAbility():GetSpecialValueFor("tornado_radius")

		-- Movement
		if (tornado:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() > tornado_radius then
			if not tornado:IsMoving() then
				tornado:MoveToPosition(caster:GetAbsOrigin() + RandomVector(tornado_radius))
			end
		end
	end
end
