--[[
	Author: Ractidous
	Date: 23.02.2015.

	Store the caster.
]]
function Thinker_StoreCaster( event )
	local ability	= event.ability
	local caster	= event.caster
	local thinker	= event.target

	thinker.dream_coil_caster	= caster
	ability.dream_coil_thinker	= thinker
end

--[[
	Author: Ractidous
	Date: 23.02.2015.

	Apply modifier to the enemy
]]
function Thinker_ApplyModifierToEnemy( event )
	local ability	= event.ability
	local caster	= ability.dream_coil_thinker
	local enemy		= event.target

		local duration = ability:GetLevelSpecialValueFor("coil_duration",  ( ability:GetLevel() - 1 )) + caster:GetTalentValue("spec_puppet_rope_dur")

	ability:ApplyDataDrivenModifier( caster, enemy, event.modifier_name, { Duration = duration } )
end

--[[
	Author: Ractidous
	Date: 23.02.2015.

	Check to see if the coil gets broken.
]]
function CheckCoilBreak( event )
	local thinker	= event.caster
	local enemy		= event.target

	local dist	= (enemy:GetAbsOrigin() - thinker:GetAbsOrigin()):Length2D()
	if dist > event.coil_break_radius then
		-- Link has been broken
		local ability	= event.ability
		local caster	= thinker.dream_coil_caster
		local duration = ability:GetLevelSpecialValueFor("coil_duration",  ( ability:GetLevel() - 1 ))

		ability:ApplyDataDrivenModifier( caster, enemy, event.coil_break_modifier, { Duration = duration } )

		-- Remove this modifier
		enemy:RemoveModifierByNameAndCaster( event.coil_tether_modifier, thinker )
	end
end