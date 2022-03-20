--	Troy's Battle Lunge
--	by Firetoad, 2018.05.24

LinkLuaModifier("modifier_battle_lunge_pre_animation", "heroes/troy/troy_battle_lunge.lua", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_battle_lunge_motion", "heroes/troy/troy_battle_lunge.lua", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_battle_lunge_slow", "heroes/troy/troy_battle_lunge.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_battle_lunge_status_resist", "heroes/troy/troy_battle_lunge.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_battle_lunge_talent_cast_range_checker", "heroes/troy/troy_battle_lunge.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_battle_lunge_talent_cast_range", "heroes/troy/troy_battle_lunge.lua", LUA_MODIFIER_MOTION_NONE)

troy_battle_lunge = class({})

-------------------------------

function troy_battle_lunge:GetCastRange()
	local cast_range = self:GetSpecialValueFor("cast_range")
	if self:GetCaster():HasModifier("modifier_battle_lunge_talent_cast_range") then
		cast_range = cast_range + 300
	end
	return cast_range
end

function troy_battle_lunge:GetIntrinsicModifierName()
	return "modifier_battle_lunge_talent_cast_range_checker"
end

function troy_battle_lunge:OnAbilityPhaseStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target_point = self:GetCursorPosition()

	-- Motion geometry
	local direction = target_point - caster:GetAbsOrigin()
	local distance = direction:Length2D()
	local duration = self:GetSpecialValueFor("lunge_duration")

	-- Cast animation
	caster:AddNewModifier(caster, self, "modifier_battle_lunge_pre_animation", {duration = 0.8})

	return true
end

function troy_battle_lunge:OnAbilityPhaseInterrupted()
	if not IsServer() then return end
	self:GetCaster():RemoveModifierByName("modifier_battle_lunge_pre_animation")
end

function troy_battle_lunge:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target_point = self:GetCursorPosition()
		caster:RemoveModifierByName("modifier_battle_lunge_pre_animation")

		-- Motion geometry
		local direction = target_point - caster:GetAbsOrigin()
		local distance = direction:Length2D()
		local cast_damage = caster:GetMaxHealth() * self:GetSpecialValueFor("health_cost") * 0.01
		local duration = self:GetSpecialValueFor("lunge_duration")
		local x_motion_tick = direction.x * 0.03 / duration
		local y_motion_tick = direction.y * 0.03 / duration
		local height = self:GetSpecialValueFor("lunge_height")
		height = math.max(height, height * distance / 300)

		-- Pay health cost
		ApplyDamage({victim = caster, attacker = caster, damage = cast_damage, 
			damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS})

		-- Play lunge particle & sound
		caster:EmitSound("Hero_Leshrac.Lightning_Storm")
		local lunge_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_troy/troy_battle_lunge.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(lunge_pfx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(lunge_pfx, 1, target_point)
		ParticleManager:SetParticleControl(lunge_pfx, 2, Vector(1, 1, 1))
		ParticleManager:ReleaseParticleIndex(lunge_pfx)

		-- Add immolation stacks from the health cost
		if caster:FindAbilityByName("troy_immolation") then
			local immolation_ability = caster:FindAbilityByName("troy_immolation")
			if immolation_ability:GetLevel() > 0 then
				local duration = immolation_ability:GetSpecialValueFor("duration") + caster:GetTalentValue("special_bonus_troy_immolation_duration")
				caster:AddNewModifier(caster, immolation_ability, "modifier_immolation_stacks", {duration = duration}):SetStackCount(cast_damage)
			end
		end

		-- Apply motion controller
		caster:AddNewModifier(caster, self, "modifier_battle_lunge_motion", {duration = duration, x_tick = x_motion_tick, y_tick = y_motion_tick, height = height, z_max_time = duration, distance = distance})
	end
end

function troy_battle_lunge:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

-------------------------------

modifier_battle_lunge_talent_cast_range_checker = class({})

function modifier_battle_lunge_talent_cast_range_checker:IsHidden() return true end
function modifier_battle_lunge_talent_cast_range_checker:IsDebuff() return false end
function modifier_battle_lunge_talent_cast_range_checker:IsPurgable() return false end

function modifier_battle_lunge_talent_cast_range_checker:OnCreated(keys)
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_battle_lunge_talent_cast_range_checker:OnIntervalThink()
	if IsServer() then
		local talent_ability = self:GetParent():FindAbilityByName("special_bonus_troy_battle_lunge_range")
		if talent_ability and talent_ability:GetLevel() > 0 and not self:GetParent():HasModifier("modifier_battle_lunge_talent_cast_range") then
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_battle_lunge_talent_cast_range", {})
		end
	end
end

-------------------------------

modifier_battle_lunge_talent_cast_range = class({})

function modifier_battle_lunge_talent_cast_range:IsHidden() return true end
function modifier_battle_lunge_talent_cast_range:IsDebuff() return false end
function modifier_battle_lunge_talent_cast_range:IsPurgable() return false end

-------------------------------

modifier_battle_lunge_pre_animation = class({})

function modifier_battle_lunge_pre_animation:IsHidden() return true end
function modifier_battle_lunge_pre_animation:IsDebuff() return false end
function modifier_battle_lunge_pre_animation:IsPurgable() return false end
function modifier_battle_lunge_pre_animation:GetPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST end

function modifier_battle_lunge_pre_animation:DeclareFunctions()
	local funcs = {
		-- MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		-- MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE
	}
	return funcs
end

function modifier_battle_lunge_pre_animation:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end

function modifier_battle_lunge_pre_animation:GetOverrideAnimationRate()
	return 0.65
end

-------------------------------

modifier_battle_lunge_motion = class({})

function modifier_battle_lunge_motion:IsHidden() return true end
function modifier_battle_lunge_motion:IsDebuff() return false end
function modifier_battle_lunge_motion:IsPurgable() return false end
function modifier_battle_lunge_motion:GetPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST end

function modifier_battle_lunge_motion:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
		MODIFIER_PROPERTY_DISABLE_TURNING
	}
	return funcs
