LinkLuaModifier("modifier_troy_the_arena", "heroes/troy/troy_the_arena.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_troy_the_arena_caster", "heroes/troy/troy_the_arena.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_troy_the_arena_check_position", "heroes/troy/troy_the_arena.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_troy_the_arena_barrier", "heroes/troy/troy_the_arena.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_troy_the_arena_knockback", "heroes/troy/troy_the_arena.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_troy_the_arena_pull", "heroes/troy/troy_the_arena.lua", LUA_MODIFIER_MOTION_HORIZONTAL)

troy_the_arena = troy_the_arena or class({})

function troy_the_arena:GetAOERadius()	
	return self:GetSpecialValueFor("field_radius")		
end

function troy_the_arena:OnSpellStart()			
	if IsServer() then
		-- Ability properties
		local target_point = self:GetCaster():GetAbsOrigin()
		local caster = self:GetCaster()
		local ability = self
		local formation_particle = "particles/units/heroes/hero_troy/troy_arena_stomp.vpcf"		

		-- Ability specials
		local formation_delay = ability:GetSpecialValueFor("delay")
		local field_radius = ability:GetSpecialValueFor("radius")
		local duration = ability:GetSpecialValueFor("duration") + caster:GetTalentValue("special_bonus_troy_arena_duration")
