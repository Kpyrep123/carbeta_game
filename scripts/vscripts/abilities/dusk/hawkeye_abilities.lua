require('lib/physics')
require('lib/util_dusk')
require('lib/timers')

function hawkeye_double_tap(event)
  local caster = event.caster
  local caster_pos = caster:GetAbsOrigin()
  local distance = 2500 + caster:GetTalentValue("shot_range")
  local target = caster:GetCursorPosition()
  local direction = (target - caster_pos):Normalized()
  local speed = 10000
  local point = caster_pos+direction*distance
  
  caster:EmitSound("Ability.Assassinate")

  local point = point + Vector(0,0,300)
  
  local target = FastDummy(point, caster:GetTeam(), 5, 0)
  
  local info = 
  {
  Target = target,
  Source = caster,
  Ability = caster:FindAbilityByName("hawkeye_double_tap_visuals"),  
  EffectName = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf",
  vSpawnOrigin = target:GetAbsOrigin(),
  fDistance = distance,
  fStartRadius = 64,
  fEndRadius = 64,
  bHasFrontalCone = false,
  bReplaceExisting = false,
  iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
  iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
  iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
  fExpireTime = GameRules:GetGameTime() + 10.0,
  bDeleteOnHit = true,
  iMoveSpeed = speed,
  bProvidesVision = false,
  iVisionRadius = 0,
  iVisionTeamNumber = caster:GetTeamNumber(),
  iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
  }
  
  local projectile = ProjectileManager:CreateTrackingProjectile(info)
  
  local info = 
  {
  Ability = event.ability,
  EffectName = "",
  vSpawnOrigin = caster:GetAbsOrigin(),
  fDistance = distance,
  fStartRadius = 90,
  fEndRadius = 90,
  Source = caster,
  bHasFrontalCone = false,
  bReplaceExisting = false,
  iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
  iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
  iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
  fExpireTime = GameRules:GetGameTime() + 10.0,
  vVelocity = direction * speed,
  bProvidesVision = true,
  iVisionRadius = 600,
  iVisionTeamNumber = caster:GetTeamNumber()
  }
  local projectile = ProjectileManager:CreateLinearProjectile(info)
end

function hawkeye_double_tap_hit(event)
  local caster = event.caster
  local target = event.target
  local ability = event.ability
  local ability_level = ability:GetLevel() - 1
  local target_hp = target:GetMaxHealth()
  local duration = ability:GetLevelSpecialValueFor("markdur", ability_level)
  local mult = event.mult + caster:GetTalentValue("shot_damage")
  -- if caster:HasScepter() then mult = event.mult_scepter or 1.25 end
  local basedmg = event.ability:GetLevelSpecialValueFor("base_damage",event.ability:GetLevel()-1)
    
  local damage = caster:GetAverageTrueAttackDamage(caster)*mult/100+basedmg
  
  print("DAMAGE IS AT "..damage.." AND BASE DAMAGE IS AT "..caster:GetAverageTrueAttackDamage(caster))
--  local damage = target_hp*0.5
  local dmgTable = {
    attacker = caster,
    victim = target,
    damage = damage,
    damage_type = event.ability:GetAbilityDamageType(),
    ability = event.ability
    }
    ApplyDamage(dmgTable)
  --if not target:IsAlive() then table.remove(caster.hitlist,target) end  

end
