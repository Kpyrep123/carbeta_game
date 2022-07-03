-- Author: Shush
-- Date: 2/5/2017

------------------------------
--     HELPER FUNCTIONS     --
------------------------------

local function ApplyInflammableToRemoteMines(caster, range, remote_mines)

	if not remote_mines then
		-- Find Remote Mines in the explosion radius
		remote_mines = FindUnitsInRadius(caster:GetTeamNumber(),
										caster:GetAbsOrigin(),
										nil,
										range,
										DOTA_UNIT_TARGET_TEAM_FRIENDLY,
										DOTA_UNIT_TARGET_OTHER,
										DOTA_UNIT_TARGET_FLAG_NONE,
										FIND_ANY_ORDER,
										false)
	end

	local modifier_inflammable = "modifier_imba_remote_mine_inflammable"
	local detonate_ability = "imba_techies_remote_mines_pinpoint_detonation"

	-- Give them inflammable stacks
	for _,remote_mine in pairs(remote_mines) do
		if remote_mine:GetUnitName() == "npc_imba_techies_remote_mines" then

			local modifier_inflammable_handler = remote_mine:FindModifierByName(modifier_inflammable)
			if not modifier_inflammable_handler then
				local detonate_ability_handler = remote_mine:FindAbilityByName(detonate_ability)
				if detonate_ability_handler then
					local inflammable_duration = detonate_ability_handler:GetSpecialValueFor("inflammable_duration")
					modifier_inflammable_handler = remote_mine:AddNewModifier(caster, detonate_ability_handler, modifier_inflammable, {duration = inflammable_duration})
				end
			end

			-- Nil Check
			if modifier_inflammable_handler then
				modifier_inflammable_handler:IncrementStackCount()
				modifier_inflammable_handler:ForceRefresh()
			end
		end
	end
end

local function RefreshElectroCharge(unit)
	local modifier_electrocharge = "modifier_imba_statis_trap_electrocharge"

	-- If the enemy has Electrocharge (from Stasis Trap), refresh it and add a stack
	local modifier_electrocharge_handler = unit:FindModifierByName(modifier_electrocharge)
	if modifier_electrocharge_handler then
		modifier_electrocharge_handler:IncrementStackCount()
		modifier_electrocharge_handler:ForceRefresh()
	end
end

local function PlantProximityMine(caster, ability, spawn_point, big_boom)
	-- Create the mine unit
	local mine_name
	if big_boom then
		mine_name = "explosive_mech_big_boom"
	else
		mine_name = "explosive_mech"
	end

	local mine = CreateUnitByName(mine_name, spawn_point, true, caster, caster, caster:GetTeamNumber())

	mine:AddRangeIndicator(caster, nil, nil, ability:GetAOERadius(), 150, 22, 22, false, false, false)

	-- Set the mine's team to be the same as the caster
	local playerID = caster:GetPlayerID()
	mine:SetControllableByPlayer(playerID, true)

	-- Set the mine's owner to be the caster
	mine:SetOwner(caster)

	-- Set the mine's modifier AI
	mine:AddNewModifier(caster, ability, "modifier_imba_proximity_mine", {})
end

------------------------------
--     PROXIMITY MINE       --
------------------------------


imba_techies_land_mines = imba_techies_land_mines or class({})

function imba_techies_land_mines:IsHiddenWhenStolen() return false end
function imba_techies_land_mines:IsNetherWardStealable() return false end


function imba_techies_land_mines:GetManaCost(level)
	-- Ability properties
	local caster = self:GetCaster()
	local modifier_charges = "modifier_generic_charges"

	-- Ability specials
	local mana_increase_per_stack = self:GetSpecialValueFor("mana_increase_per_stack")

	-- Find stack count
	stacks = caster:GetModifierStackCount(modifier_charges, caster)

	local mana_cost = 110 + mana_increase_per_stack * stacks
	return mana_cost
end

function imba_techies_land_mines:CastFilterResultLocation(location)
	if IsServer() then
		-- Ability properties
		local caster = self:GetCaster()
		local ability = self

		-- Ability specials
		local mine_distance = ability:GetSpecialValueFor("mine_distance")
		local trigger_range = ability:GetSpecialValueFor("radius")

		-- #1 Talent: Trigger range increase
		trigger_range = trigger_range + caster:FindTalentValue("special_bonus_imba_techies_1")

		-- Radius
		local radius = mine_distance + trigger_range

		-- Look for nearby mines
		local friendly_units = FindUnitsInRadius(caster:GetTeamNumber(),
												location,
												nil,
												radius,
												DOTA_UNIT_TARGET_TEAM_FRIENDLY,
												DOTA_UNIT_TARGET_OTHER,
												DOTA_UNIT_TARGET_FLAG_NONE,
												FIND_ANY_ORDER,
												false)

		local mine_found = false

		-- Search and see if mines were found
		for _,unit in pairs(friendly_units) do
			local unitName = unit:GetUnitName()
			if unitName == "explosive_mech" or unitName == "explosive_mech_big_boom" then
				mine_found = true
				break
			end
		end

		if mine_found then
			return UF_FAIL_CUSTOM
		else
			return UF_SUCCESS
		end
	end