--		local vision_aoe = ability:GetSpecialValueFor("vision_aoe")

		-- Talent parameter adjustments
		if caster:FindAbilityByName("special_bonus_troy_instant_arena") and caster:FindAbilityByName("special_bonus_troy_instant_arena"):GetLevel() > 0 then
			formation_delay = 0
		else
			-- Cast sound
			caster:EmitSound("Hero_Jeremy.RedMistArena.Start")
		end

		-- Formation particle
		local formation_particle_fx = ParticleManager:CreateParticle(formation_particle, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(formation_particle_fx, 0, target_point)
		ParticleManager:SetParticleControl(formation_particle_fx, 1, Vector(field_radius, 1, 0))
		ParticleManager:SetParticleControl(formation_particle_fx, 2, Vector(formation_delay, 0, 0))
		--ParticleManager:SetParticleControl(formation_particle_fx, 4, Vector(1, 1, 1))
		--ParticleManager:SetParticleControl(formation_particle_fx, 15, target_point)

		-- Wait for formation to finish setting up
		Timers:CreateTimer(formation_delay, function()
			-- Apply thinker modifier on target location
			caster:AddNewModifier(caster, ability, "modifier_troy_the_arena_caster", {duration = duration})
			CreateModifierThinker(caster, ability, "modifier_troy_the_arena", {duration = duration, target_point_x = target_point.x, target_point_y = target_point.y, target_point_z = target_point.z, formation_particle_fx = formation_particle_fx}, target_point, caster:GetTeamNumber(), false)
			caster:EmitSound("Hero_Tusk.IceShards")
			-- Sound talent adjustments
			if caster:FindAbilityByName("special_bonus_troy_arena_duration") and caster:FindAbilityByName("special_bonus_troy_arena_duration"):GetLevel() > 0 then
				caster:EmitSound("Hero_Jeremy.RedMistArena.Erupt.Long")
			else
				caster:EmitSound("Hero_Jeremy.RedMistArena.Erupt")
			end
		end)
		-- self:SetActivated(false)

		-- Scepter effect
		if caster:HasScepter() then
			local dps_scepter = ability:GetSpecialValueFor("dps_scepter")
			Timers:CreateTimer(0, function()
				local units = FindUnitsInRadius(caster:GetTeamNumber(), target_point, nil, field_radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				for _, unit in pairs(units) do
					if unit:GetTeam() ~= caster:GetTeam() then
						ApplyDamage({victim = unit, attacker = caster, damage = dps_scepter, damage_type = DAMAGE_TYPE_MAGICAL})
					elseif unit == caster then
						ApplyDamage({victim = unit, attacker = caster, damage = dps_scepter, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL})
					end
				end
				duration = duration - 1
				if duration > 0 then
					return 1.0
				end
			end)
		end
	end
end

modifier_command_restricted = class({})

function modifier_command_restricted:IsHidden()
	return true
end

function modifier_command_restricted:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true}
end

---------------------------------------------------
--				Kinetic Field modifier
---------------------------------------------------
modifier_troy_the_arena = modifier_troy_the_arena or class({})

function modifier_troy_the_arena:IsHidden()	return true end
function modifier_troy_the_arena:IsPassive() return true end

function modifier_troy_the_arena:OnCreated(keys)
	if IsServer() then
		self.target = self:GetParent()
		self.field_radius = self:GetAbility():GetSpecialValueFor("radius")

		--fuck you vectors
		self.target_point = Vector(keys.target_point_x, keys.target_point_y, keys.target_point_z)
--		local vision_aoe = self:GetAbility():GetSpecialValueFor("vision_aoe")
		self.duration = self:GetDuration()

		-- local dummy = CreateUnitByName("npc_arena_dummy", self.target_point, true, nil, nil, self:GetCaster():GetTeamNumber())
		-- dummy:SetControllableByPlayer(self:GetCaster():GetPlayerOwnerID(), true)
		-- dummy:SetOwner(self:GetCaster())
		-- dummy:FindAbilityByName("arena_cast_error_outside"):UpgradeAbility(true)
		-- dummy:FindAbilityByName("arena_cast_error_inside"):UpgradeAbility(true)
		-- dummy:AddNewModifier(self:GetCaster(), nil, "modifier_kill", {duration = self.duration})
		-- dummy:AddNewModifier(self:GetCaster(), nil, "modifier_invulnerable", {})

		local particle_field = "particles/units/heroes/hero_troy/troy_arena_a3.vpcf" -- the field itself

--		AddFOWViewer(self:GetCaster():GetTeamNumber(), self.target:GetAbsOrigin(), vision_aoe, self.duration, false)
		ParticleManager:DestroyParticle(keys.formation_particle_fx, false)
		ParticleManager:ReleaseParticleIndex(keys.formation_particle_fx)		
		
		self.field_particle = ParticleManager:CreateParticle(particle_field, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(self.field_particle, 0, self.target_point)
		ParticleManager:SetParticleControl(self.field_particle, 1, Vector(self.field_radius, 1, 1))
		ParticleManager:SetParticleControl(self.field_particle, 2, Vector(self.duration, 0, 0))
		ParticleManager:SetParticleControl(self.field_particle, 4, Vector(1, 1, 1))
		ParticleManager:SetParticleControl(self.field_particle, 15, self.target_point)  

		if self:GetCaster():HasScepter() then
			local lava_field = "particles/units/heroes/hero_troy/troy_arena_lava.vpcf"

		end
		self:StartIntervalThink(FrameTime())
		self:CheckPositions()
	end
end

function modifier_troy_the_arena:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		local ability = self:GetAbility()
		ParticleManager:DestroyParticle(self.field_particle, false)
		ParticleManager:ReleaseParticleIndex(self.field_particle)
		-- caster:StopSound("Hero_Jeremy.RedMistArena.Start")
		-- caster:StopSound("Hero_Jeremy.RedMistArena.Erupt")
		-- caster:StopSound("Hero_Jeremy.RedMistArena.Erupt.Long")
		-- self:GetAbility():SetActivated(true)
	end
end

function modifier_troy_the_arena:OnIntervalThink()
	self:CheckPositions()
end

function modifier_troy_the_arena:CheckPositions()
	local nearbyUnits = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
		self.target_point,
		nil,
		800,
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		FIND_ANY_ORDER,
		false
	)
	for _,unit in pairs(nearbyUnits) do
		if not unit:HasModifier("modifier_troy_the_arena_check_position") then
			unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_troy_the_arena_check_position", {duration = self:GetRemainingTime(), target_point_x = self.target_point.x, target_point_y = self.target_point.y, target_point_z = self.target_point.z})
		end
	end

	local heroes = HeroList:GetAllHeroes()
	for _,hero in pairs(heroes) do
		if not hero:HasModifier("modifier_troy_the_arena_check_position") then
			hero:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_troy_the_arena_check_position", {duration = self:GetRemainingTime(), target_point_x = self.target_point.x, target_point_y = self.target_point.y, target_point_z = self.target_point.z})
		end
		local units = hero:GetAdditionalOwnedUnits()
		for _,unit in pairs(units) do
			if not unit:HasModifier("modifier_troy_the_arena_check_position") then
				unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_troy_the_arena_check_position", {duration = self:GetRemainingTime(), target_point_x = self.target_point.x, target_point_y = self.target_point.y, target_point_z = self.target_point.z})
			end
		end
	end
end

-- Kinetic Field check position
modifier_troy_the_arena_caster = modifier_troy_the_arena_caster or class({})

function modifier_troy_the_arena_caster:IsHidden() return false end

function modifier_troy_the_arena_caster:OnCreated(keys)
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_troy_the_arena_caster:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function modifier_troy_the_arena_caster:GetMinHealth()
	return 1
end

function modifier_troy_the_arena_caster:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_troy_the_arena_caster:OnTakeDamage( event )
	if IsServer() and event.unit == self:GetParent() then
		if event.inflictor and event.inflictor:GetName() == "axe_culling_blade" then
			if event.unit:GetHealth() < 2 then
				self:Destroy()
				ApplyDamage({victim = event.unit, attacker = event.attacker, damage = 1, damage_type = DAMAGE_TYPE_PURE, ability = event.ability})
			end
		end
	end
end

-- Kinetic Field check position
modifier_troy_the_arena_check_position = modifier_troy_the_arena_check_position or class({})

function modifier_troy_the_arena_check_position:IsHidden() return true end

function modifier_troy_the_arena_check_position:OnCreated(keys)
	--fuck you vectors
	self.target_point = Vector(keys.target_point_x, keys.target_point_y, keys.target_point_z)
end

function modifier_troy_the_arena_check_position:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_UNIT_MOVED,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}

	return funcs
