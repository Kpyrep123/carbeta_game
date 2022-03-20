function Initiate( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:TriggerSpellAbsorb(ability) then
		RemoveLinkens(target)
		target:RemoveModifierByName("modifier_blackout")
		return
	end
end

function CheckMoves( keys )
	if not moveCount then moveCount = 0 end
	moveCount = moveCount + 1
	Timers:CreateTimer(2, function() 
		moveCount = moveCount - 1
	end)

	if moveCount < 3 then return end

	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability

	print(ability)
	print(target)

	ability:ApplyDataDrivenModifier(caster, target, "modifier_block_commands", {})
end

function StopSound(keys)
	keys.target:StopSound("Hero_Warlock.Upheaval")
end

function blackout( filterTable )
    local units = filterTable["units"]
    local issuer = filterTable["issuer_player_id_const"]
    local order_type = filterTable["order_type"]
    local abilityIndex = filterTable["entindex_ability"]
    local ability = EntIndexToHScript(abilityIndex)
    local targetIndex = filterTable["entindex_target"]

    local unit = EntIndexToHScript(units["0"])
    if not IsValidEntity(unit) then return false end
    
    local hasModifier = unit:FindModifierByName("modifier_blackout")
    if hasModifier and (order_type ~= DOTA_UNIT_ORDER_STOP or order_type ~= DOTA_UNIT_ORDER_HOLD_POSITION) then
        local blackout = hasModifier:GetAbility()
        local skoros = hasModifier:GetCaster()
        if blackout and skoros then
            local chance = blackout:GetSpecialValueFor("halt_chance")
            local random = RollPercentage(chance)
            if random then
                blackout:ApplyDataDrivenModifier(skoros, unit, "modifier_block_commands", {duration = blackout:GetSpecialValueFor("halt_duration")})
                return false
            else
                return true
            end
        end
    end
end