end

function modifier_battle_lunge_motion:GetModifierDisableTurning()
	return 1
end

function modifier_battle_lunge_motion:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_1_END
end


function modifier_battle_lunge_motion:GetOverrideAnimationRate()
	return 0.8
end

function modifier_battle_lunge_motion:CheckState()
	if IsServer() then
		local state = {
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true
		}
		return state
	end
end

function modifier_battle_lunge_motion:OnCreated(keys)
	if IsServer() then
		self.x_tick = keys.x_tick
		self.y_tick = keys.y_tick
		-- self.z_tick = keys.z_tick
		self.z_max_time = keys.z_max_time
		self.z_time = 0

		self.origin = self:GetParent():GetAbsOrigin()
		self.direction = self:GetParent():GetForwardVector()
		self.velocity = keys.distance / keys.z_max_time
		self.jump = 0
		self.height = keys.height
		-- self.fall = keys.jump / (18 * keys.z_max_time)

		-- Deactivate ultimate during the jump
		if self:GetCaster():FindAbilityByName("troy_the_arena") then
			self:GetCaster():FindAbilityByName("troy_the_arena"):SetActivated(false)
		end

		if self:ApplyHorizontalMotionController() == false then
			self:Destroy()
			return
		end

		if self:ApplyVerticalMotionController() == false then
			self:Destroy()
			return
		end
	end
end

function modifier_battle_lunge_motion:OnHorizontalMotionInterrupted()
	self:Destroy()
end

function modifier_battle_lunge_motion:OnVerticalMotionInterrupted()
	self:Destroy()
end

function modifier_battle_lunge_motion:UpdateHorizontalMotion(parent, delta_time)
	if IsServer() then
		parent:SetAbsOrigin(parent:GetAbsOrigin() + Vector(self.x_tick, self.y_tick, self.jump))
	end
end

function modifier_battle_lunge_motion:UpdateVerticalMotion(parent, delta_time)
	if IsServer() then
		self.z_time = self.z_time + delta_time
		local origin = parent:GetAbsOrigin()
		local ground_position = GetGroundPosition(origin, parent)
		self.jump = 4 * self.height * self.z_time * (self.z_max_time - self.z_time)
		parent:SetAbsOrigin(ground_position + Vector(0,0,self.jump))

		-- self.jump = self.jump - self.fall
		-- print(self.jump)
		-- if self.z_time > self.z_max_time then
		-- 	parent:SetAbsOrigin(parent:GetAbsOrigin() - Vector(0, 0, self.z_tick))
		-- else
		-- 	parent:SetAbsOrigin(parent:GetAbsOrigin() + Vector(0, 0, self.z_tick))
		-- end

		--[[


		m = 0.6

		d = 50 
		x = 0
		y = 0

		d = 0
		x = 0.3
		y = max jump height

		d = -50
		x = 0.6
		y = 0
		


		]]
	end
end

