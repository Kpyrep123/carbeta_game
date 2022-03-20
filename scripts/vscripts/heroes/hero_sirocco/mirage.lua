

if IsServer() then
  require('abilities/life_in_arena/utils')
end

function mirage( keys )
local target = keys.target
local caster = keys.caster
local ability = keys.ability
local ability_level = ability:GetLevel() - 1
local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
  if target:TriggerSpellAbsorb(ability) then
    return 
  end
  
  if target:GetUnitName() == "npc_dota_roshan" then 
    return 
  end
    
  if not caster.count_ill then
    caster.count_ill=0
  end

  target:EmitSound("Hero_Pugna.Decrepify")
  ability:ApplyDataDrivenModifier(caster, target, 'modifier_illusionist_mastery_of_illusions', {duration = durationTarget} )
  ability:ApplyDataDrivenModifier(caster, caster, "modifier_invisa", {duration = duration})
  caster:AddNewModifier(caster, caster, "modifier_invisible", {duration = duration})
    ApplyDamage({
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = ability:GetAbilityDamageType(),
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = ability
      })  

  local count_illusion = ability:GetSpecialValueFor("count_illusion")
  local duration = ability:GetSpecialValueFor("duration") + caster:GetTalentValue("special_bonus_unique_sirocco_mirage_dur")
  local outgoingDamage = ability:GetSpecialValueFor("illusion_dealt") + caster:GetTalentValue("special_bonus_unique_sirocco_out_dam")
  local incomingDamage = ability:GetSpecialValueFor("illusion_taken")

  local origin = caster:GetAbsOrigin()

  for i=1,count_illusion do
    local illus = CreateIllusion(caster,caster,origin,duration,outgoingDamage,incomingDamage)
    illus:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
  end
end
