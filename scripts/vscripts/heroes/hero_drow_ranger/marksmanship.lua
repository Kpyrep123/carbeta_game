--[[
	Author: kritth
	Date: 1.1.2015.
	Check number of units every interval
	Note: Might be possible to do entirely in datadriven, however, I seem to crash everytime I tried
	to do so, insteads, I just use simple script
]]
function marksmanship_detection( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor( "radius", ( ability:GetLevel() - 1 ) )
	local modifierName = "modifier_marksmanship_effect_datadriven"
		if caster:PassivesDisabled() and caster:HasModifier(modifierName) then 
		caster:RemoveModifierByName( modifierName )
	end
	if not caster:PassivesDisabled() then
	-- Count units in radius
	local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
	local count = 0
	for k, v in pairs( units ) do
		count = count + 1
	end
	
	-- Apply and destroy
	if count > 0 and not caster:HasModifier( modifierName ) then
		ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
		if caster:HasModifier("modifier_shard_evasion") then 
			caster:RemoveModifierByName("modifier_shard_evasion")
		end
	elseif count == 0 and caster:HasModifier( modifierName ) then
		caster:RemoveModifierByName( modifierName )
		if caster:HasTalent("special_bonus_unquie_evasion") then 
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_shard_evasion", {})
		end
	end
end

end

function instinct_venom( keys )
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	if not caster:PassivesDisabled() then
	ability:ApplyDataDrivenModifier(caster, target, "modifier_killer_venom", {duration = duration - target:GetStatusResistance()})
end

end