end

function imba_techies_land_mines:GetCustomCastErrorLocation(location)
	return "Cannot place mine in range of other mines"
end

function imba_techies_land_mines:GetAOERadius()
	local caster = self:GetCaster()
	local ability = self

	local trigger_range = ability:GetSpecialValueFor("radius")
	local mine_distance = ability:GetSpecialValueFor("mine_distance")

	-- #1 Talent: Trigger range increase
	trigger_range = trigger_range + caster:GetTalentValue("special_bonus_imba_techies_1")

	return trigger_range + mine_distance
end

function imba_techies_land_mines:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local target_point = self:GetCursorPosition()
	local cast_response = {"techies_tech_setmine_01", "techies_tech_setmine_02", "techies_tech_setmine_04", "techies_tech_setmine_08", "techies_tech_setmine_09", "techies_tech_setmine_10", "techies_tech_setmine_11", "techies_tech_setmine_13", "techies_tech_setmine_16", "techies_tech_setmine_17", "techies_tech_setmine_18", "techies_tech_setmine_19", "techies_tech_setmine_20", "techies_tech_setmine_30", "techies_tech_setmine_32", "techies_tech_setmine_33", "techies_tech_setmine_34", "techies_tech_setmine_38", "techies_tech_setmine_45", "techies_tech_setmine_46", "techies_tech_setmine_47", "techies_tech_setmine_48", "techies_tech_setmine_50", "techies_tech_setmine_51", "techies_tech_setmine_54", "techies_tech_cast_02", "techies_tech_cast_03", "techies_tech_setmine_05", "techies_tech_setmine_06", "techies_tech_setmine_07", "techies_tech_setmine_14", "techies_tech_setmine_21", "techies_tech_setmine_22", "techies_tech_setmine_23", "techies_tech_setmine_24", "techies_tech_setmine_25", "techies_tech_setmine_26", "techies_tech_setmine_28", "techies_tech_setmine_29", "techies_tech_setmine_35", "techies_tech_setmine_36", "techies_tech_setmine_37", "techies_tech_setmine_39", "techies_tech_setmine_41", "techies_tech_setmine_42", "techies_tech_setmine_43", "techies_tech_setmine_44", "techies_tech_setmine_52"}
	local sound_cast = "Hero_Techies.LandMine.Plant"
	local modifier_charges = "modifier_generic_charges"

	-- Ability special
	local initial_mines = ability:GetSpecialValueFor("initial_mines")
	local mine_distance = ability:GetSpecialValueFor("mine_distance")

	-- Play cast response
	EmitSoundOn(cast_response[math.random(1, #cast_response)], caster)

	-- Play cast sound
	EmitSoundOn(sound_cast, caster)

	-- Get the amount of Proximity Mine charges, and consume all stacks
	local mine_placement_count = 0
	local modifier_charges_handler = caster:FindModifierByName(modifier_charges)
	if modifier_charges_handler then
		mine_placement_count = modifier_charges_handler:GetStackCount()

		-- If there are no charges, do nothing
		if modifier_charges_handler:GetStackCount() > 0 then
			modifier_charges_handler:SetStackCount(0)
		end
	end

	-- Determine mine locations, depending on mine count
	local direction = (target_point - caster:GetAbsOrigin()):Normalized()

	-- Always plant the initial mine in the target point. Big boom if appropriate
	local big_boom = false

	-- #7 Talent: Proximity Mines initial mine is a Big Boom
	if caster:HasTalent("special_bonus_imba_techies_7") then
		big_boom = true
	end

	PlantProximityMine(caster, ability, target_point, big_boom)

	-- Rotate the locations and find the additional mine spots
	if mine_placement_count > 0 then
		local degree = 360 / mine_placement_count

		-- Calculate location of the first mine, ahead of the target point
		local mine_spawn_point = target_point + direction * mine_distance

		for i = 1, mine_placement_count do
			-- Prepare the QAngle
			local qangle = QAngle(0, (i-1) * degree, 0)

			-- Rotate the mine point
			local mine_point = RotatePosition(target_point, qangle, mine_spawn_point)

			-- Plant a mine!
			PlantProximityMine(caster, ability, mine_point, false)
		end
	end
end

------------------------------
--     PROXIMITY MINE AI    --
------------------------------
LinkLuaModifier("modifier_imba_proximity_mine", "components/abilities/heroes/hero_techies.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_proximity_mine_building_res", "components/abilities/heroes/hero_techies.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_proximity_mine_talent", "components/abilities/heroes/hero_techies.lua", LUA_MODIFIER_MOTION_NONE)

-- Proximity mine states modifier
modifier_imba_proximity_mine = modifier_imba_proximity_mine or class({})

function modifier_imba_proximity_mine:OnCreated()
	if not IsServer() then return end

	-- Ability properties
	self.caster = self:GetParent()
	self.owner = self.caster:GetOwner()

	self.ability = self.owner:FindAbilityByName("imba_techies_land_mines")

	-- Ability specials
	self.explosion_delay = self.ability:GetSpecialValueFor("proximity_threshold")
	self.mine_damage = self.ability:GetSpecialValueFor("damage")
	self.trigger_range = self.ability:GetSpecialValueFor("radius")
	self.activation_delay = self.ability:GetSpecialValueFor("activation_delay")
	self.building_damage_pct = self.ability:GetSpecialValueFor("building_damage_pct")

	-- IMBA Ability specials
	self.buidling_damage_duration = self.ability:GetSpecialValueFor("buidling_damage_duration")
	self.tick_interval = self.ability:GetSpecialValueFor("tick_interval")
	self.fow_radius = self.ability:GetSpecialValueFor("fow_radius")
	self.fow_duration = self.ability:GetSpecialValueFor("fow_duration")
	self.big_boom_mine_bonus_dmg = self.ability:GetSpecialValueFor("big_boom_mine_bonus_dmg")
	self.big_boom_shrapnel_duration = self.ability:GetSpecialValueFor("big_boom_shrapnel_duration")

	-- #1 Talent: Trigger range increase
	self.trigger_range = self.trigger_range + self.caster:FindTalentValue("special_bonus_imba_techies_1")

	-- Set the mine as inactive
	self.active = false
	self.triggered = false
	self.trigger_time = 0

	-- Add mine particle effect
	local particle_mine = "particles/units/heroes/hero_techies/techies_land_mine.vpcf"
	local particle_mine_fx = ParticleManager:CreateParticle(particle_mine, PATTACH_ABSORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControl(particle_mine_fx, 0, self.caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_mine_fx, 3, self.caster:GetAbsOrigin())
	self:AddParticle(particle_mine_fx, false, false, -1, false, false)

	-- Determine if this is a Big Boom
	if self.caster:GetUnitName() == "explosive_mech_big_boom" then
		self.is_big_boom = true
	end

	-- Wait for the mine to activate
	Timers:CreateTimer(self.activation_delay, function()
		-- Mark mine as active
		self.active = true

		-- Start looking around for enemies
		self:StartIntervalThink(self.tick_interval)
	end)
end

function modifier_imba_proximity_mine:IsHidden() return true end
function modifier_imba_proximity_mine:IsPurgable() return false end
function modifier_imba_proximity_mine:IsDebuff() return false end

function modifier_imba_proximity_mine:OnIntervalThink()
	if IsServer() then
		local caster = self.caster

		-- If the mine was killed, remove the modifier
		if not caster:IsAlive() then
			self:Destroy()
		end

		local modifier_sign = "modifier_imba_minefield_sign_detection"
		-- If the mine is under the sign effect, reset possible triggers and do nothing
		if caster:HasModifier(modifier_sign) then
			self.triggered = false
			self.trigger_time = 0
			self.hidden_by_sign = true
			return nil
		end

		-- Look for nearby enemies
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
			caster:GetAbsOrigin(),
			nil,
			self.trigger_range,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			FIND_ANY_ORDER,
			false
		)

		local enemy_found

		if #enemies > 0 then
			local non_flying_enemies = false

			-- Check if there is at least one enemy that isn't flying
			for _,enemy in pairs(enemies) do
				if not enemy:HasFlyMovementCapability() then
					non_flying_enemies = true
					break
				end
			end

			-- At least one non-flying enemy found - mark as found
			if non_flying_enemies then
				enemy_found = true
			else
				enemy_found = false
			end
		else
			enemy_found = false
		end

		-- If the mine is not triggered, check if it should be triggered
		if not self.triggered then
			if enemy_found then
				self.triggered = true
				self.trigger_time = 0

				-- Play prime sound
				local sound_prime = "Hero_Techies.LandMine.Priming"
				EmitSoundOn(sound_prime, caster)
			end

		-- If the mine was already triggered, check if it should stop or count time
		else
			if enemy_found then
				self.trigger_time = self.trigger_time + self.tick_interval

				-- Check if the mine should blow up
				if self.trigger_time >= self.explosion_delay then
					self:_Explode()
				end
			else
				self.triggered = false
				self.trigger_time = 0
			end
		end
	end
end

function modifier_imba_proximity_mine:_Explode()
	local enemy_killed
	local caster = self.caster
	local trigger_range = self.trigger_range

	-- BLOW UP TIME! Play explosion sound
	local sound_explosion = "Hero_Techies.LandMine.Detonate"
	EmitSoundOn(sound_explosion, caster)

	local casterAbsOrigin = caster:GetAbsOrigin()

	-- Add particle explosion effect
	local particle_explosion = "particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf"
	local particle_explosion_fx = ParticleManager:CreateParticle(particle_explosion, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle_explosion_fx, 0, casterAbsOrigin)
	ParticleManager:SetParticleControl(particle_explosion_fx, 1, casterAbsOrigin)
	ParticleManager:SetParticleControl(particle_explosion_fx, 2, Vector(trigger_range, 1, 1))
	ParticleManager:ReleaseParticleIndex(particle_explosion_fx)

	-- Look for nearby enemies
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
										casterAbsOrigin,
										nil,
										trigger_range,
										DOTA_UNIT_TARGET_TEAM_ENEMY,
										DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
										DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
										FIND_ANY_ORDER,
										false)

	local modifier_building_res = "modifier_imba_proximity_mine_building_res"
	local modifier_talent_shrapnel = "modifier_imba_proximity_mine_talent"

	-- If this is a Big Boom, RAIN THEM SHRAPNELS!
	if self.is_big_boom then
		CreateModifierThinker(caster, self.ability, modifier_talent_shrapnel, {duration = self.big_boom_shrapnel_duration}, casterAbsOrigin, caster:GetTeamNumber(), false)
	end

	-- Deal damage to nearby non-flying enemies
	for _,enemy in pairs(enemies) do

		-- If an enemy doesn't have flying movement, ignore it, otherwise continue
		if not enemy:HasFlyMovementCapability() then

			-- If this is a Big Boom, add damage to the blast!
			local damage = self.mine_damage
			if self.is_big_boom then
				damage = damage + self.big_boom_mine_bonus_dmg
			end

			-- If the enemy is a building, reduce damage to it
			if enemy:IsBuilding() then
				damage = damage * self.building_damage_pct / 100
			end

			-- Deal damage
			local damageTable = {victim = enemy,
									attacker = caster, 
--									damage = damage * ((1+(PlayerResource:GetSelectedHeroEntity(self.caster:GetPlayerOwnerID()):GetSpellAmplification(false) * 0.01))),
									damage = damage,
									damage_type = DAMAGE_TYPE_MAGICAL,
									ability = self.ability
									}

			ApplyDamage(damageTable)

			-- If the enemy was a building, give it magical protection
			if enemy:IsBuilding() and not enemy:HasModifier(modifier_building_res) then
				enemy:AddNewModifier(caster, self.ability, modifier_building_res, {duration = self.buidling_damage_duration})
			end

			RefreshElectroCharge(enemy)

			-- See if the enemy died from the mine
			Timers:CreateTimer(FrameTime(), function()
				if not enemy:IsAlive() then
					enemy_killed = true
				end
			end)
		end
	end

	ApplyInflammableToRemoteMines(caster, self.trigger_range, nil)

	-- If an enemy was killed from a mine, play kill response
	if RollPercentage(25) then
		Timers:CreateTimer(FrameTime()*2, function()
			local kill_response = {"techies_tech_mineblowsup_01", "techies_tech_mineblowsup_02", "techies_tech_mineblowsup_03", "techies_tech_mineblowsup_04", "techies_tech_mineblowsup_05", "techies_tech_mineblowsup_06", "techies_tech_mineblowsup_08", "techies_tech_mineblowsup_09", "techies_tech_minekill_01", "techies_tech_minekill_02", "techies_tech_minekill_03"}

			if enemy_killed then
				EmitSoundOn(kill_response[math.random(1, #kill_response)], self.owner)
			end
		end)
	end

	-- Apply flying vision at detonation point
	AddFOWViewer(caster:GetTeamNumber(), casterAbsOrigin, self.fow_radius, self.fow_duration, false)

	-- Kill self and remove modifier
	caster:ForceKill(false)
	self:Destroy()
end

function modifier_imba_proximity_mine:CheckState()
	local state

	if self.active and not self.triggered then
		state = {[MODIFIER_STATE_INVISIBLE] = true,
				 [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	else
		state = {[MODIFIER_STATE_INVISIBLE] = false,
				 [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	end

	return state
end

function modifier_imba_proximity_mine:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_TAKEDAMAGE,
					 MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}

	return decFuncs
end

function modifier_imba_proximity_mine:GetModifierIncomingDamage_Percentage()
	return -100
end

function modifier_imba_proximity_mine:OnTakeDamage(keys)
	local unit = keys.unit
	local attacker = keys.attacker

	-- Only apply if the unit taking damage is the mine
	if unit == self.caster then
		-- Reduce mines' life by 1, or kill it. This is only relevant for Big Boom mines
		local mine_health = self.caster:GetHealth()
		if mine_health > 1 then
			self.caster:SetHealth(mine_health - 1)
		else
			self.caster:Kill(self.ability, attacker)
		end
	end
end

function modifier_imba_proximity_mine:GetPriority()
	return MODIFIER_PRIORITY_NORMAL
end


-- Building fortification modifier
modifier_imba_proximity_mine_building_res = modifier_imba_proximity_mine_building_res or class({})

function modifier_imba_proximity_mine_building_res:OnCreated()
	-- Ability properties
	self.ability = self:GetAbility()

	-- Ability specials
	self.building_magic_resistance = self.ability:GetSpecialValueFor("building_magic_resistance")
end

function modifier_imba_proximity_mine_building_res:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}

	return decFuncs
end

function modifier_imba_proximity_mine_building_res:GetModifierMagicalResistanceBonus()
	return self.building_magic_resistance
end

function modifier_imba_proximity_mine_building_res:IsHidden() return true end
function modifier_imba_proximity_mine_building_res:IsPurgable() return false end
function modifier_imba_proximity_mine_building_res:IsDebuff() return false end




-- BIG BOOM SHRAPNEL MODIFIER!
modifier_imba_proximity_mine_talent = modifier_imba_proximity_mine_talent or class({})

function modifier_imba_proximity_mine_talent:OnCreated()
	if IsServer() then
		-- Ability properties
		self.caster = self:GetCaster()
		self.parent = self:GetParent()
		self.parent_team = self.parent:GetTeamNumber()
		local parentAbsOrigin = self.parent:GetAbsOrigin()
		self.parent_pos = parentAbsOrigin
		self.ability = self:GetAbility()

		-- Ability specials
		self.big_boom_shrapnel_aoe = self.ability:GetSpecialValueFor("big_boom_shrapnel_aoe")
		self.big_boom_shrapnel_damage = self.ability:GetSpecialValueFor("big_boom_shrapnel_damage")
		self.big_boom_shrapnel_interval = self.ability:GetSpecialValueFor("big_boom_shrapnel_interval")

		-- Create rain particles
		local particle_rain = "particles/hero/techies/techies_big_boom_explosions.vpcf"
		local particle_rain_fx = ParticleManager:CreateParticle(particle_rain, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(particle_rain_fx, 0, parentAbsOrigin)
		ParticleManager:SetParticleControl(particle_rain_fx, 1, parentAbsOrigin)
		ParticleManager:SetParticleControl(particle_rain_fx, 3, parentAbsOrigin)
		self:AddParticle(particle_rain_fx, false, false, -1, false, false)

		-- Damage per interval
		self.damage = self.big_boom_shrapnel_damage * self.big_boom_shrapnel_interval

		-- Start thinking
		self:StartIntervalThink(self.big_boom_shrapnel_interval)
	end
end

function modifier_imba_proximity_mine_talent:OnIntervalThink()
	if IsServer() then
		-- Find all nearby units
		local enemies = FindUnitsInRadius(self.parent_team,
										  self.parent_pos,
										  nil,
										  self.big_boom_shrapnel_aoe,
										  DOTA_UNIT_TARGET_TEAM_ENEMY,
										  DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
										  DOTA_DAMAGE_FLAG_NONE,
										  FIND_ANY_ORDER,
										  false)

		for _, enemy in pairs(enemies) do
			-- Deal magical damage to them
			local damageTable = {victim = enemy,
								attacker = self.caster,
--								damage = self.damage * ((1+(PlayerResource:GetSelectedHeroEntity(self.caster:GetPlayerOwnerID()):GetSpellAmplification(false) * 0.01))),
								damage = self.damage,
								damage_type = DAMAGE_TYPE_MAGICAL,
								ability = self.ability
								}

			ApplyDamage(damageTable)
		end
	end
end
