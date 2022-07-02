function VoidBlast( keys )
	local caster = keys.caster
	local ability = keys.ability
	local wave_speed = ability:GetLevelSpecialValueFor("wave_speed", (ability:GetLevel() - 1)) + caster:GetTalentValue("special_bonus_unquie_void_blast_range")
	local wave_width = ability:GetLevelSpecialValueFor("wave_width", (ability:GetLevel() - 1))
	local wave_range = ability:GetLevelSpecialValueFor("wave_range", (ability:GetLevel() - 1)) + caster:GetTalentValue("special_bonus_unquie_void_blast_range")
	if not caster:HasShard() then
	local caster_location = caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local forwardVec = (target_point - caster_location):Normalized()

	-- Projectile variables
	
	local wave_location = caster_location
	local wave_particle = keys.wave_particle

	-- Vision variables
	local vision_aoe = ability:GetLevelSpecialValueFor("wave_width", (ability:GetLevel() - 1))
	local vision_duration = ability:GetLevelSpecialValueFor("vision_duration", (ability:GetLevel() - 1))
	-- Creating the projectile
	local projectileTable =
	{
		EffectName = wave_particle,
		Ability = ability,
		vSpawnOrigin = caster_location,
		vVelocity = Vector( forwardVec.x * wave_speed, forwardVec.y * wave_speed, 0 ),
		fDistance = wave_range,
		fStartRadius = wave_width,
		fEndRadius = wave_width,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	}
	-- Saving the projectile ID so that we can destroy it later
	projectile_id = ProjectileManager:CreateLinearProjectile( projectileTable )
 	else
 	local caster = keys.caster
	local player = caster:GetPlayerID()
	local ability = keys.ability
	local images_count = 6
	local spawnRadius = ability:GetLevelSpecialValueFor( "wave_range", ability:GetLevel() - 1 ) + caster:GetTalentValue("special_bonus_unquie_void_blast_range")
	local delay = ability:GetLevelSpecialValueFor( "spawn_delay", ability:GetLevel() - 1 )
	local point = keys.target_points[1]
	local casterOrigin = caster:GetAbsOrigin()
	local casterForwardVec = caster:GetForwardVector()
	local rotateVar = 0
	ability:CreateVisibilityNode(point, spawnRadius, 1)

	-- Setup a table of projectile positions
	local vProjPos = {}
	for i=1, images_count do
		local rotate_distance = point + casterForwardVec * spawnRadius
		local rotate_angle = QAngle(0,rotateVar,0)
		rotateVar = rotateVar + 360/images_count
		local rotate_position = RotatePosition(point, rotate_angle, rotate_distance)

		local distance = (rotate_position - point):Length2D()
		local vector = (rotate_position - point):Normalized()
		local speed = ability:GetLevelSpecialValueFor("wave_speed", (ability:GetLevel() - 1)) + caster:GetTalentValue("special_bonus_unquie_void_blast_range")
		local projectileTable =
		{
			EffectName = "particles/units/heroes/hero_void_spirit/void_spirit_monk_punch_ti6.vpcf",
			Ability = ability,
			vSpawnOrigin = point,
			vVelocity = Vector( vector.x * speed, vector.y * speed, 0 ),
			fDistance = distance,
			fStartRadius = wave_width,
			fEndRadius = wave_width,	
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
		}

		vProjPos[i] = ProjectileManager:CreateLinearProjectile(projectileTable)
	end
end
	-- Timer to provide vision
	Timers:CreateTimer( function()
		-- Calculating the distance traveled
		wave_location = wave_location + forwardVec * (wave_speed * 1/30)

		-- Reveal the area after the projectile passes through it
		AddFOWViewer(caster:GetTeamNumber(), wave_location, vision_aoe, vision_duration, false)

		local distance = (wave_location - caster_location):Length2D()

		-- Checking if we traveled far enough, if yes then destroy the timer
		if distance >= wave_range then
			return nil
		else
			return 1/30
		end
	end)
end

function VoidBlast_hit( keys)
	local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("void_duration", (ability:GetLevel() - 1))
	ability:ApplyDataDrivenModifier(caster, target, "modifier_void_hit", {duration = duration})
	ability:ApplyDataDrivenModifier(caster, target, "modifier_hit_damage", {duration = duration})
	if target:IsRealHero() then
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_void_duration", {duration = duration})
end
end

