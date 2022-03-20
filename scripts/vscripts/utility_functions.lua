--[[ utility_functions.lua ]]

---------------------------------------------------------------------------
-- Handle messages
---------------------------------------------------------------------------
function BroadcastMessage( sMessage, fDuration )
    local centerMessage = {
        message = sMessage,
        duration = fDuration
    }
    FireGameEvent( "show_center_message", centerMessage )
end

function PickRandomShuffle( reference_list, bucket )
    if ( #reference_list == 0 ) then
        return nil
    end
    
    if ( #bucket == 0 ) then
        -- ran out of options, refill the bucket from the reference
        for k, v in pairs(reference_list) do
            bucket[k] = v
        end
    end

    -- pick a value from the bucket and remove it
    local pick_index = RandomInt( 1, #bucket )
    local result = bucket[ pick_index ]
    table.remove( bucket, pick_index )
    return result
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function ShuffledList( orig_list )
	local list = shallowcopy( orig_list )
	local result = {}
	local count = #list
	for i = 1, count do
		local pick = RandomInt( 1, #list )
		result[ #result + 1 ] = list[ pick ]
		table.remove( list, pick )
	end
	return result
end

function TableCount( t )
	local n = 0
	for _ in pairs( t ) do
		n = n + 1
	end
	return n
end

function TableFindKey( table, val )
	if table == nil then
		print( "nil" )
		return nil
	end

	for k, v in pairs( table ) do
		if v == val then
			return k
		end
	end
	return nil
end

function CountdownTimer()
    nCOUNTDOWNTIMER = nCOUNTDOWNTIMER - 1
    local t = nCOUNTDOWNTIMER
    --print( t )
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local broadcast_gametimer = 
        {
            timer_minute_10 = m10,
            timer_minute_01 = m01,
            timer_second_10 = s10,
            timer_second_01 = s01,
        }
    CustomGameEventManager:Send_ServerToAllClients( "countdown", broadcast_gametimer )
    if t <= 120 then
        CustomGameEventManager:Send_ServerToAllClients( "time_remaining", broadcast_gametimer )
    end
end

function SetTimer( cmdName, time )
    print( "Set the timer to: " .. time )
    nCOUNTDOWNTIMER = time
end


function CDOTA_BaseNPC:HasTalent(talentName)
    local talent = self:FindAbilityByName(talentName)
    if talent and talent:GetLevel() > 0 then
        return true
    end

    return false
end

function CDOTA_BaseNPC:GetTalentValue(talentName)
    local talent = self:FindAbilityByName(talentName)
    if talent and talent:GetLevel() > 0 then
        return talent:GetSpecialValueFor("value")
    end
    
    return 0
end


function CDOTABaseAbility:GetTalentSpecialValueFor(value)
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

function CheckForInnates(npc)
    if(npc:HasAbility("parasight_combust")) then
        local innate = npc:FindAbilityByName("parasight_combust")
        if innate then innate:SetLevel(1) end
    elseif(npc:HasAbility("viscous_ooze_size_mutator")) then
        local innate = npc:FindAbilityByName("viscous_ooze_size_mutator")
        if innate then innate:SetLevel(1) end
    elseif(npc:HasAbility("scaldris_antipode")) then
        local innate = npc:FindAbilityByName("scaldris_antipode")
        if innate then innate:SetLevel(1) end
    elseif(npc:HasAbility("hellion_ambient_effects")) then
        local innate = npc:FindAbilityByName("hellion_ambient_effects")
        if innate then innate:SetLevel(1) end
    elseif(npc:HasAbility("dragon_knight_elder_dragon_form")) then
        npc:AddNewModifier(npc, nil, "modifier_dragon_knight_aghs", {})
    --Lathall
    -- elseif(npc:HasAbility("lathaal_superposition")) then
    --  local innate = npc:FindAbilityByName("lathaal_superposition")
    --  if innate then innate:SetLevel(1) end
    elseif(npc:GetName() == "npc_dota_hero_life_stealer") then
        local innate = npc:FindAbilityByName("horror_lastspell")
        if innate then innate:SetLevel(1) end
    elseif(npc:GetName() == "npc_dota_hero_lich") then
        local innate = npc:FindAbilityByName("collector_seance")
        if innate then npc:AddNewModifier(npc, innate, "modifier_collector_lastdeath", {}) end
    elseif(npc:GetName() == "npc_dota_hero_slark") then
        local innate = npc:FindAbilityByName("genos_adaptation")
        if innate then innate:SetLevel(1) end
    elseif(npc:GetName() == "npc_dota_hero_rubick") then
        --[[ Note that this implementation does not allow rubick's 
        Skulk and Cold Spot to benefit from cooldown reduction.
        I don't want to add innate abilities to heroes that do
        not have them, so for now we are pending a fix to the 
        method through which Cold Spot and Skulk handle CDR.]]
        local innate = npc:FindAbilityByName("rubick_spell_steal")
        if innate then 
            npc:AddNewModifier(npc, innate, "modifier_horror_lastspell", {}) 
            npc:AddNewModifier(npc, innate, "modifier_collector_lastdeath", {})
        end
    elseif (npc:HasAbility("warp_beast_silly_attack_mutator")) then
        local innate = npc:FindAbilityByName("warp_beast_silly_attack_mutator")
        if innate then innate:SetLevel(1) end
    end
end


if CosmeticLib == nil then
  print( '[CosmeticLib] Creating Cosmetics Manager' )
  CosmeticLib = {}
  CosmeticLib.__index = CosmeticLib
end

-- Initialize the library, should be called only once
function CosmeticLib:Init()
  if not CosmeticLib.bHasInitialized then
    -- Set flag so it cannot initialize twice
    CosmeticLib.bHasInitialized = true
    
    -- Disable combine models
    SendToServerConsole( "dota_combine_models 0" )
    SendToConsole( "dota_combine_models 0" )
    
    -- Create the tables
    CosmeticLib:_CreateTables()
    
    -- Custom console command
    Convars:RegisterCommand( "print_available_players", function( cmd )
        return CosmeticLib:PrintPlayers()
      end, "Print all available players", FCVAR_CHEAT
    )
    Convars:RegisterCommand( "print_item_sets_for_player", function( cmd, player_id ) 
        return CosmeticLib:PrintSetsForHero( PlayerResource:GetPlayer( tonumber( player_id ) ) )
      end, "Print set item for hero", FCVAR_CHEAT
    )
    Convars:RegisterCommand( "print_items_from_player", function( cmd, player_id )
        return CosmeticLib:PrintItemsFromPlayer( PlayerResource:GetPlayer( tonumber( player_id ) ) )
      end, "Print items currently equipped to assigned hero", FCVAR_CHEAT
    )
    Convars:RegisterCommand( "print_items_for_slot_from_player", function( cmd, player_id, slot_name )
        return CosmeticLib:PrintItemsForSlotFromPlayer( PlayerResource:GetPlayer( tonumber( player_id ) ), slot_name )
      end, "Print items available for certain slot in hero", FCVAR_CHEAT
    )
    Convars:RegisterCommand( "equip_item_set_for_player", function( cmd, player_id, set_id ) 
        local hero = PlayerResource:GetPlayer( tonumber( player_id ) ):GetAssignedHero()
        return CosmeticLib:EquipHeroSet( hero, set_id )
      end, "Equip set item for hero", FCVAR_CHEAT
    )
    Convars:RegisterCommand( "replace_item_by_slot", function( cmd, player_id, slot_name, item_id )
        local hero = PlayerResource:GetPlayer( tonumber( player_id ) ):GetAssignedHero()
        return CosmeticLib:ReplaceWithSlotName( hero, slot_name, item_id )
      end, "Replace item by slot name", FCVAR_CHEAT
    )
    Convars:RegisterCommand( "replace_item_by_id", function( cmd, player_id, old_item_id, new_item_id )
        local hero = PlayerResource:GetPlayer( tonumber( player_id ) ):GetAssignedHero()
        return CosmeticLib:ReplaceWithItemID( hero, old_item_id, new_item_id )
      end, "Replace item by id", FCVAR_CHEAT
    )
    Convars:RegisterCommand( "replace_default", function( cmd, player_id )
        local hero = PlayerResource:GetPlayer( tonumber( player_id ) ):GetAssignedHero()
        return CosmeticLib:ReplaceDefault( hero, hero:GetName() )
      end, "Replace items with default items", FCVAR_CHEAT
    )
    Convars:RegisterCommand( "remove_from_slot", function( cmd, player_id, slot_name )
        local hero = PlayerResource:GetPlayer( tonumber( player_id ) ):GetAssignedHero()
        return CosmeticLib:RemoveFromSlot( hero, slot_name )
      end, "Remove cosmetic in certain slot", FCVAR_CHEAT
    )
    Convars:RegisterCommand( "remove_all", function( cmd, player_id )
        local hero = PlayerResource:GetPlayer( tonumber( player_id ) ):GetAssignedHero()
        return CosmeticLib:RemoveAll( hero )
      end, "Remove all cosmetics from hero", FCVAR_CHEAT
    )
  end
end

-- Create table in the structure specified above
function CosmeticLib:_CreateTables()
  -- Load in values
  local kvLoadedTable = LoadKeyValues( "scripts/items/items_game.txt" )
  CosmeticLib._AllItemsByID = kvLoadedTable[ "items" ]
  CosmeticLib._NameToID = CosmeticLib._NameToID or {}                   -- Structure table[ "item_name" ] = item_id
  
  -- Create these tables for faster lookup time
  for CosmeticID, CosmeticTable in pairs( CosmeticLib._AllItemsByID ) do          -- Extract only from items block
    if CosmeticTable[ "prefab" ] then 
      if CosmeticTable[ "prefab" ] == "default_item" and CosmeticTable[ "used_by_heroes" ]
          and type( CosmeticTable[ "used_by_heroes" ] ) == "table" then     -- Insert default items
        CosmeticLib:_InsertIntoDefaultTable( CosmeticID )
        CosmeticLib._NameToID[ CosmeticTable[ "name" ] ] = CosmeticID
      elseif CosmeticTable[ "prefab" ] == "wearable" and CosmeticTable[ "used_by_heroes" ]
          and type( CosmeticTable[ "used_by_heroes" ] ) == "table" then     -- Insert wearable items
        CosmeticLib:_InsertIntoWearableTable( CosmeticID )
        CosmeticLib._NameToID[ CosmeticTable[ "name" ] ] = CosmeticID
      elseif CosmeticTable[ "prefab" ] == "courier" then                -- Insert couriers
        CosmeticLib:_InsertIntoCourierTable( CosmeticID )
        CosmeticLib._NameToID[ CosmeticTable[ "name" ] ] = CosmeticID
      elseif CosmeticTable[ "prefab" ] == "ward" then
        CosmeticLib:_InsertIntoWardTable( CosmeticID )
        CosmeticLib._NameToID[ CosmeticTable[ "name" ] ] = CosmeticID
      end
    end
  end
  
  -- Run second time for bundle
  for CosmeticID, CosmeticTable in pairs( CosmeticLib._AllItemsByID ) do          -- Extract only from items block
    if CosmeticTable[ "prefab" ] and CosmeticTable[ "prefab" ] == "bundle"
        and CosmeticTable[ "used_by_heroes" ] ~= nil and type( CosmeticTable[ "used_by_heroes" ] ) == "table" then
      CosmeticLib:_InsertIntoBundleTable( CosmeticID )
      CosmeticLib._NameToID[ CosmeticTable[ "name" ] ] = CosmeticID
    end
  end
  
  CosmeticLib._AllItemsByID[ "-1" ] = {}
  CosmeticLib._AllItemsByID[ "-1" ][ "model_player" ] = "models/development/invisiblebox.vmdl"
end

--[[
====================================================================================================================
=========================================Direct Commands============================================================
====================================================================================================================
]]

-- Print available players for replace
function CosmeticLib:PrintPlayers()
  local players = {}
  for i = 0, 9 do
    local player = PlayerResource:GetPlayer( i )
    if player and player:GetAssignedHero() then
      table.insert( players, i )
    end
  end
  
  print( "[CosmeticLib] Available players are" )
  for k, v in pairs( players ) do
    print( "[CosmeticLib] Player " .. v )
  end
end

-- Print available set_id for player with id player_id to console
function CosmeticLib:PrintSetsForHero( player )
  local hero = player:GetAssignedHero()
  local hero_sets = CosmeticLib:GetAllSetsForHero( hero:GetName() )
  print( "[CosmeticLib] Available set for " .. hero:GetName() .. " are" )
  for _, item_id in pairs( hero_sets ) do
    print( "[CosmeticLib] Set ID: " .. item_id .. "\tName: " .. CosmeticLib._AllItemsByID[ item_id ][ "name" ] )
  end
end

-- Print all item slots and its associated item id from player_id to console
function CosmeticLib:PrintItemsFromPlayer( player )
  local hero = player:GetAssignedHero()
  if hero and hero:IsRealHero() then
    if CosmeticLib:_Identify( hero )then
      print( "[CosmeticLib] Current cosmetics: " )
      for item_slot, handle_table in pairs( hero._cosmeticlib_wearables_slots ) do
        print( "[CosmeticLib] Item ID: " .. handle_table[ "item_id" ] .. "\tSlot: " .. item_slot )
      end
    end
  end
end

-- Print all items for certain slot from player
function CosmeticLib:PrintItemsForSlotFromPlayer( player, slot_name )
  local hero = player:GetAssignedHero()
  if hero and hero:IsRealHero() then
    if CosmeticLib._WearableForHero[ hero:GetName() ] and CosmeticLib._WearableForHero[ hero:GetName() ][ slot_name ] then
      for item_name, item_id in pairs( CosmeticLib._WearableForHero[ hero:GetName() ][ slot_name ] ) do
        print( "[CosmeticLib] Item ID: " .. item_id .. "\tItem Name: " .. item_name )
      end
    else
      print( "[CosmeticLib] Invalid input. Please try again." )
    end
  end
end

--[[
====================================================================================================================
========================================Create Table Functions======================================================
====================================================================================================================
]]

-- Create sub table with new key value, return true if it existed or is able to create one
function CosmeticLib:_CheckSubTable( new_key, table_to_insert )
  if new_key and table_to_insert and type( table_to_insert ) == "table" then
    if table_to_insert[ new_key ] == nil then
      table_to_insert[ new_key ] = {}
    end
    return 1
  else
    return nil
  end
end

-- Insert element into the default wearable table
function CosmeticLib:_InsertIntoDefaultTable( CosmeticID )
  CosmeticLib._DefaultForHero = CosmeticLib._DefaultForHero or {}
  CosmeticLib:_InsertIntoCosmeticTable( CosmeticID, CosmeticLib._DefaultForHero )
end

-- Insert element into the non-default wearable table
function CosmeticLib:_InsertIntoWearableTable( CosmeticID )
  CosmeticLib._WearableForHero = CosmeticLib._WearableForHero or {}
  CosmeticLib:_InsertIntoCosmeticTable( CosmeticID, CosmeticLib._WearableForHero )
end

--[[
  This function will put cosmetics into table
  Structure is
  CosmeticLib._TypeForHero[ "hero_name" ][ "item_slot" ][ "item_name" ] = item_id
]]
function CosmeticLib:_InsertIntoCosmeticTable( CosmeticID, table_to_insert )
  -- All cosmetic will be store in this two tables
  CosmeticLib._SlotToName = CosmeticLib._SlotToName or {}             -- Structure table[ "slot_name" ][ "item_name" ] = item_id
  CosmeticLib._ModelNameToID = CosmeticLib._ModelNameToID or {}         -- Structure table[ "model_name" ] = item_id

  -- Check if it can be used by heroes
  local selected_item = CosmeticLib._AllItemsByID[ "" .. CosmeticID ]
  if not selected_item[ "used_by_heroes" ] or not selected_item[ "model_player" ] then return end
  local usable_by_heroes = selected_item[ "used_by_heroes" ]
  
  for hero_name, _ in pairs( usable_by_heroes ) do
    if CosmeticLib:_CheckSubTable( hero_name, table_to_insert ) then            -- Check on hero name
      local item_slot = selected_item[ "item_slot" ] or "weapon"
      if CosmeticLib:_CheckSubTable( item_slot, table_to_insert[ hero_name ] ) then   -- Check on item slot
        local item_name = selected_item[ "name" ]
        if item_name then                               -- Check on item name
          table_to_insert[ hero_name ][ item_slot ][ item_name ] = CosmeticID
          CosmeticLib._ModelNameToID[ selected_item[ "model_player" ] ] = CosmeticID
          
          if CosmeticLib:_CheckSubTable( item_slot, CosmeticLib._SlotToName ) then  -- Check to add into _SlotToName
            CosmeticLib._SlotToName[ item_slot ][ item_name ] = CosmeticID
          end
        end
      end
    end
  end
end

-- Insert new data into courier table
function CosmeticLib:_InsertIntoCourierTable( CosmeticID )
  CosmeticLib._Couriers = CosmeticLib._Couriers or {}
  
  local selected_item = CosmeticLib._AllItemsByID[ "" .. CosmeticID ]
  
  if CosmeticLib:_CheckSubTable( selected_item[ "name" ], CosmeticLib._Couriers ) then
    CosmeticLib._Couriers[ selected_item[ "name" ] ] = CosmeticID 
  end
end

-- Insert new data into ward table
function CosmeticLib:_InsertIntoWardTable( CosmeticID )
  CosmeticLib._Wards = CosmeticLib._Wards or {}
  
  local selected_item = CosmeticLib._AllItemsByID[ "" .. CosmeticID ]
  
  if CosmeticLib:_CheckSubTable( selected_item[ "name" ], CosmeticLib._Wards ) then
    CosmeticLib._Wards[ selected_item[ "name" ] ] = CosmeticID
  end
end

-- Insert new data into bundle/set table
function CosmeticLib:_InsertIntoBundleTable( CosmeticID )
  CosmeticLib._Sets = CosmeticLib._Sets or {}
  CosmeticLib._SetByHeroes = CosmeticLib._SetByHeroes or {}
  
  local selected_item = CosmeticLib._AllItemsByID[ "" .. CosmeticID ]
  
  if CosmeticLib:_CheckSubTable( selected_item[ "name" ], CosmeticLib._Sets ) then
    -- For hero name lookup
    for hero_name, enabled in pairs( selected_item[ "used_by_heroes" ] ) do
      if CosmeticLib:_CheckSubTable( hero_name, CosmeticLib._SetByHeroes ) then
        CosmeticLib._SetByHeroes[ hero_name ][ selected_item[ "name" ] ] = CosmeticID
      end
    end
    -- For set name lookup
    for cosmetic_name, enabled in pairs( selected_item[ "bundle" ] ) do
      local item_set_id = CosmeticLib:GetIDByName( cosmetic_name )
      if item_set_id then
        local item = CosmeticLib._AllItemsByID[ item_set_id ]
        if item then
          if item[ "item_slot" ] then
            CosmeticLib._Sets[ selected_item[ "name" ] ][ item[ "item_slot" ] ] = item_set_id
          elseif item[ "prefab" ] == "wearable" or item[ "prefab" ] == "default_item" then
            CosmeticLib._Sets[ selected_item[ "name" ] ][ "weapon" ] = item_set_id
          end
        end
      end
    end
  end
end

--[[
====================================================================================================================
===========================================Getter Functions=========================================================
====================================================================================================================
]]

--[[
  Get available cosmetic slots for given hero name
]]
function CosmeticLib:GetAvailableSlotForHero( hero_name )
  if hero_name then
    if CosmeticLib._WearableForHero[ hero_name ] ~= nil then
      local toReturn = {}
      for item_slot, _ in pairs( CosmeticLib._WearableForHero[ hero_name ] ) do
        table.insert( toReturn, item_slot )
      end
      table.sort( toReturn )
      return toReturn
    end
  else
    print( '[CosmeticLib:Getter] Error: Given hero_name does not exist.' )
  end
end

--[[
  Get available cosmetics for hero in given slot
]]
function CosmeticLib:GetAllAvailableForHeroInSlot( hero_name, slot_name )
  if hero_name then
    if CosmeticLib._WearableForHero[ hero_name ][ slot_name ] ~= nil then
      local toReturn = {}
      for item_name, _ in pairs( CosmeticLib._WearableForHero[ hero_name ][ slot_name ] ) do
        table.insert( toReturn, item_name )
      end
      table.sort( toReturn )
      return toReturn
    end
  else
    print( '[CosmeticLib:Getter] Error: Given hero_name does not exist.' )
  end
end


-- Get all available cosmetics name
function CosmeticLib:GetAllAvailableWearablesName()
  if CosmeticLib._NameToID then
    local toReturn = {}
    for k, v in pairs( CosmeticLib._NameToID ) do
      table.insert( toReturn, k )
    end
    table.sort( toReturn )
    return toReturn
  else
    print( '[CosmeticLib:Getter] Error: No cosmetic table found. Please verify that you have item_games.txt in your vpk' )
    return nil
  end
end

-- Get all available cosmetics id
function CosmeticLib:GetAllAvailableWearablesID()
  if CosmeticLib._NameToID then
    local toReturn = {}
    for k, v in pairs( CosmeticLib._NameToID ) do
      table.insert( toReturn, v )
    end
    table.sort( toReturn )
    return toReturn
  else
    print( '[CosmeticLib:Getter] Error: No cosmetic table found. Please verify that you have item_games.txt in your vpk' )
    return nil
  end
end

-- Get all sets
function CosmeticLib:GetSetByName( set_name )
  return CosmeticLib._Sets[ set_name ]
end

-- Get all set for hero
function CosmeticLib:GetAllSetsForHero( hero_name )
  return CosmeticLib._SetByHeroes[ hero_name ]
end

-- Get ID by item name
function CosmeticLib:GetIDByName( item_name )
  if CosmeticLib._NameToID[ item_name ] ~= nil then
    return "" .. CosmeticLib._NameToID[ item_name ]
  end
end

-- Get ID by model name
function CosmeticLib:GetIDByModelName( model_name )
  if CosmeticLib._ModelNameToID[ model_name ] ~= nil then
    return "" .. CosmeticLib._ModelNameToID[ model_name ]
  end
end

--[[
====================================================================================================================
==========================================Replace Functions=========================================================
====================================================================================================================
]]

-- Check if the table existed
function CosmeticLib:_Identify( unit )
  if unit:entindex() then
    if unit._cosmeticlib_wearables_slots == nil then
      unit._cosmeticlib_wearables_slots = {}
      -- Fill the table
      local wearable = unit:FirstMoveChild()
      while wearable do
        if wearable:GetClassname() == "dota_item_wearable" then
          local id = CosmeticLib:GetIDByModelName( wearable:GetModelName() )
          local item = CosmeticLib._AllItemsByID[ id ]
          if item then
            -- Structure table[ item_slot ] = { handle entindex, item_id }
            local item_slot = item[ "item_slot" ] or "weapon"
            unit._cosmeticlib_wearables_slots[ item_slot ] = { handle = wearable, item_id = id }
          end
        end
        wearable = wearable:NextMovePeer()
      end
    end
    return 1
  else
    print( '[CosmeticLib:Replace] Error: Input is not entity' )
    return nil
  end
end

-- Equip set for hero
function CosmeticLib:EquipHeroSet( hero, set_id )
  CosmeticLib:EquipSet( hero, hero:GetName(), set_id )
end

-- Equip set
function CosmeticLib:EquipSet( unit, hero_name, set_id )
  if unit and hero_name and set_id and CosmeticLib:_Identify( unit ) then
    local selected_item = CosmeticLib._AllItemsByID[ "" .. set_id ]
    if selected_item and CosmeticLib._SetByHeroes[ hero_name ]
        and CosmeticLib._SetByHeroes[ hero_name ][ selected_item[ "name" ] ] then
      for slot_name, item_id in pairs ( CosmeticLib._Sets[ selected_item[ "name" ] ] ) do
        CosmeticLib:ReplaceWithSlotName( unit, slot_name, item_id )
      end
      return
    end
  end
  
  print( "[CosmeticLib:EquipSet] Error: Invalid input." )
end

-- Replace any unit back to default based on hero_name
function CosmeticLib:ReplaceDefault( unit, hero_name )
  if unit and hero_name and CosmeticLib:_Identify( unit ) then
    if CosmeticLib._DefaultForHero[ hero_name ] then
      local hero_items = CosmeticLib._DefaultForHero[ hero_name ]
      for slot_name, item_table in pairs( hero_items ) do
        for item_name, item_id in pairs( item_table ) do
          CosmeticLib:ReplaceWithSlotName( unit, slot_name, item_id )
        end
      end
      return
    end
  end
  
  print( "[CosmeticLib:Replace] Error: Invalid input." )
end

-- Remove from slot
function CosmeticLib:RemoveFromSlot( unit, slot_name )
  if unit and slot_name and CosmeticLib:_Identify( unit ) then
    if unit._cosmeticlib_wearables_slots[ slot_name ] then
      CosmeticLib:_Replace( unit._cosmeticlib_wearables_slots[ slot_name ], "-1" )
    end
    return
  end
  
  print( "[CosmeticLib:Remove] Error: Invalid input." )
end

-- Remove all
function CosmeticLib:RemoveAll( unit )
  if unit and CosmeticLib:_Identify( unit ) then
    -- Start force replacing
    for slot_name, handle_table in pairs( unit._cosmeticlib_wearables_slots ) do
      CosmeticLib:_Replace( handle_table, "-1" )
    end
    return
  end
  
  print( "[CosmeticLib:Remove] Error: Invalid input." )
end

-- Replace with check respect to slot name
function CosmeticLib:ReplaceWithSlotName( unit, slot_name, new_item_id )
  if unit and slot_name and new_item_id and CosmeticLib:_Identify( unit ) then
    local handle_table = unit._cosmeticlib_wearables_slots[ slot_name ]
    if handle_table then
      return CosmeticLib:_Replace( handle_table, new_item_id )
    end
  end
  
  print( "[CosmeticLib:Replace] Error: Invalid input." )
end

-- Replace with check respect to old item_id
function CosmeticLib:ReplaceWithItemID( unit, old_item_id, new_item_id )
  if unit and old_item_id and new_item_id and CosmeticLib:_Identify( unit ) then
    for slot_name, handle_table in pairs( unit._cosmeticlib_wearables_slots ) do
      if "" .. handle_table[ "item_id" ] == "" .. old_item_id then
        return CosmeticLib:_Replace( handle_table, new_item_id )
      end
    end
  end

  print( "[CosmeticLib:Replace] Error: Invalid input." )
end

-- Replace cosmetic
-- This should never be called alone
function CosmeticLib:_Replace( handle_table, new_item_id )
  local item = CosmeticLib._AllItemsByID[ "" .. new_item_id ]
  handle_table[ "handle" ]:SetModel( item[ "model_player" ] )
  handle_table[ "item_id" ] = new_item_id
  
  -- Attach particle
  -- Still cannot attach it properly
  if item[ "visual" ] and item[ "visual" ][ "attached_particlesystem0" ] then
    local wearable = handle_table[ "handle" ]
    local counter = 0
    local particle_name = item[ "visual" ][ "attached_particlesystem0" ]
  end
end

--[[
====================================================================================================================
====================================================================================================================
====================================================================================================================
]]

CosmeticLib:Init()