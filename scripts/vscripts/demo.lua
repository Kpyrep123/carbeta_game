function CHPGameMode:SetupDemoMode()
	-- require("utility_functions")
	GameRules:GetGameModeEntity():SetFixedRespawnTime( 4 )
	-- GameMode:SetBotThinkingEnabled( true ) -- the ConVar is currently disabled in C++
	-- Set bot mode difficulty: can try GameMode:SetCustomGameDifficulty( 1 )
	GameRules:SetPreGameTime( 0 )


	GameRules:SetUseUniversalShopMode( true )
	GameRules:SetSameHeroSelectionEnabled( true )

	GameRules:SetCustomVictoryMessageDuration( 1 )
	GameRules:SetCustomGameEndDelay(1)
	GameRules:SetPostGameTime(1)

	-- Events
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( self, 'OnNPCSpawnedDemo' ), self )
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( self, 'OnGameRulesStateChangeDemo' ), self )
	if GameRules:IsCheatMode() then
	  ListenToGameEvent( "dota_item_purchased", Dynamic_Wrap( self, "OnItemPurchasedDemo" ), self )
	end
	ListenToGameEvent( "npc_replaced", Dynamic_Wrap( self, "OnNPCReplacedDemo" ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( self, "OnEntityKilledDemo" ), self )

	CustomGameEventManager:RegisterListener( "WelcomePanelDismissed", function(...) return self:OnWelcomePanelDismissed( ... ) end )
	CustomGameEventManager:RegisterListener( "RefreshButtonPressed", function(...) return self:OnRefreshButtonPressed( ... ) end )
	CustomGameEventManager:RegisterListener( "LevelUpButtonPressed", function(...) return self:OnLevelUpButtonPressed( ... ) end )
	CustomGameEventManager:RegisterListener( "MaxLevelButtonPressed", function(...) return self:OnMaxLevelButtonPressed( ... ) end )
	CustomGameEventManager:RegisterListener( "FreeSpellsButtonPressed", function(...) return self:OnFreeSpellsButtonPressed( ... ) end )
	CustomGameEventManager:RegisterListener( "InvulnerabilityButtonPressed", function(...) return self:OnInvulnerabilityButtonPressed( ... ) end )
	CustomGameEventManager:RegisterListener( "SpawnAllyButtonPressed", function(...) return self:OnSpawnAllyButtonPressed( ... ) end ) -- deprecated
	CustomGameEventManager:RegisterListener( "SpawnEnemyButtonPressed", function(...) return self:OnSpawnEnemyButtonPressed( ... ) end )
	CustomGameEventManager:RegisterListener( "LevelUpEnemyButtonPressed", function(...) return self:OnLevelUpEnemyButtonPressed( ... ) end )
	CustomGameEventManager:RegisterListener( "DummyTargetsButtonPressed", function(...) return self:OnDummyTargetsButtonPressed( ... ) end )
	CustomGameEventManager:RegisterListener( "RemoveSpawnedUnitsButtonPressed", function(...) return self:OnRemoveSpawnedUnitsButtonPressed( ... ) end )
	CustomGameEventManager:RegisterListener( "LaneCreepsButtonPressed", function(...) return self:OnLaneCreepsButtonPressed( ... ) end )
	CustomGameEventManager:RegisterListener( "ChangeHeroButtonPressed", function(...) return self:OnChangeHeroButtonPressed( ... ) end )
	CustomGameEventManager:RegisterListener( "ChangeCosmeticsButtonPressed", function(...) return self:OnChangeCosmeticsButtonPressed( ... ) end )
	CustomGameEventManager:RegisterListener( "PauseButtonPressed", function(...) return self:OnPauseButtonPressed( ... ) end )
	CustomGameEventManager:RegisterListener( "LeaveButtonPressed", function(...) return self:OnLeaveButtonPressed( ... ) end )

	-- GameRules:SetCustomGameTeamMaxPlayers(1, 0)
	-- GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 1 )
	-- GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 1 )
	
	if GameRules:IsCheatMode() then
	  SendToServerConsole( "sv_cheats 1" )
	  SendToServerConsole( "dota_hero_god_mode 0" )
	  SendToServerConsole( "dota_ability_debug 0" )
	  SendToServerConsole( "dota_creeps_no_spawning 0" )
	end
	--SendToServerConsole( "dota_bot_mode 1" )

	self.m_sHeroSelection = sHeroSelection -- this seems redundant, but events.lua doesn't seem to know about sHeroSelection

	self.m_bPlayerDataCaptured = false
	self.m_nPlayerID = 0

	--self.m_nHeroLevelBeforeMaxing = 1 -- unused now
	--self.m_bHeroMaxedOut = false -- unused now
	
	self.m_nALLIES_TEAM = 2
	self.m_tAlliesList = {}
	self.m_nAlliesCount = 0

	self.m_nENEMIES_TEAM = 3
	self.m_tEnemiesList = {}

	self.m_nDUMMIES_TEAM = 4
	self.m_tDummiesList = {}
	self.m_nDummiesCount = 0
	self.m_bDummiesEnabled = true

	self.m_bFreeSpellsEnabled = false
	self.m_bInvulnerabilityEnabled = false
	self.m_bCreepsEnabled = true

	self.m_CheckUI = true

	local hNeutralSpawn = Entities:FindByName( nil, "neutral_caster_spawn" )
	self._hNeutralCaster = CreateUnitByName( "npc_dota_neutral_caster", hNeutralSpawn:GetAbsOrigin(), false, nil, nil, NEUTRAL_TEAM )
	-- print(self._hNeutralCaster)
	GameRules:SetCustomGameSetupTimeout( 0 ) -- skip the custom team UI with 0, or do indefinite duration with -1
	PlayerResource:SetCustomTeamAssignment( self.m_nPlayerID, self.m_nALLIES_TEAM ) -- put PlayerID 0 on Radiant team (== team 2)
	if IsInToolsMode() then
	end