function Incrementstack( params )
	local caster = params.caster
	local target = params.target
	local ability = params.ability
	counter_buff = params.caster:FindModifierByName("modifier_warpath_datadriven_counter")
if target:IsHero() then
	-- If the counter buff doesn't exist, create it. After creation, reassign the counter_buff variable so it's no longer nil.
	if counter_buff == nil then
		params.ability:ApplyDataDrivenModifier(params.caster, params.caster, "modifier_warpath_datadriven_counter", nil)
		counter_buff = params.caster:FindModifierByName("modifier_warpath_datadriven_counter")
	end

	-- If the current amount of stacks is under the max, create a new stack, set the counter stack number, and reset the counter's duration.
	if counter_buff:GetStackCount() < params.max_stacks then
		counter_buff:IncrementStackCount()
		if caster:HasTalent("special_bonus_unquie_double_touch") then
			counter_buff:IncrementStackCount()
		end
	-- Else, if we are over the number of maximum stacks, destroy a random stack and make a new one.
	else
		counter_buff:IncrementStackCount()
		if caster:HasTalent("special_bonus_unquie_double_touch") then
			counter_buff:IncrementStackCount()
		end
	end
end
end


function Decrisment( keys )
local target = keys.target
local caster = keys.caster
local ability = keys.ability
local ability_level = ability:GetLevel() - 1
	
	counter_buff:DecrementStackCount()	
	if caster:HasTalent("special_bonus_unquie_double_touch") then
		counter_buff:DecrementStackCount()	
	end

end

function PermaIncreasment( keys )
local target = keys.target
local caster = keys.caster
local ability = keys.ability
local ability_level = ability:GetLevel() - 1

	counter_buff:IncrementStackCount()
	if caster:HasTalent("special_bonus_unquie_double_touch") then 
		counter_buff:IncrementStackCount()
	end

end

luna_void_blast_lua = class({})

function luna_void_blast_lua:OnSpellStart( keys )
		local caster = self:GetCaster()
	local ability = self
	local wave_speed = ability:GetLevelSpecialValueFor("wave_speed", (ability:GetLevel() - 1)) + caster:GetTalentValue("special_bonus_unquie_void_blast_range")
	local wave_width = ability:GetLevelSpecialValueFor("wave_width", (ability:GetLevel() - 1))
	local wave_range = ability:GetLevelSpecialValueFor("wave_range", (ability:GetLevel() - 1)) + caster:GetTalentValue("special_bonus_unquie_void_blast_range")
	if not caster:HasShard() then
	local caster_location = caster:GetAbsOrigin()
	local target_point = self:GetCursorPosition()
	local forwardVec = (target_point - caster_location):Normalized()
	local wave_particle = "particles/units/heroes/hero_void_spirit/void_spirit_monk_punch_ti6.vpcf"

	-- Projectile variables
	
	local wave_location = caster_location
	local wave_particle = wave_particle

	-- Vision variables
	local vision_aoe = ability:GetLevelSpecialValueFor("wave_width", (ability:GetLevel() - 1))
	local vision_duration = ability:GetLevelSpecialValueFor("vision_duration", (ability:GetLevel() - 1))
	-- Creating the projectile
	local projectileTable =
	{
		EffectName = wave_particle,
		Ability = ability,
		vSpawnOrigin = caster_location,
		vVelocity = Vector( forwardVec.x * wave_speed, forwardVec.y * wave_speed, 0 ),
		fDistance = wave_range,
		fStartRadius = wave_width,
		fEndRadius = wave_width,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	}
	-- Saving the projectile ID so that we can destroy it later
	projectile_id = ProjectileManager:CreateLinearProjectile( projectileTable )
 	else
	local player = caster:GetPlayerID()
	local images_count = 6
	local spawnRadius = ability:GetLevelSpecialValueFor( "wave_range", ability:GetLevel() - 1 ) + caster:GetTalentValue("special_bonus_unquie_void_blast_range")
	local delay = ability:GetLevelSpecialValueFor( "spawn_delay", ability:GetLevel() - 1 )
	local point = self:GetCursorPosition()
	local casterOrigin = caster:GetAbsOrigin()
	local casterForwardVec = caster:GetForwardVector()
	local rotateVar = 0
	ability:CreateVisibilityNode(point, spawnRadius, 1)

	-- Setup a table of projectile positions
	local vProjPos = {}
	for i=1, images_count do
		local rotate_distance = point + casterForwardVec * spawnRadius
		local rotate_angle = QAngle(0,rotateVar,0)
		rotateVar = rotateVar + 360/images_count
		local rotate_position = RotatePosition(point, rotate_angle, rotate_distance)

		local distance = (rotate_position - point):Length2D()
		local vector = (rotate_position - point):Normalized()
		local speed = ability:GetLevelSpecialValueFor("wave_speed", (ability:GetLevel() - 1)) + caster:GetTalentValue("special_bonus_unquie_void_blast_range")
		local projectileTable =
		{
			EffectName = "particles/units/heroes/hero_void_spirit/void_spirit_monk_punch_ti6.vpcf",
			Ability = ability,
			vSpawnOrigin = point,
			vVelocity = Vector( vector.x * speed, vector.y * speed, 0 ),
			fDistance = distance,
			fStartRadius = wave_width,
			fEndRadius = wave_width,	
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
		}

		vProjPos[i] = ProjectileManager:CreateLinearProjectile(projectileTable)
	end
