LinkLuaModifier("modifier_latch", "scripts/vscripts/heroes/warp_beast/warp_beast_latch.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_latch_target", "scripts/vscripts/heroes/warp_beast/warp_beast_latch.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_latch_scepter", "scripts/vscripts/heroes/warp_beast/warp_beast_latch.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_latch_shard", "scripts/vscripts/heroes/warp_beast/warp_beast_latch.lua", LUA_MODIFIER_MOTION_NONE)


warp_beast_latch = class({})


function warp_beast_latch:CastFilterResultTarget(hTarget)
	if hTarget == self:GetCaster() then 
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end
function warp_beast_latch:GetCustomCastErrorTarget(hTarget)
	return "Cannot Target Self"
end


function warp_beast_latch:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	if target:GetTeam() ~= caster:GetTeam() and target:TriggerSpellAbsorb(self) then
		return
	end

	if target:HasModifier("modifier_item_lotus_orb_active") then 
		return 
	end

	-- Scepter effect
	if caster:HasScepter() then
		caster:AddNewModifier(caster, self, "modifier_latch_scepter", {duration = self:GetSpecialValueFor("duration_scepter")})
	end

	local distance = -80 
	local duration = self:GetSpecialValueFor("duration")
	if target:GetTeam() == caster:GetTeam() then 
		distance = -20
		duration = -1
	end

	local bonusAttackSpeed = self:GetSpecialValueFor("attackspeed_bonus") + caster:GetTalentValue("special_bonus_unique_warp_beast_latch_attackspeed")
	local modifier = caster:AddNewModifier(caster, self, "modifier_latch", {Duration = duration, attackSpeed = bonusAttackSpeed})
	target:AddNewModifier(caster, self, "modifier_latch_target", {Duration = duration})
	modifier.target = target

	local latchPosition = target:GetAbsOrigin() + (target:GetForwardVector() * distance) + Vector(0, RandomFloat(-2, 2), 0)
	local latchDirection = (target:GetAbsOrigin() - latchPosition):Normalized()

	caster:Hold()
	caster:EmitSound("Hero_Warp_Beast.Latch")

	local targetHeight = self:GetLatchHeight(target)
	
	caster:SetAbsOrigin(latchPosition + Vector(0,0,targetHeight))
	caster:SetForwardVector(latchDirection)
	-- caster:SetAbsOrigin(target:GetAbsOrigin() + Vector(0, 0, 150) + caster:GetForwardVector() * -75)
	caster:SetParent(target, "attach_origin")

	if target:GetTeam() ~= caster:GetTeam() then
		caster:SetAngles(45, caster:GetAngles().y, caster:GetAngles().z)
		caster:SetAttacking(target)
		local order = 
		{
			UnitIndex = caster:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = target:entindex()
		}
		ExecuteOrderFromTable(order)
		caster:SetForceAttackTarget(target)
		-- Timers:CreateTimer(0.1, function() ExecuteOrderFromTable(order) return nil end )
	end

	-- caster:SetCursorTargetingNothing(true)
	
	-- caster:PerformAttack(target, true, true, true, true, false, false, false)

end

function warp_beast_latch:GetLatchHeight(target)
	if target:GetUnitName() == "npc_dota_hero_phoenix" then return 180 end
	if target:GetUnitName() == "npc_dota_hero_skywrath_mage" then return 240 end
	if target:IsHero() then return 120 end
	if target:IsBarracks() then return 250 end
	if target:IsTower() then return 275 end
	if target:IsRoshan() then return 300 end
	if target:IsFort() then return 400 end
	if target:GetUnitName() == "npc_dota_phoenix_sun" then return 340 end
	-- Default height
	return 80
end


------------------------------------------------------------------------------------------------------------------
modifier_latch = class({})

function modifier_latch:CheckState( )
	local states = {
		-- [MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
	}
	return states
end

function modifier_latch:OnCreated(keys)
	self.attackspeed_bonus = keys.attackSpeed
	if IsServer() then 
		self:StartIntervalThink(0.1)
	end
end

function modifier_latch:OnIntervalThink()
	if not IsServer() then return end

	if self.target then
		local caster = self:GetCaster()
		local target = self.target

		if not caster:CanEntityBeSeenByMyTeam(target) then
			target:RemoveModifierByNameAndCaster("modifier_latch_target", caster)
		end

		if caster:IsStunned() then 
			target:RemoveModifierByNameAndCaster("modifier_latch_target", caster)
		end
	end
end

function modifier_latch:GetEffectName()
	return "particles/units/heroes/hero_warp_beast/warp_beast_latch.vpcf"
end

function modifier_latch:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ORDER
	}
	return funcs