end

--[[ Events ]]
--------------------------------------------------------------------------------
-- GameEvent:OnGameRulesStateChange
--------------------------------------------------------------------------------
function CHPGameMode:OnGameRulesStateChangeDemo()
	local nNewState = GameRules:State_Get()
	print( "OnGameRulesStateChange: " .. nNewState )

	if nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		print( "OnGameRulesStateChange: Hero Selection" )

	elseif nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		print( "OnGameRulesStateChange: Pre Game Selection" )
		SendToServerConsole( "dota_dev forcegamestart" )

	elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		print( "OnGameRulesStateChange: Game In Progress" )
	end
end

--------------------------------------------------------------------------------
-- GameEvent: OnNPCSpawned
--------------------------------------------------------------------------------
function CHPGameMode:OnNPCSpawnedDemo( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if spawnedUnit and spawnedUnit:GetPlayerOwnerID() == 0 and spawnedUnit:IsRealHero() and not spawnedUnit:IsClone() then
		print( "spawnedUnit is player's hero" )
		local hPlayerHero = spawnedUnit
		hPlayerHero:SetContextThink( "self:Think_InitializePlayerHero", function() return self:Think_InitializePlayerHero( hPlayerHero ) end, 0 )
	end
	
	if spawnedUnit:GetUnitName() == "npc_dota_neutral_caster" then
		--print( "Neutral Caster spawned" )
		spawnedUnit:SetContextThink( "self:Think_InitializeNeutralCaster", function() return self:Think_InitializeNeutralCaster( spawnedUnit ) end, 0 )
	end
end

--------------------------------------------------------------------------------
-- GameEvent: OnAbilityUsed
--------------------------------------------------------------------------------
-- function CHPGameMode:OnAbilityUsedDemo( event )
-- 	if self.m_bFreeSpellsEnabled then
-- 		local ply = EntIndexToHScript( event.PlayerID )
-- 		if ply then
-- 			local hero = PlayerResource:GetSelectedHeroEntity( event.PlayerID )
-- 			if hero then 
-- 				local abilityName = event.abilityname
-- 				if abilityName then
-- 					local ability = hero:FindAbilityByName(ability)
-- 					if ability then
-- 						print("refreshing")
-- 						ability:RefundManaCost()
-- 						ability:EndCooldown()
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- end

--------------------------------------------------------------------------------
-- Event: OnItemPickUp
--------------------------------------------------------------------------------
--[[function CHPGameMode:OnItemPickUp( event )
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner = EntIndexToHScript( event.HeroEntityIndex )
	--r = RandomInt(200, 400)
	if event.itemname == "item_bag_of_gold" then
		--print("Bag of gold picked up")
		PlayerResource:ModifyGold( owner:GetPlayerID(), r, true, 0 )
		UTIL_Remove( item ) -- otherwise it pollutes the player inventory
	end
end
]]--
--------------------------------------------------------------------------------
-- Think_InitializePlayerHero
--------------------------------------------------------------------------------
function CHPGameMode:Think_InitializePlayerHero( hPlayerHero )
	if not hPlayerHero then
		return 0.1
	end

	if self.m_bPlayerDataCaptured == false then
		local nPlayerID = hPlayerHero:GetPlayerOwnerID()
		PlayerResource:ModifyGold( nPlayerID, 99999, true, 0 )
		if hPlayerHero:GetUnitName() == self.m_sHeroSelection then
			self.m_bPlayerDataCaptured = true
		end
	end

	if self.m_bInvulnerabilityEnabled then
		local hAllPlayerUnits = {}
		hAllPlayerUnits = hPlayerHero:GetAdditionalOwnedUnits()
		hAllPlayerUnits[ #hAllPlayerUnits + 1 ] = hPlayerHero

		for _, hUnit in pairs( hAllPlayerUnits ) do
			hUnit:AddNewModifier( hPlayerHero, nil, "lm_take_no_damage", nil )
		end
	end

	local hPlayerOwner = hPlayerHero:GetPlayerOwner()
	if hPlayerOwner and not hPlayerOwner.checkUI then
		hPlayerOwner.checkUI = true
		Timers:CreateTimer(1.0, function() 
			CustomGameEventManager:Send_ServerToPlayer(hPlayerOwner, "map_check", event)
		end)
	end

	return
end

--------------------------------------------------------------------------------
-- Think_InitializeNeutralCaster
--------------------------------------------------------------------------------
function CHPGameMode:Think_InitializeNeutralCaster( neutralCaster )
	if not neutralCaster then
		return 0.1
	end

	print("Initialzing Neutral Caster")
	print( "neutralCaster:AddAbility( \"la_spawn_enemy_at_target\" )" )
	neutralCaster:AddAbility( "la_spawn_enemy_at_target" )
	return
end

--------------------------------------------------------------------------------
-- Think_InitializeNeutralCaster
--------------------------------------------------------------------------------
function CHPGameMode:Think_InitializeCustomUI( neutralCaster )
	if not neutralCaster then
		return 0.1
	end

	print( "neutralCaster:AddAbility( \"la_spawn_enemy_at_target\" )" )
	neutralCaster:AddAbility( "la_spawn_enemy_at_target" )
	return
end

--------------------------------------------------------------------------------
-- GameEvent: OnItemPurchasedDemo
--------------------------------------------------------------------------------
function CHPGameMode:OnItemPurchasedDemo( event )
	local hBuyer = PlayerResource:GetPlayer( event.PlayerID )
	local hBuyerHero = hBuyer:GetAssignedHero()
	hBuyerHero:ModifyGold( event.itemcost, true, 0 )
end

--------------------------------------------------------------------------------
-- GameEvent: OnNPCReplacedDemo
--------------------------------------------------------------------------------
function CHPGameMode:OnNPCReplacedDemo( event )
	local sNewHeroName = PlayerResource:GetSelectedHeroName( event.new_entindex )
	print( "sNewHeroName == " .. sNewHeroName ) -- we fail to get in here
	self:BroadcastMsg( "Changed hero to " .. sNewHeroName )
end

--------------------------------------------------------------------------------
-- GameEvent: OnEntityKilledDemo
--------------------------------------------------------------------------------
function CHPGameMode:OnEntityKilledDemo( keys )
	local killedEntity = EntIndexToHScript( keys.entindex_killed )

	if killedEntity:IsHero() and keys.entindex_attacker ~= nil then
	    local killerEntity = EntIndexToHScript( keys.entindex_attacker )
	    local teamkills = PlayerResource:GetTeamKills(killerEntity:GetTeamNumber())
	    if teamkills >= 2 and not GameRules:IsCheatMode() then
	      GameRules:SetCustomVictoryMessage( "Thanks for playing!" )
		  GameRules:SetCustomVictoryMessageDuration( 3.0 )
		  GameRules:SetGameWinner( killerEntity:GetTeamNumber() )
	    end
	end
	if killedEntity:IsBuilding() and keys.entindex_attacker ~= nil then
		local killerEntity = EntIndexToHScript( keys.entindex_attacker )
		if not GameRules:IsCheatMode() then
	      GameRules:SetCustomVictoryMessage( "Thanks for playing!" )
		  GameRules:SetCustomVictoryMessageDuration( 3.0 )
		  GameRules:SetGameWinner( killerEntity:GetTeamNumber() )
	    end
	end
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnWelcomePanelDismissed
--------------------------------------------------------------------------------
function CHPGameMode:OnWelcomePanelDismissed( event )
	print( "Entering CHPGameMode:OnWelcomePanelDismissed( event )" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnRefreshButtonPressed
--------------------------------------------------------------------------------
function CHPGameMode:OnRefreshButtonPressed( eventSourceIndex )
	if GameRules:IsCheatMode() then
		SendToServerConsole( "dota_dev hero_refresh" )
	else
		for k, hero in pairs(HeroList:GetAllHeroes()) do
			self:RefreshHero(hero)
		end
	end
	self:BroadcastMsg( "#Refresh_Msg" )
end

function CHPGameMode:RefreshHero( hero )
	if hero then
		hero:SetHealth(hero:GetMaxHealth())
		hero:SetMana(hero:GetMaxMana())
		for i = 0, DOTA_MAX_ABILITIES - 1 do
			local hAbility = hero:GetAbilityByIndex( i )
			if hAbility and not hAbility:IsCooldownReady() then
				hAbility:EndCooldown()
			end
		end
		for i = 0, 8 do
			local hItem = hero:GetItemInSlot( i )
			if hItem and not hItem:IsCooldownReady() then
				hItem:EndCooldown()
			end
		end
	end
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnLevelUpButtonPressed
--------------------------------------------------------------------------------
function CHPGameMode:OnLevelUpButtonPressed( eventSourceIndex, data )
	if GameRules:IsCheatMode() then
		SendToServerConsole( "dota_dev hero_level 1" )
	else
		local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
		if hPlayerHero then 
			hPlayerHero:HeroLevelUp(true)
		end
	end
	self:BroadcastMsg( "#LevelUp_Msg" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnMaxLevelButtonPressed
--------------------------------------------------------------------------------
function CHPGameMode:OnMaxLevelButtonPressed( eventSourceIndex, data )
	local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
	hPlayerHero:AddExperience( 32400, false, false ) -- for some reason maxing your level this way fixes the bad interaction with OnHeroReplaced
	--while hPlayerHero:GetLevel() < 25 do
		--hPlayerHero:HeroLevelUp( false )
	--end

	for i = 0, DOTA_MAX_ABILITIES - 1 do
		local hAbility = hPlayerHero:GetAbilityByIndex( i )
		if hAbility and hAbility:CanAbilityBeUpgraded () == ABILITY_CAN_BE_UPGRADED and not hAbility:IsHidden() and not string.find(hAbility:GetName(), "special_bonus") then
			while hAbility:GetLevel() < hAbility:GetMaxLevel() do
				hPlayerHero:UpgradeAbility( hAbility )
			end
		end
	end

	hPlayerHero:SetAbilityPoints( 4 )
	self:BroadcastMsg( "#MaxLevel_Msg" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnFreeSpellsButtonPressed
--------------------------------------------------------------------------------
function CHPGameMode:OnFreeSpellsButtonPressed( eventSourceIndex, data )
	if GameRules:IsCheatMode() then
		SendToServerConsole( "toggle dota_ability_debug" )
		if self.m_bFreeSpellsEnabled == false then
			self.m_bFreeSpellsEnabled = true
			SendToServerConsole( "dota_dev hero_refresh" )
			self:BroadcastMsg( "#FreeSpellsOn_Msg" )
		elseif self.m_bFreeSpellsEnabled == true then
			self.m_bFreeSpellsEnabled = false
			self:BroadcastMsg( "#FreeSpellsOff_Msg" )
		end
	else
		local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
		self:RefreshHero(hPlayerHero)
		local hAllPlayerUnits = {}
		hAllPlayerUnits = hPlayerHero:GetAdditionalOwnedUnits()
		hAllPlayerUnits[ #hAllPlayerUnits + 1 ] = hPlayerHero
		if self.m_bFreeSpellsEnabled == false then
			for _, hUnit in pairs( hAllPlayerUnits ) do
				hUnit:AddNewModifier( hPlayerHero, nil, "lm_free_spells", nil )
			end
			self.m_bFreeSpellsEnabled = true
			self:BroadcastMsg( "#FreeSpellsOn_Msg" )
		elseif self.m_bFreeSpellsEnabled == true then
			for _, hUnit in pairs( hAllPlayerUnits ) do
				hUnit:RemoveModifierByName( "lm_free_spells" )
			end
			self.m_bFreeSpellsEnabled = false
			self:BroadcastMsg( "#FreeSpellsOff_Msg" )
		end
	end
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnInvulnerabilityButtonPressed
--------------------------------------------------------------------------------
function CHPGameMode:OnInvulnerabilityButtonPressed( eventSourceIndex, data )
	local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
	local hAllPlayerUnits = {}
	hAllPlayerUnits = hPlayerHero:GetAdditionalOwnedUnits()
	hAllPlayerUnits[ #hAllPlayerUnits + 1 ] = hPlayerHero

	if self.m_bInvulnerabilityEnabled == false then
		for _, hUnit in pairs( hAllPlayerUnits ) do
			hUnit:AddNewModifier( hPlayerHero, nil, "lm_take_no_damage", nil )
		end
		self.m_bInvulnerabilityEnabled = true
		self:BroadcastMsg( "#InvulnerabilityOn_Msg" )
	elseif self.m_bInvulnerabilityEnabled == true then
		for _, hUnit in pairs( hAllPlayerUnits ) do
			hUnit:RemoveModifierByName( "lm_take_no_damage" )
		end
		self.m_bInvulnerabilityEnabled = false
		self:BroadcastMsg( "#InvulnerabilityOff_Msg" )
	end
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnSpawnAllyButtonPressed -- deprecated
--------------------------------------------------------------------------------
function CHPGameMode:OnSpawnAllyButtonPressed( eventSourceIndex, data )
	local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
	self.m_nAlliesCount = self.m_nAlliesCount + 1
	print( "Ally team count is now: " .. self.m_nAlliesCount )
	self.m_tAlliesList[ self.m_nAlliesCount ] = CreateUnitByName( "npc_dota_hero_axe", hPlayerHero:GetAbsOrigin(), true, nil, nil, self.m_nALLIES_TEAM )
	local hUnit = self.m_tAlliesList[ self.m_nAlliesCount ]
	hUnit:SetControllableByPlayer( self.m_nPlayerID, false )
	hUnit:SetRespawnPosition( hPlayerHero:GetAbsOrigin() )
	FindClearSpaceForUnit( hUnit, hPlayerHero:GetAbsOrigin(), false )
	hUnit:Hold()
	hUnit:SetIdleAcquire( false )
	hUnit:SetAcquisitionRange( 0 )
	self:BroadcastMsg( "#SpawnAlly_Msg" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: SpawnEnemyButtonPressed
--------------------------------------------------------------------------------
function CHPGameMode:OnSpawnEnemyButtonPressed( eventSourceIndex, data )
	if #self.m_tEnemiesList >= 100 then
		print( "#self.m_tEnemiesList == " .. #self.m_tEnemiesList )

		self:BroadcastMsg( "#MaxEnemies_Msg" )
		return
	end

    local hAbility = self._hNeutralCaster:FindAbilityByName( "la_spawn_enemy_at_target" )
	self._hNeutralCaster:CastAbilityImmediately( hAbility, -1 )

	local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
	local hAbilityTestSearch = hPlayerHero:FindAbilityByName( "la_spawn_enemy_at_target" )
	if hAbilityTestSearch then -- Testing whether AddAbility worked successfully on the lua-based ability
		print( "hPlayerHero:AddAbility( \"la_spawn_enemy_at_target\" ) was successful" )
	end

	self:BroadcastMsg( "#SpawnEnemy_Msg" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnLevelUpEnemyButtonPressed
--------------------------------------------------------------------------------
function CHPGameMode:OnLevelUpEnemyButtonPressed( eventSourceIndex )
	for k, v in pairs( self.m_tEnemiesList ) do
		self.m_tEnemiesList[ k ]:HeroLevelUp( false )
	end
	self:BroadcastMsg( "#LevelUpEnemy_Msg" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnDummyTargetsButtonPressed
--------------------------------------------------------------------------------
function CHPGameMode:OnDummyTargetsButtonPressed( eventSourceIndex, data )
	local hPlayerHero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
	self.m_nDummiesCount = self.m_nDummiesCount + 1
	print( "Dummy team count is now: " .. self.m_nDummiesCount )
	self.m_tDummiesList[ self.m_nDummiesCount ] = CreateUnitByName( "npc_dota_hero_target_dummy", hPlayerHero:GetAbsOrigin(), true, nil, nil, self.m_nDUMMIES_TEAM )
	print(self.m_tDummiesList[ self.m_nDummiesCount ])
	local hUnit = self.m_tDummiesList[ self.m_nDummiesCount ]
	hUnit:SetControllableByPlayer( self.m_nPlayerID, false )
	FindClearSpaceForUnit( hUnit, hPlayerHero:GetAbsOrigin(), false )
	hUnit:Hold()
	hUnit:SetIdleAcquire( false )
	hUnit:SetAcquisitionRange( 0 )
	self:BroadcastMsg( "#SpawnDummyTarget_Msg" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnRemoveSpawnedUnitsButtonPressed
--------------------------------------------------------------------------------
function CHPGameMode:OnRemoveSpawnedUnitsButtonPressed( eventSourceIndex )
	print( "Entering CHPGameMode:OnRemoveSpawnedUnitsButtonPressed( eventSourceIndex )" )
	PrintAltTable( self.m_tAlliesList, " " )
	for k, v in pairs( self.m_tAlliesList ) do
		self.m_tAlliesList[ k ]:Destroy()
		self.m_tAlliesList[ k ] = nil
	end
	PrintAltTable( self.m_tEnemiesList, " " )
	for k, v in pairs( self.m_tEnemiesList ) do
		self.m_tEnemiesList[ k ]:Destroy()
		self.m_tEnemiesList[ k ] = nil
	end
	PrintAltTable( self.m_tDummiesList, " " )
	for k, v in pairs( self.m_tDummiesList ) do
		self.m_tDummiesList[ k ]:Destroy()
		self.m_tDummiesList[ k ] = nil
	end

	self.m_nEnemiesCount = 0
	self.m_nDummiesCount = 0

	self:BroadcastMsg( "#RemoveSpawnedUnits_Msg" )
end

--------------------------------------------------------------------------------
-- ButtonEvent: OnLaneCreepsButtonPressed
--------------------------------------------------------------------------------
function CHPGameMode:OnLaneCreepsButtonPressed( eventSourceIndex )
	SendToServerConsole( "toggle dota_creeps_no_spawning" )
	if self.m_bCreepsEnabled == false then
		self.m_bCreepsEnabled = true
		self:BroadcastMsg( "#LaneCreepsOn_Msg" )
	elseif self.m_bCreepsEnabled == true then
		-- if we're disabling creep spawns, then also kill existing creep waves
		SendToServerConsole( "dota_kill_creeps radiant" )
		SendToServerConsole( "dota_kill_creeps dire" )
		self.m_bCreepsEnabled = false
		self:BroadcastMsg( "#LaneCreepsOff_Msg" )
	end
end

--------------------------------------------------------------------------------
-- GameEvent: OnChangeCosmeticsButtonPressed
--------------------------------------------------------------------------------
function CHPGameMode:OnChangeCosmeticsButtonPressed( eventSourceIndex )
	-- currently running the command directly in XML, should run it here if possible
	-- can use GetSelectedHeroID
end

--------------------------------------------------------------------------------
-- GameEvent: OnChangeHeroButtonPressed
--------------------------------------------------------------------------------
function CHPGameMode:OnChangeHeroButtonPressed( eventSourceIndex )
	-- Clean up enemies
	for _,unit in pairs(HeroList:GetAllHeroes()) do
		if PlayerResource:IsFakeClient(unit:GetPlayerOwnerID()) then

		else 
			
		end
	end
	self.m_tEnemiesList = {}
	
	-- GameRules:SetHeroSelectionTime(3)
	-- GameRules:ResetToHeroSelection()
	HeroSelection:Restart()
end

--------------------------------------------------------------------------------
-- GameEvent: OnPauseButtonPressed
--------------------------------------------------------------------------------
function CHPGameMode:OnPauseButtonPressed( eventSourceIndex )
	SendToServerConsole( "dota_pause" )
end

--------------------------------------------------------------------------------
-- GameEvent: OnLeaveButtonPressed
--------------------------------------------------------------------------------
function CHPGameMode:OnLeaveButtonPressed( eventSourceIndex )
	GameRules:SetCustomVictoryMessage( "Thanks for testing!" )
	GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
end