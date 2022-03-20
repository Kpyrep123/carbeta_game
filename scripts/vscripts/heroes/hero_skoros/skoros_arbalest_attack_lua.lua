if skoros_Arbalest_Attack_lua == nil then
	skoros_Arbalest_Attack_lua = class({})
end

LinkLuaModifier( "modifier_arbalest_thinker", "heroes/hero_skoros/skoros_Arbalest_Attack_lua.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arbalest_cooldown", "heroes/hero_skoros/skoros_Arbalest_Attack_lua.lua" ,LUA_MODIFIER_MOTION_NONE )

function skoros_Arbalest_Attack_lua:OnSpellStart()
	if self:GetCursorPosition() and self:GetCaster():HasModifier("Arbalest") then
		local caster = self:GetCaster()
		local point = self:GetCursorPosition()
		
		local origin = caster:GetAbsOrigin()
		local casterVec = (point - origin):Normalized()

		if origin == point then 
			casterVec = caster:GetForwardVector()
		end

		local projectileSpeed = self:GetSpecialValueFor("projectile_speed")
		local distance = self:GetSpecialValueFor("bonus_range")
		local radius = self:GetSpecialValueFor("aoe")
		local visionRadius = self:GetSpecialValueFor("target_vision_radius")

		local arbalest = caster:FindAbilityByName("skoros_Arbalest")
		local charges = caster:GetModifierStackCount("Arbalest", arbalest)

		if charges == 1 then 
			caster:RemoveModifierByName("Arbalest")
		else
			caster:SetModifierStackCount("Arbalest",arbalest,charges - 1)
			local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)	
			for _,unit in pairs(units) do
				if unit:GetUnitName() == caster:GetUnitName() and unit:GetPlayerID() == caster:GetPlayerID() and unit:HasModifier("Arbalest") then
					unit:SetModifierStackCount("Arbalest",ability,charges - 1)
				end
			end
		end

		local slowDuration = self:GetCaster().attackspeed * self:GetCaster().attackFinishPct
		caster:AddNewModifier(caster,self,"modifier_arbalest_cooldown",{Duration = slowDuration})
		local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)	
		for _,unit in pairs(units) do
			if unit:GetUnitName() == caster:GetUnitName() and unit:GetPlayerID() == caster:GetPlayerID() and unit:HasModifier("Arbalest") then
				unit:AddNewModifier(caster,self,"modifier_arbalest_cooldown",{Duration = slowDuration})
			end
		end
		caster:Stop()
		caster:EmitSound("Hero_Clinkz.SearingArrows")
		-- Creating the projectile
		local projectileTable =
		{
			EffectName = "particles/skoros/skoros_arbalest_attack.vpcf",
			Ability = self,
			vSpawnOrigin = origin,
			vVelocity = Vector( casterVec.x * projectileSpeed, casterVec.y * projectileSpeed, 0 ),
			fDistance = distance,
			fStartRadius = radius,
			fEndRadius = radius,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = true,
			bProvidesVision = true,
			iVisionRadius = visionRadius,
			iVisionTeamNumber = caster:GetTeamNumber(),
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
		}
		-- Saving the projectile ID so that we can destroy it later
		projectile_id = ProjectileManager:CreateLinearProjectile( projectileTable )
	end
end

function skoros_Arbalest_Attack_lua:GetIntrinsicModifierName()
	return "modifier_arbalest_thinker"
end

function skoros_Arbalest_Attack_lua:OnProjectileHit( hTarget, vLocation )
	local caster = self:GetCaster()
	local target = hTarget
	local ability = self
	local vision = ability:GetSpecialValueFor("target_vision_radius")
	local duration = ability:GetSpecialValueFor("target_vision_duration")

	if target then
		target:EmitSound("Hero_Clinkz.SearingArrows.Impact")
		caster:PerformAttack( target, true, true, true, false, false, false, false )
		AddFOWViewer(caster:GetTeamNumber(),target:GetAbsOrigin(), vision , duration, true)
		return true
	end
end

function skoros_Arbalest_Attack_lua:GetCooldown( nLevel )
	return self:GetCaster().attackspeed * self:GetCaster().attackFinishPct
end

function skoros_Arbalest_Attack_lua:GetPlaybackRateOverride()
	return 1.7 / self:GetCaster().attackspeed
end

function skoros_Arbalest_Attack_lua:GetCastAnimation()
	return ACT_DOTA_ATTACK
end

function skoros_Arbalest_Attack_lua:IsHiddenAbilityCastable(  )
	return true
end

if modifier_arbalest_thinker == nil then modifier_arbalest_thinker = class({}) end

function modifier_arbalest_thinker:IsHidden()
	return true
end

function modifier_arbalest_thinker:OnCreated()
	if IsServer() then
		local attackTime = self:GetCaster():GetBaseAttackTime()
		local attackStart = 0.700000
		local attackFinish = attackTime - attackStart

		self:GetCaster().attackStartPct = attackStart / attackTime
		self:GetCaster().attackFinishPct = attackFinish / attackTime
		self:GetCaster().attackspeed = self:GetCaster():GetSecondsPerAttack()

		self:StartIntervalThink(0.1)
	end
	return true
end

function modifier_arbalest_thinker:OnIntervalThink()
	self:GetCaster().attackspeed = self:GetCaster():GetSecondsPerAttack()
	if not self:GetAbility():IsInAbilityPhase() then
		self:GetAbility():SetOverrideCastPoint(self:GetCaster().attackspeed * self:GetCaster().attackStartPct)
	end
end

if modifier_arbalest_cooldown == nil then modifier_arbalest_cooldown = class({}) end

function modifier_arbalest_cooldown:IsHidden()
	return false
end

function modifier_arbalest_cooldown:CheckState()
	return {[MODIFIER_STATE_DISARMED] = true}
end