end
	-- Timer to provide vision
	Timers:CreateTimer( function()
		-- Calculating the distance traveled
		wave_location = wave_location + forwardVec * (wave_speed * 1/30)

		-- Reveal the area after the projectile passes through it
		AddFOWViewer(caster:GetTeamNumber(), wave_location, vision_aoe, vision_duration, false)

		local distance = (wave_location - caster_location):Length2D()

		-- Checking if we traveled far enough, if yes then destroy the timer
		if distance >= wave_range then
			return nil
		else
			return 1/30
		end
	end)
end

LinkLuaModifier("luna_void_blast_lua_mark", "heroes/hero_luna/VoidBlast.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("luna_void_blast_lua_buff", "heroes/hero_luna/VoidBlast.lua", LUA_MODIFIER_MOTION_NONE)

function luna_void_blast_lua:OnProjectileHit( hTarget, vLocation )
	local buff_duration = self:GetSpecialValueFor("buff_duration")
	local duration = self:GetSpecialValueFor("duration")
	local stacks = self:GetCaster():AddNewModifier(self:GetCaster(), self, "luna_void_blast_lua_buff", {})
	hTarget:AddNewModifier(self:GetCaster(), self, "luna_void_blast_lua_mark", {duration = duration * (1 - hTarget:GetStatusResistance())})
	stacks:SetStackCount(stacks:GetStackCount() + 1)
	Timers:CreateTimer(buff_duration, function()
		stacks:DecrementStackCount()
	end)
	if self:GetCaster():HasTalent("special_bonus_unquie_double_touch") then 
		stacks:SetStackCount(stacks:GetStackCount() + 1)
		Timers:CreateTimer(buff_duration, function()
			stacks:DecrementStackCount()
		end)
	end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

luna_void_blast_lua_mark = class({})
function luna_void_blast_lua_mark:IsHidden() return false end
function luna_void_blast_lua_mark:IsPurgable() return true end
function luna_void_blast_lua_mark:GetTexture() return end
function luna_void_blast_lua_mark:GetEffectName() return end

function luna_void_blast_lua_mark:OnCreated()
	self:OnIntervalThink()
	self:StartIntervalThink(0.5)
	self.damage = self:GetAbility():GetSpecialValueFor("damage") / 2
end

function luna_void_blast_lua_mark:OnRefresh()
	self.damage = self:GetAbility():GetSpecialValueFor("damage") / 2
end

function luna_void_blast_lua_mark:OnIntervalThink(  )
	damage = self:GetAbility():GetSpecialValueFor("damage") / 2
		ApplyDamage({
		    victim = self:GetParent(),
		    attacker = self:GetCaster(),
		    damage = damage,
		    damage_type = DAMAGE_TYPE_MAGICAL,
		    damage_flags = DOTA_DAMAGE_FLAG_NONE,
		    ability = self:GetAbility()
	  	})

end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

luna_void_blast_lua_buff = class({})
function luna_void_blast_lua_buff:IsHidden() return self:GetStackCount()==0 end
function luna_void_blast_lua_buff:IsPurgable() return false end
function luna_void_blast_lua_buff:GetTexture() return end
function luna_void_blast_lua_buff:GetEffectName() return end

function luna_void_blast_lua_buff:OnCreated()

end

function luna_void_blast_lua_buff:OnRefresh()

end
