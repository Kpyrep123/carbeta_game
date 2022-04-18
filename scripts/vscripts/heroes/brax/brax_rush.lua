--	Thunderboar's Rush
--	Concept by Brax
--	Implementation by Firetoad, 2018.08.13

LinkLuaModifier("modifier_brax_rush_motion", "heroes/brax/brax_rush.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_brax_rush_talent_far_cast_checker", "heroes/brax/brax_rush.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_brax_rush_talent_far_cast", "heroes/brax/brax_rush.lua", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_status_fire", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_cold", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_toxin", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_electro", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_status_viral", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_corrupt", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_gas", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_explosion", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_radiatoin", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_magnet", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_status_bleed", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_bash", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_piercing", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
brax_rush = class({})

-------------------------------

function brax_rush:GetIntrinsicModifierName()
	return "modifier_brax_rush_talent_far_cast_checker"
end

function brax_rush:OnAbilityPhaseStart()
	if not IsServer() then return end
	self:GetCaster():EmitSound("Brax.RushCast")
	return true
end

function brax_rush:OnAbilityPhaseInterrupted()
	if not IsServer() then return end
	self:GetCaster():StopSound("Brax.RushCast")	
end

function brax_rush:GetCastRange()
	if IsServer() then
		local cast_range = self:GetSpecialValueFor("rush_range") + self:GetCaster():GetCastRangeIncrease()
		if self:GetCaster():HasModifier("modifier_brax_rush_talent_far_cast") then
			return cast_range + 400
		else
			return cast_range
		end
	else
		local cast_range = self:GetSpecialValueFor("rush_range")
		if self:GetCaster():HasModifier("modifier_brax_rush_talent_far_cast") then
			return cast_range + 400
		else
			return cast_range
		end
	end
end

function brax_rush:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target_point = self:GetCursorPosition()

		-- Motion geometry
		local direction = target_point - caster:GetAbsOrigin()
		local distance = direction:Length2D()
		local speed = self:GetSpecialValueFor("rush_speed")
		local x_motion_tick = direction:Normalized().x * speed * 0.03
		local y_motion_tick = direction:Normalized().y * speed * 0.03

		-- Play cast sound
		--caster:EmitSound("Hero_Spirit_Breaker.NetherStrike.End")

		-- Apply motion controller
		caster:AddNewModifier(caster, self, "modifier_brax_rush_motion", {x_tick = x_motion_tick, y_tick = y_motion_tick, target_x = target_point.x, target_y = target_point.y})
	end
end

-------------------------------

modifier_brax_rush_talent_far_cast_checker = class({})

function modifier_brax_rush_talent_far_cast_checker:IsHidden() return true end
function modifier_brax_rush_talent_far_cast_checker:IsDebuff() return false end
function modifier_brax_rush_talent_far_cast_checker:IsPurgable() return false end

function modifier_brax_rush_talent_far_cast_checker:OnCreated(keys)
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_brax_rush_talent_far_cast_checker:OnIntervalThink()
	if IsServer() then
		local talent_ability = self:GetParent():FindAbilityByName("special_bonus_brax_3")
		if talent_ability and talent_ability:GetLevel() > 0 and not self:GetParent():HasModifier("modifier_brax_rush_talent_far_cast") then
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_brax_rush_talent_far_cast", {})
		end
	end
end

-------------------------------

modifier_brax_rush_talent_far_cast = class({})

function modifier_brax_rush_talent_far_cast:IsHidden() return true end
function modifier_brax_rush_talent_far_cast:IsDebuff() return false end
function modifier_brax_rush_talent_far_cast:IsPurgable() return false end

-------------------------------

modifier_brax_rush_motion = class({})

function modifier_brax_rush_motion:IsHidden() return true end
function modifier_brax_rush_motion:IsDebuff() return false end
function modifier_brax_rush_motion:IsPurgable() return false end
function modifier_brax_rush_motion:GetPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST end

function modifier_brax_rush_motion:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_DISABLE_TURNING
	}
	return funcs
end

function modifier_brax_rush_motion:GetModifierDisableTurning()
	return 1
end

function modifier_brax_rush_motion:GetOverrideAnimation()
	return ACT_DOTA_OVERRIDE_ABILITY_4
end

function modifier_brax_rush_motion:GetEffectName()
	return "particles/units/heroes/hero_thunderboar/thunderous_rush.vpcf"
end

function modifier_brax_rush_motion:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_brax_rush_motion:CheckState()
	if IsServer() then
		local state = {
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_SILENCED] = true
		}
		return state
	end
end

function modifier_brax_rush_motion:OnCreated(keys)
	if IsServer() then
		self.x_tick = keys.x_tick
		self.y_tick = keys.y_tick
		self.target_x = keys.target_x
		self.target_y = keys.target_y

		if self:ApplyHorizontalMotionController() == false then
			self:Destroy()
			return
		end
	end
end

function modifier_brax_rush_motion:OnHorizontalMotionInterrupted()
	self:Destroy()
end

function modifier_brax_rush_motion:UpdateHorizontalMotion(parent, delta_time)
	if IsServer() then
		local current_pos = parent:GetAbsOrigin()
		GridNav:DestroyTreesAroundPoint(current_pos, 200, false)
		if (math.abs(current_pos.x - self.target_x) <= math.abs(self.x_tick)) or (math.abs(current_pos.y - self.target_y) <= math.abs(self.y_tick)) then
			parent:SetAbsOrigin(GetGroundPosition(Vector(self.target_x, self.target_y, 0), parent))
			self:Destroy()
		else
			parent:SetAbsOrigin(current_pos + Vector(self.x_tick, self.y_tick, 0))
		end
	end