end

function modifier_latch:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed_bonus
end

function modifier_latch:OnAttackLanded(event)
	if IsServer() and self:GetParent() == event.attacker then 
		local attacker = event.attacker
		local target = event.target

		-- if target:IsBuilding() or target:IsIllusion() or (target:GetTeam() == attacker:GetTeam()) then
		-- 	return end

		-- -- print(event.damage)
		-- -- print(damage)
		-- local damage = event.damage * (100 - target:GetPhysicalArmorReduction()) / 100
		-- local heal = self:GetAbility():GetSpecialValueFor("lifesteal_bonus") * damage / 100

		-- if attacker:IsRealHero() then
		-- 	attacker:Heal(heal, attacker)
		-- end

		-- local lifesteal_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
		-- ParticleManager:SetParticleControl(lifesteal_pfx, 0, attacker:GetAbsOrigin())
		-- ParticleManager:ReleaseParticleIndex(lifesteal_pfx)

		if attacker:HasModifier("modifier_item_aghanims_shard") then
			local duration = self:GetAbility():GetSpecialValueFor("shard_debuff_duration")
			target:AddNewModifier(attacker, self:GetAbility(), "modifier_latch_shard", {duration = duration})
		end
	end
end

function modifier_latch:OnOrder(event)
	if IsServer() and event.unit == self:GetParent() and self.target and self.target:HasModifier("modifier_latch_target") and self.target:GetTeam() == self:GetParent():GetTeam() then 
		self.target:RemoveModifierByNameAndCaster("modifier_latch_target", self:GetCaster())
		self:Destroy()
	end
end

function modifier_latch:OnDestroy()
	if not IsServer() then return end

	local caster = self:GetCaster()

	caster:SetForceAttackTarget(nil)

	self:GetAbility():SetActivated(true)
	caster:SetParent(nil, "attach_origin")
	caster:SetAngles(0, caster:GetAngles().y, 0)
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
end

modifier_latch_target = class({})

if IsServer() then
	cast_orders = {
    	[DOTA_UNIT_ORDER_CAST_POSITION] = true,
    	[DOTA_UNIT_ORDER_CAST_TARGET] = true,
	}
end

function modifier_latch_target:IsPurgable()
	return false
end

function modifier_latch_target:DeclareFunctions()
	local funcs = {
		-- MODIFIER_EVENT_ON_ORDER
	}
	return funcs
end

function modifier_latch_target:OnOrder(event)
	if not IsServer() then return end

	local caster = self:GetCaster()
	if event.unit == caster and caster:IsRealHero() then
		if cast_orders[event.order_type] and not self:GetCaster():IsSilenced() then
			local ability = event.ability
			if ability then
				local castPosition
				if event.target then
					castPosition = event.target:GetAbsOrigin()
				else
					castPosition = event.new_pos
				end

				local maxCastRange = ability:GetCastRange(castPosition, caster) + caster:GetCastRangeIncrease()
				local distance = (caster:GetAbsOrigin() - castPosition):Length2D()

				-- Remove latch if Temporal Jump is used and within range
				if maxCastRange >= distance and ability:GetName() == "warp_beast_temporal_jump" then
					self:Destroy()
				-- Remove latch if Warp is used
				elseif caster:HasModifier("modifier_warp") and maxCastRange < distance then
					self:Destroy()
				end
			end
		end
	end
end

function modifier_latch_target:OnDestroy()
	if not IsServer() then return end
	
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_latch")
end



------------------------------------------------------------------------------------------------------------------
modifier_latch_scepter = class({})

function modifier_latch_scepter:IsDebuff() return false end
function modifier_latch_scepter:IsHidden() return false end
function modifier_latch_scepter:IsPurgable() return false end

function modifier_latch_scepter:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
	return funcs
end

function modifier_latch_scepter:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_scepter")
end

------------------------------------------------------------------------------------------------------------------
modifier_latch_shard = class({})

function modifier_latch_shard:IsDebuff() return true end
function modifier_latch_shard:IsHidden() return false end
function modifier_latch_shard:IsPurgable() return true end
function modifier_latch_shard:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_latch_shard:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end

function modifier_latch_shard:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("scepter_armor_debuff")
end