function modifier_battle_lunge_motion:OnDestroy()
	if IsServer() then
		local caster = self:GetParent()
		local ability = self:GetAbility()
		local landing_point = caster:GetAbsOrigin()
		local slow_duration = ability:GetSpecialValueFor("duration")
		local initial_slow = ability:GetSpecialValueFor("movement_slow")
		local creep_damage_pct = ability:GetSpecialValueFor("creep_damage_pct")
		local radius = ability:GetSpecialValueFor("radius")

		-- Reactivate ultimate after the jump
		if caster:FindAbilityByName("troy_the_arena") then
			caster:FindAbilityByName("troy_the_arena"):SetActivated(true)
		end

		-- Resolve landing
		local angles = caster:GetAngles()
		-- caster:SetAngles(0, angles.y, angles.z)
		caster:RemoveHorizontalMotionController(self)
		caster:RemoveVerticalMotionController(self)
		ResolveNPCPositions(landing_point, 128)
		GridNav:DestroyTreesAroundPoint(landing_point, 300, false)


		-- Play impact particle
		local impact_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_troy/troy_battle_lunge_impact.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(impact_pfx, 0, landing_point)
		ParticleManager:SetParticleControl(impact_pfx, 1, landing_point)
		ParticleManager:SetParticleControl(impact_pfx, 2, Vector(radius, 1, 1))
		ParticleManager:ReleaseParticleIndex(impact_pfx)

		-- Play impact sound
		caster:StopSound("Hero_Leshrac.Split_Earth")
		caster:EmitSound("Hero_Leshrac.Split_Earth")
		-- Timers:CreateTimer(1.2, function()
		-- 	caster:StopSound("Hero_Jeremy.BattleLunge.Impact")
		-- end)

		-- Hero effects
		local heroes = FindUnitsInRadius(caster:GetTeamNumber(), landing_point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		if #heroes > 0 then
			caster:Heal(caster:GetMaxHealth() * #heroes * ability:GetSpecialValueFor("heal_hero") * 0.01, caster)
		else
			caster:RemoveModifierByName("modifier_battle_lunge_slow")
			caster:AddNewModifier(caster, ability, "modifier_battle_lunge_slow", {duration = slow_duration, slow = math.abs(initial_slow)})
		end

		-- Enemy effects
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), landing_point, nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,enemy in pairs(enemies) do
			enemy:RemoveModifierByName("modifier_battle_lunge_slow")
			enemy:AddNewModifier(caster, ability, "modifier_battle_lunge_slow", {duration = slow_duration, slow = math.abs(initial_slow)})
			if caster:HasShard() then 
				caster:PerformAttack(enemy, true, true, true, true, false, false, true)
			end
			if enemy:IsHero() then
				ApplyDamage({victim = enemy, attacker = caster, damage = ability:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_MAGICAL})
			else
				ApplyDamage({victim = enemy, attacker = caster, damage = ability:GetSpecialValueFor("damage") * creep_damage_pct * 0.01, damage_type = DAMAGE_TYPE_MAGICAL})
			end
		end
		if #enemies > 0 then
			caster:RemoveModifierByName("modifier_battle_lunge_status_resist")
			caster:AddNewModifier(caster, ability, "modifier_battle_lunge_status_resist", {duration = slow_duration, resist = #heroes * ability:GetSpecialValueFor("status_resist_hero") + (#enemies - #heroes) * ability:GetSpecialValueFor("status_resist_creep")})
		end
	end
end

-------------------------------

modifier_battle_lunge_slow = class({})

function modifier_battle_lunge_slow:IsHidden() return false end
function modifier_battle_lunge_slow:IsDebuff() return true end
function modifier_battle_lunge_slow:IsPurgable() return true end

function modifier_battle_lunge_slow:OnCreated(keys)
	if IsServer() then
		self.slow = keys.slow
		self.slow_step = self.slow * 0.2 / self:GetDuration()
		self:SetStackCount(self.slow)
		self:StartIntervalThink(0.2)
	end
end

function modifier_battle_lunge_slow:OnIntervalThink()
	if IsServer() then
		self.slow = math.max(self.slow - self.slow_step, 0)
		self:SetStackCount(self.slow)
	end
end

function modifier_battle_lunge_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}

	return funcs
end

function modifier_battle_lunge_slow:GetModifierMoveSpeedBonus_Percentage()
	return (-1) * self:GetStackCount()
end

-------------------------------

modifier_battle_lunge_status_resist = class({})

function modifier_battle_lunge_status_resist:IsHidden() return false end
function modifier_battle_lunge_status_resist:IsDebuff() return false end
function modifier_battle_lunge_status_resist:IsPurgable() return false end
function modifier_battle_lunge_status_resist:DeclareFunctions() 	
	local funcs = {
					MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
					MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
				  }
	return funcs 
end
function modifier_battle_lunge_status_resist:OnCreated(keys)
	if IsServer() then
		self.resist = keys.resist
		self:SetStackCount(self.resist)
	end
end

function modifier_battle_lunge_status_resist:GetModifierPhysicalArmorBonus()
	return self:GetStackCount()
end

function modifier_battle_lunge_status_resist:GetModifierConstantHealthRegen()
	if self:GetCaster():HasTalent("special_bonus_troy_arena_dps") then 
		return self:GetStackCount()
	end
end