end

function modifier_brax_rush_motion:OnDestroy()
	if IsServer() then
		local caster = self:GetParent()
		local ability = self:GetAbility()
		local landing_point = caster:GetAbsOrigin()
		local pull_range = ability:GetSpecialValueFor("pull_range")
		local pull_end_radius = ability:GetSpecialValueFor("pull_end_radius")

		-- Resolve landing
		caster:RemoveHorizontalMotionController(self)
		caster:RemoveVerticalMotionController(self)
		ResolveNPCPositions(landing_point, 128)
		GridNav:DestroyTreesAroundPoint(landing_point, 200, false)
		caster:EmitSound("Hero_StormSpirit.ElectricVortexCast")

		-- Impact effect
		local impact_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_thunderboar/thunderous_rush_impact.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(impact_pfx, 0, landing_point)
		ParticleManager:SetParticleControl(impact_pfx, 1, landing_point + caster:GetForwardVector() * 300)
		ParticleManager:ReleaseParticleIndex(impact_pfx)

		-- Scepter effect
		if caster:HasModifier("modifier_item_aghanims_shard") then
			local enemies = FindUnitsInRadius(caster:GetTeam(), landing_point + caster:GetForwardVector() * 150, nil, ability:GetSpecialValueFor("scepter_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				ability:KnockUp(enemy)
			end
		else

			-- Instant projectile
			local rush_projectile = {
				Ability				= self:GetAbility(),
				EffectName			= nil,
				vSpawnOrigin		= caster:GetAbsOrigin(),
				fDistance			= pull_range,
				fStartRadius		= 64,
				fEndRadius			= pull_end_radius,
				Source				= caster,
				bHasFrontalCone		= true,
				bReplaceExisting	= false,
				iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
				iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				fExpireTime 		= GameRules:GetGameTime() + 10.0,
				bDeleteOnHit		= false,
				vVelocity			= caster:GetForwardVector() * 10000,
				bProvidesVision		= false,
			}
			ProjectileManager:CreateLinearProjectile(rush_projectile)
			rush_projectile.fStartRadius = pull_end_radius
			rush_projectile.fDistance = pull_end_radius
			rush_projectile.vSpawnOrigin = caster:GetAbsOrigin() - caster:GetForwardVector() * pull_end_radius * 0.75
			ProjectileManager:CreateLinearProjectile(rush_projectile)
		end
	end
end

function brax_rush:OnProjectileHit(target, location)
	if IsServer() then
		self:KnockUp(target)
	end
end

function brax_rush:KnockUp(target)
	if target then
		local caster = self:GetCaster()
		local caster_loc = caster:GetAbsOrigin()
		local target_loc = target:GetAbsOrigin()
		local damage = self:GetSpecialValueFor("damage")
		local pull_duration = self:GetSpecialValueFor("pull_duration")
		ApplyDamage({victim = target, attacker = caster, ability = self, damage = self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_MAGICAL})

		-- Draw particle
		local pull_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_thunderboar/thunderous_rush_grap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(pull_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_loc, true)
		Timers:CreateTimer(pull_duration, function()
			ParticleManager:DestroyParticle(pull_pfx, false)
			ParticleManager:ReleaseParticleIndex(pull_pfx)
		end)

		-- Knockback
		local knockback_destination = caster_loc + caster:GetForwardVector() * 150
		local knockback_vector = (knockback_destination - target_loc)
		local knockback_center = target_loc - knockback_vector:Normalized() * 150
		local knockback_table = {
			center_x = knockback_center.x,
			center_y = knockback_center.y,
			center_z = knockback_center.z,
			knockback_duration = pull_duration,
			knockback_distance = knockback_vector:Length2D(),
			knockback_height = 0,
			should_stun = 1,
			duration = pull_duration
		}
		target:RemoveModifierByName("modifier_knockback")
		target:AddNewModifier(caster, self, "modifier_knockback", knockback_table)
		local chance = self:GetSpecialValueFor("status_chance")
		if RollPercentage(chance) then 
			if target:HasModifier("modifier_status_fire") then 
				local fire = target:FindModifierByName("modifier_status_fire"):GetStackCount()
				local mod = target:AddNewModifier(self:GetCaster(), self, "modifier_status_radiatoin", {duration = 5})
				target:RemoveModifierByName("modifier_status_fire")
				mod:SetStackCount(fire + 1) 
			elseif target:HasModifier("modifier_status_cold") then 
				local cold = target:FindModifierByName("modifier_status_cold"):GetStackCount()
				local mod = target:AddNewModifier(self:GetCaster(), self, "modifier_status_magnet", {duration = 5})
				mod:SetStackCount(cold + 1)
				target:RemoveModifierByName("modifier_status_cold")
			elseif target:HasModifier("modifier_status_toxin") then 
				local toxin = target:FindModifierByName("modifier_status_toxin"):GetStackCount()
				local mod = target:AddNewModifier(self:GetCaster(), self, "modifier_status_corrupt", {duration = 5})
				mod:SetStackCount(toxin + 1)
				target:RemoveModifierByName("modifier_status_toxin")
			else
				local mod = target:AddNewModifier(self:GetCaster(), self, "modifier_status_electro", {duration = 5})
				mod:SetStackCount(mod:GetStackCount() + 1)
			end
		end
	end
end