end

function modifier_troy_the_arena_check_position:OnUnitMoved(keys)
	if IsServer() then
		local parent = self:GetParent()
		--OnUnitMoved actually responds to ALL units. Return immediately if not the modifier's parent.
		if keys.unit then
			if keys.unit:GetEntityIndex() ~= parent:GetEntityIndex() then
				return
			else
				self:kineticize(self:GetCaster(), parent, self:GetAbility())
			end
		else
			return
		end
	end
end

function modifier_troy_the_arena_check_position:OnAbilityFullyCast(keys)
	if IsServer() then
		local parent = self:GetParent()
		local caster =  self:GetCaster()
		local ability = self:GetAbility()
		--OnUnitMoved actually responds to ALL units. Return immediately if not the modifier's parent.
		if keys.unit then
			if keys.unit:GetEntityIndex() ~= parent:GetEntityIndex() then
				return
			else
				self:kineticize(caster, parent, ability)
			end
		else
			return
		end
	end
end


function modifier_troy_the_arena_check_position:kineticize(caster, target, ability)
	--if not target:HasModifier("modifier_troy_the_arena_knockback") then
		local radius = ability:GetSpecialValueFor("radius")
		local duration = ability:GetSpecialValueFor("duration")
		local wall_damage = ability:GetSpecialValueFor("wall_damage") + self:GetCaster():GetTalentValue("special_bonus_troy_arena_dps")
		local wall_hit_distance = ability:GetSpecialValueFor("wall_hit_distance")
		local wall_hit_height = ability:GetSpecialValueFor("wall_hit_height")
		local wall_hit_duration = ability:GetSpecialValueFor("wall_hit_duration")
		local center_of_field = self.target_point
		local modifier_barrier = "modifier_troy_the_arena_barrier"

		-- Solves for the target's distance from the border of the field (negative is inside, positive is outside)
		local distance = (target:GetAbsOrigin() - center_of_field):Length2D()
		local distance_from_border = distance - radius

		-- The target's angle in the world
		local target_angle = target:GetAnglesAsVector().y

		-- Solves for the target's angle in relation to the center of the circle in radians
		local origin_difference =  center_of_field - target:GetAbsOrigin()
		local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)

		-- Converts the radians to degrees.
		origin_difference_radian = origin_difference_radian * 180
		local angle_from_center = origin_difference_radian / math.pi
		-- Makes angle "0 to 360 degrees" as opposed to "-180 to 180 degrees" aka standard dota angles.
		angle_from_center = angle_from_center + 180.0	
		-- Checks if the target is inside the field
		if distance_from_border < 0 and math.abs(distance_from_border) <= 50 then
			target:AddNewModifier(caster, ability, modifier_barrier, {})

			local knockbackTable = {
				center_x = self.target_point.x,
				center_y = self.target_point.y,
				center_z = self.target_point.z,
				knockback_duration = wall_hit_duration,
				knockback_distance = -wall_hit_distance,
				knockback_height = wall_hit_height,
				should_stun = 1,
				duration = 0.6,
			}
			target:EmitSound("Hero_Jeremy.RedMistArena.Knockback")
			target:RemoveModifierByName("modifier_knockback")
			target:AddNewModifier(caster, ability, "modifier_knockback", knockbackTable)
			target:AddNewModifier(caster, ability, "modifier_troy_the_arena_knockback", {duration = wall_hit_duration})
			if target:GetTeam() ~= caster:GetTeam() then
				ApplyDamage({victim = target, attacker = caster, damage = wall_damage, damage_type = DAMAGE_TYPE_MAGICAL})
			end
		-- Checks if the target is outside the field,
		elseif distance_from_border > 0 and math.abs(distance_from_border) <= 60 then
			target:AddNewModifier(caster, ability, modifier_barrier, {})

			local knockbackTable = {
				center_x = self.target_point.x,
				center_y = self.target_point.y,
				center_z = self.target_point.z,
				knockback_duration = wall_hit_duration,
				knockback_distance = wall_hit_distance,
				knockback_height = wall_hit_height,
				should_stun = 1,
				duration = 0.6,
			}
			target:EmitSound("Hero_Jeremy.RedMistArena.Knockback")
			target:RemoveModifierByName("modifier_knockback")
			target:AddNewModifier(caster, ability, "modifier_knockback", knockbackTable)
			target:AddNewModifier(caster, ability, "modifier_troy_the_arena_knockback", {duration = wall_hit_duration})
			if target:GetTeam() ~= caster:GetTeam() then
				ApplyDamage({victim = target, attacker = caster, damage = wall_damage, damage_type = DAMAGE_TYPE_MAGICAL})
			end
		else
			-- Removes debuffs, so the unit can move freely
			if target:HasModifier(modifier_barrier) then
				target:RemoveModifierByName(modifier_barrier)
			end
			--self:Destroy()
		end
	--end
