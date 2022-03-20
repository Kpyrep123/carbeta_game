require('lib/physics')
require('lib/util_dusk')
require('lib/timers')

function swapforward( keys )
	local caster = keys.caster

	-- Swap sub_ability
	local sub_ability_name = keys.sub_ability_name
	local main_ability_name = keys.main_ability_name

	caster:SwapAbilities(main_ability_name, sub_ability_name, false, true)
end

function RapidStack( keys )
  local caster = keys.caster
  local ability = keys.ability
  local duration = ability:GetSpecialValueFor("duration")
  local rapidtack = ability:ApplyDataDrivenModifier(caster, caster, "modifier_RapidStack", {duration = duration})
  rapidtack:SetStackCount(3)
end

function RapidSpendStack( keys )
  local caster = keys.caster
  local ability = keys.ability
  local duration = ability:GetSpecialValueFor("duration")
  local rapidtack = caster:FindModifierByName("modifier_RapidStack")
  local stacks = rapidtack:GetStackCount()
  if caster:HasModifier("modifier_RapidStack") and stacks > 1 then
  rapidtack:DecrementStackCount()
else
  caster:RemoveModifierByName("modifier_RapidStack")
  caster:RemoveModifierByName("modifier_rapidfire")
end
end