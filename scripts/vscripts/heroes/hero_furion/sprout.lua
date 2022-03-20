--[[Author: YOLOSPAGHETTI
	Date: March 22, 2016
	Creates the sprout]]
function CreateSprout(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local point = ability:GetCursorPosition()
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
	local vision_range = ability:GetLevelSpecialValueFor("vision_range", (ability:GetLevel() -1))
	local trees = ability:GetLevelSpecialValueFor("count", ability_level) + caster:GetTalentValue("drone_count")
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	local radius = ability:GetLevelSpecialValueFor("radius", ability_level)
	local rotateVar = 45
	local casterForwardVec = caster:GetForwardVector()
	local polypMax = ability:GetLevelSpecialValueFor("hp", ability_level) + caster:GetTalentValue("drone_hp")

local vSpawnPos = {}
	for i=1, trees do
		local rotate_distance = point + casterForwardVec * radius
		local rotate_angle = QAngle(0,rotateVar,0)
		rotateVar = rotateVar + 360/trees
		local rotate_position = RotatePosition(point, rotate_angle, rotate_distance)
		table.insert(vSpawnPos, rotate_position)
	end

	local angle = math.pi/trees
	
	-- Creates 8 temporary trees at each 45 degree interval around the clicked point
	for i=1,trees do
		local position = table.remove( vSpawnPos, 1 )
		 mech = CreateUnitByName("explosive_mech", position, true, caster, caster, caster:GetTeamNumber())
			mech:SetMaxHealth(polypMax)
			mech:SetBaseMaxHealth(polypMax)
			mech:SetHealth(polypMax)
		local explose = ability:ApplyDataDrivenModifier(caster, mech, "modifier_explose", {duration = duration})
		local exp = ability:ApplyDataDrivenModifier(caster, mech, "modifier_explose_dummy", {duration = duration - 0.15})	
		local x = ability:ApplyDataDrivenModifier(caster, mech, "modifier_sound", {duration = duration - 3.0})	
		if caster:HasScepter() then 
			ability:ApplyDataDrivenModifier(caster, mech, "modifier_electric_shock", {duration = duration})
		end
		angle = angle + math.pi/trees
	end
	-- Gives vision to the caster's team in a radius around the clicked point for the duration
	AddFOWViewer(caster:GetTeam(), point, vision_range, duration, false)
end


function explosion( params )
	local caster = params.caster
	local target = params.target
	local ability = params.ability
	local ability_level = ability:GetLevel() - 1

	target:ForceKill(false)
end

function Partinggift(keys)
	local caster = keys.caster
	local ability = caster:FindAbilityByName("nova_explosive_mech")
	local ability_level = ability:GetLevel() - 1
	local point = caster:GetAbsOrigin()
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
	local vision_range = ability:GetLevelSpecialValueFor("vision_range", (ability:GetLevel() -1))
	local trees = 3
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	local radius = 150
	local rotateVar = 0
	local casterForwardVec = caster:GetForwardVector()
	local polypMax = ability:GetLevelSpecialValueFor("hp", ability_level) + caster:GetTalentValue("drone_hp")
	if caster:HasTalent("Partinggift") then
local vSpawnPos = {}
	for i=1, trees do
		local rotate_distance = point + casterForwardVec * radius
		local rotate_angle = QAngle(0,rotateVar,0)
		rotateVar = rotateVar + 360/trees
		local rotate_position = RotatePosition(point, rotate_angle, rotate_distance)
		table.insert(vSpawnPos, rotate_position)
	end

	local angle = math.pi/trees
	
	-- Creates 8 temporary trees at each 45 degree interval around the clicked point
	for i=1,trees do
		local position = table.remove( vSpawnPos, 1 )
		 mech = CreateUnitByName("explosive_mech", position, true, caster, caster, caster:GetTeamNumber())
			mech:SetMaxHealth(polypMax)
			mech:SetBaseMaxHealth(polypMax)
			mech:SetHealth(polypMax)
		local explose = ability:ApplyDataDrivenModifier(caster, mech, "modifier_explose", {duration = duration})
		local exp = ability:ApplyDataDrivenModifier(caster, mech, "modifier_explose_dummy", {duration = duration - 0.15})	
		local x = ability:ApplyDataDrivenModifier(caster, mech, "modifier_sound", {duration = duration - 3.0})	
		angle = angle + math.pi/trees
	end
	-- Gives vision to the caster's team in a radius around the clicked point for the duration
	AddFOWViewer(caster:GetTeam(), point, vision_range, duration, false)
end
end