end

function modifier_troy_the_arena_check_position:OnDestroy()
	if IsServer() then

		if self:GetParent():HasModifier("modifier_troy_the_arena_barrier") then
			self:GetParent():RemoveModifierByName("modifier_troy_the_arena_barrier")
		end
	end
end

---------------------------------------------------
--			Kinetic Field barrier
---------------------------------------------------

modifier_troy_the_arena_barrier = modifier_troy_the_arena_barrier or class({})

function modifier_troy_the_arena_barrier:IsHidden()	return true end

function modifier_troy_the_arena_barrier:OnCreated()
	if not IsServer() then return end
end

function modifier_troy_the_arena_barrier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
	}

	return funcs
end

function modifier_troy_the_arena_barrier:GetModifierMoveSpeed_Absolute()
	return 0.1
end

---------------------------------------------------
--			Kinetic Field knockback
---------------------------------------------------

modifier_troy_the_arena_knockback = modifier_troy_the_arena_knockback or class({})

function modifier_troy_the_arena_knockback:IsHidden() return true end
function modifier_troy_the_arena_knockback:IsMotionController()	return true end
function modifier_troy_the_arena_knockback:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST end

function modifier_troy_the_arena_knockback:OnCreated( keys )
	if IsServer() then
		--self.target_point = Vector(keys.target_point_x, keys.target_point_y, keys.target_point_z)
		-- self:StartIntervalThink(FrameTime())	
	end
