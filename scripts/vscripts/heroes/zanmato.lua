if IsServer() then
	require('abilities/life_in_arena/utils')
end

function TimeWalk( keys )
	local caster = keys.caster
	local target = keys.target
	local caster_location = caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local modifier = keys.modifier

	-- Distance calculations
	local speed = ability:GetLevelSpecialValueFor("speed", (ability:GetLevel() - 1))
	local distance = (target_point - caster_location):Length2D()
	local direction = (target_point - caster_location):Normalized()
	local duration = distance/speed

	-- Saving the data in the ability
	ability.time_walk_distance = distance
	ability.time_walk_speed = speed * 1/30 -- 1/30 is how often the motion controller ticks
	ability.time_walk_direction = direction
	ability.time_walk_traveled_distance = 0

	-- Apply the invlunerability modifier to the caster
	ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
end

--[[Author: Pizzalol
	Date: 21.09.2015.
	Moves the target until it has traveled the distance to the chosen point]]
function TimeWalkMotion( keys )
	local caster = keys.target
	local ability = keys.ability

	-- Move the caster while the distance traveled is less than the original distance upon cast
	if ability.time_walk_traveled_distance < ability.time_walk_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.time_walk_direction * ability.time_walk_speed)
		ability.time_walk_traveled_distance = ability.time_walk_traveled_distance + ability.time_walk_speed
	else
		-- Remove the motion controller once the distance has been traveled
		caster:InterruptMotionControllers(false)
	end
	if caster:HasShard() then
			ProjectileManager:ProjectileDodge(caster)
	end
end

--[[
	Author: Noya
	Date: 9.1.2015.
	Does damage and slow the unit, checks to damage only once per spell usage.
]]
function Stampede( event )
	-- Variables
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local outgoingDamage = ability:GetSpecialValueFor("outgoing_damage")
	local incomingDamage = ability:GetSpecialValueFor("incoming_damage")
	local duration = 2
	local origin = caster:GetAbsOrigin()
	local damage_mul = ability:GetLevelSpecialValueFor( "crit_multiplier" , ability:GetLevel() - 1  )
	caster:PerformAttack(target,true,true,true,true,true,true,true)
local casterDMG = caster:GetAverageTrueAttackDamage(caster)
local actual_dmg = damage_mul * casterDMG + caster:GetTalentValue("spec_jugg_leap")
local damageType = ability:GetAbilityDamageType()
local hit = false

-- Ignore the target if its already on the table
local targetsHit = event.ability.TargetsHit
for k,v in pairs(targetsHit) do
	if v == target then
		hit = true
	end
end

if not hit then
	-- Damage
	ApplyDamage({ victim = target, attacker = caster, damage = actual_dmg, damage_type = damageType })

	-- Modifier
	--ability:ApplyDataDrivenModifier( caster, target, "modifier_charge_stun", nil)

	-- Add to the targets hit by this cast
	table.insert(event.ability.TargetsHit, target)
end
	if caster:HasShard() and target:IsRealHero() then 
			local count_illusion = ability:GetSpecialValueFor("count_illusion")
				for i=1,count_illusion do
		local illus = CreateIllusion(caster,caster,origin,duration,outgoingDamage,incomingDamage)
		illus:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
		illus:SetControllableByPlayer(caster:GetPlayerID(), false)
		illus:SetForceAttackTarget(target)
		illus:MakeIllusion()
	end
end
end

-- Emits the global sound and initializes a table to keep track of the units hit
function StampedeStart( event )
	EmitGlobalSound("Hero_Centaur.Stampede.Cast")
	event.ability.TargetsHit = {}
end