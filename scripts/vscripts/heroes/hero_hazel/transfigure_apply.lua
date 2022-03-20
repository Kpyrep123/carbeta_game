LinkLuaModifier("modifier_transfigure_bat", "heroes/hero_hazel/modifiers/modifier_transfigure_bat.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_transfigure_rat", "heroes/hero_hazel/modifiers/modifier_transfigure_rat.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_transfigure_slug", "heroes/hero_hazel/modifiers/modifier_transfigure_slug.lua", LUA_MODIFIER_MOTION_NONE)

--[[Author: TheGreatGimmick
    Date: Feb 21, 2017
    Hazel Hexes]]

--Hex with Bat
function BatHex(keys)
	print('Target is a bat')
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local target = keys.target

	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	
	if target:IsIllusion() then
		target:ForceKill(true)
	else
		target:AddNewModifier(caster, ability, "modifier_transfigure_bat", {duration = duration})
	end
end
--Hex with Rat
function RatHex(keys)
	print('Target is a rat')
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local target = keys.target

	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	
	if target:IsIllusion() then
		target:ForceKill(true)
	else
		target:AddNewModifier(caster, ability, "modifier_transfigure_rat", {duration = duration})
	end
end
--Hex with Slug
function SlugHex(keys)
	print('Target is a slug')
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local target = keys.target

	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	
	if target:IsIllusion() then
		target:ForceKill(true)
	else
		target:AddNewModifier(caster, ability, "modifier_transfigure_slug", {duration = duration})
	end
end