end

function modifier_troy_the_arena_knockback:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_OVERRIDE_ANIMATION }

	return funcs
end

function modifier_troy_the_arena_knockback:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_troy_the_arena_knockback:GetStatusEffectName()
	return "particles/status_fx/status_effect_electrical.vpcf"
end

function modifier_troy_the_arena_knockback:GetEffectName()
	return "particles/units/heroes/hero_troy/troy_arena_pushback.vpcf"
end

function modifier_troy_the_arena_knockback:GetEffectAttachType()
	return PATTACH_ABSORIGIN
end

function modifier_troy_the_arena_knockback:CheckState()
	local state = 
	{
		[MODIFIER_STATE_STUNNED] = IsServer()
	}

	return state
end

function modifier_troy_the_arena_knockback:OnIntervalThink()
	-- Check motion controllers
	if not self:CheckMotionControllers() then
		self:Destroy()
		return nil
	end

	-- Horizontal motion
	self:HorizontalMotion(self:GetParent(), FrameTime())	
end

function modifier_troy_the_arena_knockback:HorizontalMotion()
	if IsServer() then
		local knock_distance = 25
		local direction = (self:GetParent():GetAbsOrigin() - self.target_point):Normalized()
		local set_point = self:GetParent():GetAbsOrigin() + direction * knock_distance

		self:GetParent():SetAbsOrigin(Vector(set_point.x, set_point.y, GetGroundPosition(set_point, self:GetParent()).z))
		self:GetParent():SetUnitOnClearGround()
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), knock_distance, false)
	end
end

---------------------------------------------------
--			Kinetic Field pull
---------------------------------------------------

modifier_troy_the_arena_pull = modifier_troy_the_arena_pull or class({})

function modifier_troy_the_arena_pull:IsHidden()	return true end
function modifier_troy_the_arena_pull:IsMotionController()	return true end
function modifier_troy_the_arena_pull:GetMotionControllerPriority()	return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST end
function modifier_troy_the_arena_pull:OnCreated( keys )
	if IsServer() then
		self.target_point = Vector(keys.target_point_x, keys.target_point_y, keys.target_point_z)
		self:StartIntervalThink(FrameTime())	
	end
end

function modifier_troy_the_arena_pull:DeclareFunctions()
  local funcs = { MODIFIER_PROPERTY_OVERRIDE_ANIMATION }
  return funcs
end

function modifier_troy_the_arena_pull:GetOverrideAnimation()
  return ACT_DOTA_FLAIL
end

function modifier_troy_the_arena_pull:GetStatusEffectName()
  return "particles/status_fx/status_effect_electrical.vpcf"
end

function modifier_troy_the_arena_pull:GetEffectName()
  return "particles/units/heroes/hero_troy/troy_arena_pushback.vpcf"
end

function modifier_troy_the_arena_pull:GetEffectAttachType()
	return PATTACH_ABSORIGIN
end

function modifier_troy_the_arena_pull:OnIntervalThink()
	-- Check motion controllers
	if not self:CheckMotionControllers() then
		self:Destroy()
		return nil
	end
	-- Horizontal motion
	self:HorizontalMotion(self:GetParent(), FrameTime())	
end

function modifier_troy_the_arena_pull:HorizontalMotion()
	if IsServer() then
		local pull_distance = 15
		local direction = (self.target_point - self:GetParent():GetAbsOrigin()):Normalized()
		local set_point = self:GetParent():GetAbsOrigin() + direction * pull_distance
		self:GetParent():SetAbsOrigin(Vector(set_point.x, set_point.y, GetGroundPosition(set_point, self:GetParent()).z))
		self:GetParent():SetUnitOnClearGround()
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), pull_distance, false)
	end
end

function modifier_troy_the_arena_pull:CheckState()
	local state = 
	{
		[MODIFIER_STATE_STUNNED] = IsServer()
	}
	return state
end