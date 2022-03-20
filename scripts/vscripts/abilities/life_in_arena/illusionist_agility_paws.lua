function remove_agi(event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	--
	--if not caster.curr_agi then
	--	caster.curr_agi = 0
	--end
	--
	caster.curr_agi = caster.curr_agi - target.bonus_agi
	
	caster:ModifyAgility(-target.bonus_agi)
	caster:CalculateStatBonus( true )
	--
	--if caster.count_ill then
--	caster.count_ill = caster.count_ill -1
	--end
	
	
end

function stay_agi(event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local unit = caster:GetUnitName()
	if target==caster:GetUnitName() then
	 ability:ApplyDataDrivenModifier("ability", caster, "modifier_illusionist_agility_paws_i", {})
	else
		return nil
	end
end
