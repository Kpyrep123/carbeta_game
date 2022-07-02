function C_DOTA_BaseNPC:HasTalent(talentName)
    local talent = self:FindAbilityByName(talentName)
    if talent and talent:GetLevel() > 0 then
        return true
    end

    return false
end


function C_DOTA_BaseNPC:GetTalentValue(talentName)
    local talent = self:FindAbilityByName(talentName)
    print(talentName)
    if talent and talent:GetLevel() > 0 then
        return talent:GetSpecialValueFor("value")
    end
    
    return 0
end
function CalculateDistance(ent1, ent2)
  local pos1 = ent1
  local pos2 = ent2
  if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
  if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
  local distance = (pos1 - pos2):Length2D()
  return distance
end


function MergeTables( t1, t2 )
  for name,info in pairs(t2) do
    t1[name] = info
  end
end

function C_DOTA_BaseNPC:HasShard()
  if self:HasModifier("modifier_item_aghanims_shard") then
    return true
  end

  return false
end

function C_DOTABaseAbility:GetTalentSpecialValueFor(value)
  local base = self:GetSpecialValueFor(value)
  local talentName
  local kv = self:GetAbilityKeyValues()
  for k,v in pairs(kv) do -- trawl through keyvalues
    if k == "AbilitySpecial" then
      for l,m in pairs(v) do
        if m[value] then
          talentName = m["LinkedSpecialBonus"]
        end
      end
    end
  end
  if talentName then 
    local talent = self:GetCaster():FindAbilityByName(talentName)
    if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
  end
  return base
end

function C_DOTA_BaseNPC:FindTalentValue(talentName, key)
  if self:HasModifier("modifier_"..talentName) then  
    local value_name = key or "value"
    local specialVal = AbilityKV[talentName]["AbilitySpecial"]
    for l,m in pairs(specialVal) do
      if m[value_name] then
        return m[value_name]
      end
    end
  end    
  return 0
end


