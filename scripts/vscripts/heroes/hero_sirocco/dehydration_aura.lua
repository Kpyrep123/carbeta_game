function aura( keys )
  local target = keys.target
  local caster = keys.caster
  if not caster:PassivesDisabled() then
  if target:GetMaxMana() == 0 then return end 
  local ability = keys.ability
  local targetmana = 100 - target:GetManaPercent()
  local resistance_loss = keys.resistance_loss
  local stacks = math.floor(targetmana/10) - 1

  local max = target:GetMaxMana()
  local now = target:GetMana()
  local difference = max - now
 
  if not target:HasModifier(resistance_loss) and stacks > 0 then 
    ability:ApplyDataDrivenModifier(target, target, resistance_loss, {})
  end
  target:SetModifierStackCount(resistance_loss, ability, stacks)

 --[[ if target:GetMana() < difference and caster:HasModifier("modifier_item_aghanims_shard") then 
    ability:ApplyDataDrivenModifier(target, target, "modifier_silence", {})
  end--]]
else 
  if caster:PassivesDisabled() then
  target:RemoveModifierByName(resistance_loss)
end
end
end

function stacktrack( keys)
  local modifier = "modifier_resistance_loss"
  if not keys.target:HasModifier("modifier_reduction_aura") then
    keys.target:RemoveModifierByName(modifier)
  end
end

function auraShard( keys )
local caster = keys.caster
local target = keys.target
local ability = keys.ability




end