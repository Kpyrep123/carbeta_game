--[[Author: Pizzalol
	Date: 28.09.2015.
	Applies the Shadow Strike modifier with a decaying slow]]
function shadow_strike( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local target = keys.target

	-- Ability variables
	local modifier = keys.modifier
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	local movement_slow = ability:GetLevelSpecialValueFor("movement_slow", ability_level) * -1 -- Turn it into a positive value
	local talent = caster:GetTalentValue("special_bonus_unique_ghoul_2")
	-- Decay calculation
	local slow_per_second = movement_slow / duration
	local slow_rate = 1 / slow_per_second + talent

	-- Remove the old timer if we are refreshing the duration
	if target.shadow_strike_timer then
		Timers:RemoveTimer(target.shadow_strike_timer)
	end

	-- Apply the Shadow Strike modifier and set the slow amount
	ability:ApplyDataDrivenModifier(caster, target, modifier, {duration = duration})
	target:SetModifierStackCount(modifier, caster, movement_slow)

	-- Create the timer thats responsible for the decaying movement slow
	-- Save it to the target so that we can remove it later
	target.shadow_strike_timer = Timers:CreateTimer(slow_rate, function()
		if IsValidEntity(target) and target:HasModifier(modifier) then
			local current_slow = target:GetModifierStackCount(modifier, caster)
			target:SetModifierStackCount(modifier, caster, current_slow - 1)

			return slow_rate
		else
			return nil
		end
	end)
end

function IntToDamage( keys )
	
	local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local int_caster = caster:GetIntellect()
    local int_damage = ability:GetLevelSpecialValueFor("intellect_damage_pct", (ability:GetLevel() -1)) 
    

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = int_caster * int_damage / 100

    ApplyDamage(damage_table)

end