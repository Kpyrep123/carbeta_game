function azurarestorecharge( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if caster:HasScepter() then
	local modifier_name = "modifier_azura_multishot_crossbow"
	local modifier = caster:FindModifierByNameAndCaster(modifier_name, caster)
	local bolt_per_unit = 3
		if modifier~=nil then
			modifier:AddStack( bolt_per_unit )
		end
		caster:PerformAttack(
              target,
              true,
              true,
              true,
              true,
              true,
              false,
              true
          )    -- body
	else 
		return nil
	end
end

function azurarestorechargenotaghs( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not caster:PassivesDisabled() and not target:IsBuilding() and not caster:IsIllusion() then
	local modifier_name = "modifier_azura_multishot_crossbow"
	local modifier = caster:FindModifierByNameAndCaster(modifier_name, caster)
	local bolt_per_unit = 2
		if modifier~=nil then
			modifier:AddStack( bolt_per_unit )
		end
		caster:PerformAttack(
              target,
              true,
              true,
              true,
              true,
              true,
              false,
              true
          )   
	else 
		return nil
	end
end