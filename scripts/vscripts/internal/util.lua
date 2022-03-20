function DebugPrint(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    print(...)
  end
end

function DebugPrintTable(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    PrintTable(...)
  end
end

function PrintTable(t, indent, done)
  --print ( string.format ('PrintTable type %s', type(keys)) )
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  for k, v in pairs(t) do
    table.insert(l, k)
  end

  table.sort(l)
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'


function DebugAllCalls()
    if not GameRules.DebugCalls then
        print("Starting DebugCalls")
        GameRules.DebugCalls = true

        debug.sethook(function(...)
            local info = debug.getinfo(2)
            local src = tostring(info.short_src)
            local name = tostring(info.name)
            if name ~= "__index" then
                print("Call: ".. src .. " -- " .. name .. " -- " .. info.currentline)
            end
        end, "c")
    else
        print("Stopped DebugCalls")
        GameRules.DebugCalls = false
        debug.sethook(nil, "c")
    end
end




--[[Author: Noya
  Date: 09.08.2015.
  Hides all dem hats
]]
function HideWearables( unit )
  unit.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    local model = unit:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            model:AddEffects(EF_NODRAW) -- Set model hidden
            table.insert(unit.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end
end

function ShowWearables( unit )

  for i,v in pairs(unit.hiddenWearables) do
    v:RemoveEffects(EF_NODRAW)
  end
end

function RollPseudoRandom(base_chance, entity)
  local chances_table = {
    {1, 0.015604},
    {2, 0.062009},
    {3, 0.138618},
    {4, 0.244856},
    {5, 0.380166},
    {6, 0.544011},
    {7, 0.735871},
    {8, 0.955242},
    {9, 1.201637},
    {10, 1.474584},
    {11, 1.773627},
    {12, 2.098323},
    {13, 2.448241},
    {14, 2.822965},
    {15, 3.222091},
    {16, 3.645227},
    {17, 4.091991},
    {18, 4.562014},
    {19, 5.054934},
    {20, 5.570404},
    {21, 6.108083},
    {22, 6.667640},
    {23, 7.248754},
    {24, 7.851112},
    {25, 8.474409},
    {26, 9.118346},
    {27, 9.782638},
    {28, 10.467023},
    {29, 11.171176},
    {30, 11.894919},
    {31, 12.637932},
    {32, 13.400086},
    {33, 14.180520},
    {34, 14.981009},
    {35, 15.798310},
    {36, 16.632878},
    {37, 17.490924},
    {38, 18.362465},
    {39, 19.248596},
    {40, 20.154741},
    {41, 21.092003},
    {42, 22.036458},
    {43, 22.989868},
    {44, 23.954015},
    {45, 24.930700},
    {46, 25.987235},
    {47, 27.045294},
    {48, 28.100764},
    {49, 29.155227},
    {50, 30.210303},
    {51, 31.267664},
    {52, 32.329055},
    {53, 33.411996},
    {54, 34.736999},
    {55, 36.039785},
    {56, 37.321683},
    {57, 38.583961},
    {58, 39.827833},
    {59, 41.054464},
    {60, 42.264973},
    {61, 43.460445},
    {62, 44.641928},
    {63, 45.810444},
    {64, 46.966991},
    {65, 48.112548},
    {66, 49.248078},
    {67, 50.746269},
    {68, 52.941176},
    {69, 55.072464},
    {70, 57.142857},
    {71, 59.154930},
    {72, 61.111111},
    {73, 63.013699},
    {74, 64.864865},
    {75, 66.666667},
    {76, 68.421053},
    {77, 70.129870},
    {78, 71.794872},
    {79, 73.417722},
    {80, 75.000000},
    {81, 76.543210},
    {82, 78.048780},
    {83, 79.518072},
    {84, 80.952381},
    {85, 82.352941},
    {86, 83.720930},
    {87, 85.057471},
    {88, 86.363636},
    {89, 87.640449},
    {90, 88.888889},
    {91, 90.109890},
    {92, 91.304348},
    {93, 92.473118},
    {94, 93.617021},
    {95, 94.736842},
    {96, 95.833333},
    {97, 96.907216},
    {98, 97.959184},
    {99, 98.989899},  
    {100, 100}
  }

  entity.pseudoRandomModifier = entity.pseudoRandomModifier or 0
  local prngBase
  for i = 1, #chances_table do
    if base_chance == chances_table[i][1] then      
      prngBase = chances_table[i][2]
    end  
  end

  if not prngBase then
--    print("The chance was not found! Make sure to add it to the table or change the value.")
    return false
  end
  
  if RollPercentage( prngBase + entity.pseudoRandomModifier ) then
    entity.pseudoRandomModifier = 0
    return true
  else
    entity.pseudoRandomModifier = entity.pseudoRandomModifier + prngBase    
    return false
  end
end


function ChangeAttackProjectileImba(unit)

  local particle_deso = "particles/items_fx/desolator_projectile.vpcf"
  local particle_skadi = "particles/items2_fx/skadi_projectile.vpcf"
  local particle_lifesteal = "particles/item/lifesteal_mask/lifesteal_particle.vpcf"
  local particle_deso_skadi = "particles/item/desolator/desolator_skadi_projectile_2.vpcf"
  local particle_clinkz_arrows = "particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf"
  local particle_dragon_form_green = "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_corrosive.vpcf"
  local particle_dragon_form_red = "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_fire.vpcf"
  local particle_dragon_form_blue = "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_frost.vpcf"
  local particle_terrorblade_transform = "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_base_attack.vpcf"

  -- If the unit has a Desolator and a Skadi, use the special projectile
  if unit:HasModifier("modifier_item_imba_desolator") or unit:HasModifier("modifier_item_imba_desolator_2") then
    if unit:HasModifier("modifier_item_imba_skadi") then
      unit:SetRangedProjectileName(particle_deso_skadi)
    -- If only a Desolator, use its attack projectile instead
    else
      unit:SetRangedProjectileName(particle_deso)
    end
  -- If only a Skadi, use its attack projectile instead
  elseif unit:HasModifier("modifier_item_imba_skadi") then
    unit:SetRangedProjectileName(particle_skadi)

  -- If the unit has any form of lifesteal, use the lifesteal projectile
  elseif unit:HasModifier("modifier_imba_morbid_mask") or unit:HasModifier("modifier_imba_mask_of_madness") or unit:HasModifier("modifier_imba_satanic") or unit:HasModifier("modifier_item_imba_vladmir") or unit:HasModifier("modifier_item_imba_vladmir_blood") then   
    unit:SetRangedProjectileName(particle_lifesteal)  

  -- If it's one of Dragon Knight's forms, use its attack projectile instead
  elseif unit:HasModifier("modifier_dragon_knight_corrosive_breath") then
    unit:SetRangedProjectileName(particle_dragon_form_green)
  elseif unit:HasModifier("modifier_dragon_knight_splash_attack") then
    unit:SetRangedProjectileName(particle_dragon_form_red)
  elseif unit:HasModifier("modifier_dragon_knight_frost_breath") then
    unit:SetRangedProjectileName(particle_dragon_form_blue)

  -- If it's a metamorphosed Terrorblade, use its attack projectile instead
  elseif unit:HasModifier("modifier_terrorblade_metamorphosis") then
    unit:SetRangedProjectileName(particle_terrorblade_transform)

  -- Else, default to the base ranged projectile
  else
--    print(unit:GetKeyValue("ProjectileModel"))
    unit:SetRangedProjectileName(unit:GetKeyValue("ProjectileModel"))
  end
end


function CDOTA_BaseNPC:HasShard()
  if self:HasModifier("modifier_item_aghanims_shard") then
    return true
  end

  return false
end

function RemoveLinkens( target )
  local target = target
  if target:HasModifier("modifier_item_sphere_target") then
    target:RemoveModifierByName("modifier_item_sphere_target")  --The particle effect is played automatically when this modifier is removed (but the sound isn't).
  elseif target:HasItemInInventory("item_sphere") then
    for i=0,5 do
      local item = target:GetItemInSlot(i)
      if item and target:GetItemInSlot(i):GetName() == "item_sphere" then
        item:StartCooldown(item:GetCooldown(-1))
      end
    end
  end
end