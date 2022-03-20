--[[
Overthrow Game Mode
]]




_G.nNEUTRAL_TEAM = 4
_G.nCOUNTDOWNTIMER = 901


---------------------------------------------------------------------------
-- COverthrowGameMode class
---------------------------------------------------------------------------
if COverthrowGameMode == nil then
	_G.COverthrowGameMode = class({}) -- put COverthrowGameMode in the global scope
	--refer to: http://stackoverflow.com/questions/6586145/lua-require-with-global-local

end

---------------------------------------------------------------------------
-- Required .lua files
---------------------------------------------------------------------------
require( "events" )
require( "items" )
require( "utility_functions" )
require("lib.keyvalues")
require("lib.timers")
require('libraries/cosmetic/CosmeticLib')
require('lib/util_dusk')
require('internal/util')
require('abilities/life_in_arena/utils')
require('lib/talents')

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
require('libraries/projectiles02')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
require('libraries/attachments')
-- This library can be used to synchronize client-server data via player/client-specific nettables
require('libraries/playertables')
-- This library can be used to create container inventories or container shops
require('libraries/containers')
-- This library provides a searchable, automatically updating lua API in the tools-mode via "modmaker_api" console command
require('libraries/modmaker')
-- This library provides an automatic graph construction of path_corner entities within the map
require('libraries/pathgraph')
require('vector_target')
-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')

require("lib.responses")


require("internal/funcs")
require("internal/util")
require("internal/extend")
require("constants")
local Constants = require('consts') -- XP TABLE

require("api")
---------------------------------------------------------------------------
-- Precache
---------------------------------------------------------------------------
function Precache( context )
	--Cache the gold bags
		PrecacheItemByNameSync( "item_bag_of_gold", context )
		PrecacheResource( "particle", "particles/items2_fx/veil_of_discord.vpcf", context )	

		PrecacheItemByNameSync( "item_treasure_chest", context )
		PrecacheModel( "item_treasure_chest", context )

	--Cache the creature models
		PrecacheUnitByNameSync( "npc_dota_creature_basic_zombie", context )
        PrecacheModel( "npc_dota_creature_basic_zombie", context )

        PrecacheUnitByNameSync( "npc_dota_creature_berserk_zombie", context )
        PrecacheModel( "npc_dota_creature_berserk_zombie", context )

        PrecacheUnitByNameSync( "npc_dota_treasure_courier", context )
        PrecacheModel( "npc_dota_treasure_courier", context )
        PrecacheModel( "models/units/doppelganger/doppelganger.vmdl", context )

    --Cache new particles
       	PrecacheResource( "particle", "particles/econ/events/nexon_hero_compendium_2014/teleport_end_nexon_hero_cp_2014.vpcf", context )
       	PrecacheResource( "particle", "particles/leader/leader_overhead.vpcf", context )
       	PrecacheResource( "particle", "particles/last_hit/last_hit.vpcf", context )
       	PrecacheResource( "particle", "particles/units/heroes/hero_zuus/zeus_taunt_coin.vpcf", context )
       	PrecacheResource( "particle", "particles/addons_gameplay/player_deferred_light.vpcf", context )
       	PrecacheResource( "particle", "particles/items_fx/black_king_bar_avatar.vpcf", context )
       	PrecacheResource( "particle", "particles/treasure_courier_death.vpcf", context )
       	PrecacheResource( "particle", "particles/econ/wards/f2p/f2p_ward/f2p_ward_true_sight_ambient.vpcf", context )
       	PrecacheResource( "particle", "particles/econ/items/lone_druid/lone_druid_cauldron/lone_druid_bear_entangle_dust_cauldron.vpcf", context )
       	PrecacheResource( "particle", "particles/newplayer_fx/npx_landslide_debris.vpcf", context )
       	
	--Cache particles for traps
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_dragon_knight", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_venomancer", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_axe", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_life_stealer", context )

	--Cache sounds for traps
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dragon_knight.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/soundevents_conquest.vsndevts", context )


	-- La'thaal precache
	PrecacheUnitByNameSync("npc_dota_hero_lathaal",context)
	PrecacheModel("models/heroes/lathaal/lathaal.vmdl", context)
	PrecacheModel("models/heroes/lina/lina.vmdl", context)
	PrecacheModel("models/items/meepo/the_family_values_weapon/the_family_values_weapon.vmdl", context )

	-- Viscous Ooze precache
	PrecacheUnitByNameSync("npc_dota_hero_viscous_ooze",context)
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_viscous_ooze.vsndevts", context )
	PrecacheModel("models/heroes/viscous_ooze/viscous_ooze_animation.vmdl", context)
	PrecacheModel("models/heroes/viscous_ooze/oozeling.vmdl", context)

	-- Jeremy Khan precache
	PrecacheUnitByNameSync("npc_dota_hero_axe",context)
	PrecacheModel("models/items/axe/axe_practos_weapon/axe_practos_weapon.vmdl", context)
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_axe.vsndevts", context )

	-- Warp Beast precache
	PrecacheUnitByNameSync("npc_dota_hero_warp_beast",context)
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_warp_beast.vsndevts", context )

	-- Mifune precache
	PrecacheUnitByNameSync("npc_dota_hero_mifune",context)
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_juggernaut.vsndevts", context )
	PrecacheModel("models/items/juggernaut/dragon_sword.vmdl", context)
	PrecacheModel("models/items/juggernaut/armour_of_the_exiled_ronin/armour_of_the_exiled_ronin.vmdl", context)


	-- Items precache
	PrecacheResource( "soundfile", "soundevents/game_sounds_test.vsndevts", context )
	PrecacheResource( "particle", "particles/items_fx/nokrahs_blade.vpcf", context )
	PrecacheUnitByNameSync("npc_dota_hero_troy",context)
	PrecacheModel("models/items/axe/axe_practos_weapon/axe_practos_weapon.vmdl", context)
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_jeremy.vsndevts", context )

	-- Warp Beast precache
	PrecacheUnitByNameSync("npc_dota_hero_warp_beast",context)
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_warp_beast.vsndevts", context )
	-- Axe precache (for demo mode)
	PrecacheUnitByNameSync("npc_dota_hero_troy",context)
	    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_abaddon.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_abyssal_underlord.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_alchemist.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_ancient_apparition.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_antimage.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_arc_warden.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_axe.vsndevts", context)
    PrecacheResource("soundfile","soundevents/novasoundevent.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_bane.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_batrider.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_beastmaster.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_bloodseeker.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_bounty_hunter.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_brewmaster.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_bristleback.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_broodmother.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_centaur.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_chaos_knight.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_chen.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_clinkz.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_crystal_maiden.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_dark_seer.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_dark_willow.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_dazzle.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_death_prophet.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_disruptor.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_doom_bringer.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_dragon_knight.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_drow_ranger.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_earth_spirit.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_earthshaker.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_elder_titan.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_ember_spirit.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_enchantress.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_enigma.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_faceless_void.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_furion.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_grimstroke.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_gyrocopter.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_hoodwink.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_huskar.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_invoker.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_jakiro.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_juggernaut.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_keeper_of_the_light.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_kunkka.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_legion_commander.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_leshrac.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_lich.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_life_stealer.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_lina.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_lion.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_lone_druid.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_luna.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_lycan.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_magnataur.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_mars.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_medusa.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_meepo.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_mirana.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_monkey_king.vsndevts", context)    
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_morphling.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_naga_siren.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_necrolyte.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_nevermore.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_night_stalker.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_nyx_assassin.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_obsidian_destroyer.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_ogre_magi.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_omniknight.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_oracle.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_pangolier.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_phantom_assassin.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_phantom_lancer.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_puck.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_pudge.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_pugna.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_queenofpain.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_rattletrap.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_razor.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_riki.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_rubick.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_sand_king.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_shadow_demon.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_shadow_shaman.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_shredder.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_silencer.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_skeleton_king.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_skywrath_mage.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_slardar.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_slark.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_snapfire.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_sniper.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_spectre.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_spirit_breaker.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_storm_spirit.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_sven.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_techies.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_templar_assassin.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_terrorblade.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_tidehunter.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_tinker.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_tiny.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_treant.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_troll_warlord.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_tusk.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_undying.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_ursa.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_vengefulspirit.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_venomancer.vsndevts", context) 
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_viper.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_visage.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_void_spirit.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_warlock.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_weaver.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_windrunner.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_winter_wyvern.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_wisp.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_witch_doctor.vsndevts", context)
    PrecacheResource("soundfile","soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context)
end

function Activate()
	-- Create our game mode and initialize it
	COverthrowGameMode:InitGameMode()
	-- Custom Spawn
	COverthrowGameMode:CustomSpawnCamps()
end

function COverthrowGameMode:CustomSpawnCamps()
	for name,_ in pairs(spawncamps) do
	spawnunits(name)
	end
end

---------------------------------------------------------------------------
-- Initializer
---------------------------------------------------------------------------
function COverthrowGameMode:InitGameMode()
	print( "Overthrow is loaded." )
	
--	CustomNetTables:SetTableValue( "test", "value 1", {} );
--	CustomNetTables:SetTableValue( "test", "value 2", { a = 1, b = 2 } );


	self.m_VictoryMessages = {}
	self.m_VictoryMessages[DOTA_TEAM_GOODGUYS] = "#VictoryMessage_GoodGuys"
	self.m_VictoryMessages[DOTA_TEAM_BADGUYS]  = "#VictoryMessage_BadGuys"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_1] = "#VictoryMessage_Custom1"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_2] = "#VictoryMessage_Custom2"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_3] = "#VictoryMessage_Custom3"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_4] = "#VictoryMessage_Custom4"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_5] = "#VictoryMessage_Custom5"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_6] = "#VictoryMessage_Custom6"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_7] = "#VictoryMessage_Custom7"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_8] = "#VictoryMessage_Custom8"
	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled( true )
	self.m_GatheredShuffledTeams = {}
	self.numSpawnCamps = 8
	self.specialItem = ""
	self.spawnTime = 90
	self.nNextSpawnItemNumber = 1
	self.hasWarnedSpawn = false
	self.allSpawned = false
	self.leadingTeam = -1
	self.runnerupTeam = -1
	self.leadingTeamScore = 0
	self.runnerupTeamScore = 0
	self.isGameTied = true
	self.countdownEnabled = false
	self.itemSpawnIndex = 1
	self.itemSpawnLocation = Entities:FindByName( nil, "greevil" )
	self.tier1ItemBucket = {}
	self.tier2ItemBucket = {}
	self.tier3ItemBucket = {}
	self.tier4ItemBucket = {}

	self.TEAM_KILLS_TO_WIN = 25
	self.CLOSE_TO_VICTORY_THRESHOLD = 5

	---------------------------------------------------------------------------

	self:GatherAndRegisterValidTeams()

	GameRules:GetGameModeEntity().COverthrowGameMode = self

	-- Adding Many Players
	if GetMapName() == "desert_duo" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 5 )
		self.m_GoldRadiusMin = 300
		self.m_GoldRadiusMax = 1400
		self.m_GoldDropPercent = 0
	elseif GetMapName() == "dota" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 5 )
		self.m_GoldRadiusMin = 300
		self.m_GoldRadiusMax = 1400
		self.m_GoldDropPercent = 0
	else

		self.m_GoldRadiusMin = 250
		self.m_GoldRadiusMax = 550
		self.m_GoldDropPercent = 0
	end

	-- Show the ending scoreboard immediately
	GameRules:SetCustomGameEndDelay( 0 )
	GameRules:SetCustomVictoryMessageDuration( 10 )
	GameRules:SetPreGameTime( 60 )
	GameRules:SetStrategyTime( 15.0 )
	GameRules:SetShowcaseTime( 0.0 )
	--GameRules:SetHideKillMessageHeaders( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:SetHideKillMessageHeaders( true )
	GameRules:SetUseUniversalShopMode( true )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_DOUBLEDAMAGE , true ) --Double Damage
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_HASTE, true ) --Haste
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_ILLUSION, true ) --Illusion
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_INVISIBILITY, true ) --Invis
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_REGENERATION, true ) --Regen
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_ARCANE, true ) --Arcane
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_BOUNTY, true ) --Bounty
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath( false )
	GameRules:GetGameModeEntity():SetFountainPercentageHealthRegen( 0 )
	GameRules:GetGameModeEntity():SetFountainPercentageManaRegen( 0 )
	GameRules:GetGameModeEntity():SetFountainConstantManaRegen( 0 )
	GameRules:GetGameModeEntity():SetBountyRunePickupFilter( Dynamic_Wrap( COverthrowGameMode, "BountyRunePickupFilter" ), self )
	GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( COverthrowGameMode, "ExecuteOrderFilter" ), self )
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(Constants.XP_PER_LEVEL_TABLE)



	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( COverthrowGameMode, 'OnGameRulesStateChange' ), self )
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( COverthrowGameMode, "OnNPCSpawned" ), self )

	ListenToGameEvent( "dota_team_kill_credit", Dynamic_Wrap( COverthrowGameMode, 'OnTeamKillCredit' ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( COverthrowGameMode, 'OnEntityKilled' ), self )
	ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap( COverthrowGameMode, "OnItemPickUp"), self )
	ListenToGameEvent( "dota_npc_goal_reached", Dynamic_Wrap( COverthrowGameMode, "OnNpcGoalReached" ), self )

	Convars:RegisterCommand( "overthrow_force_item_drop", function(...) self:ForceSpawnItem() end, "Force an item drop.", FCVAR_CHEAT )
	Convars:RegisterCommand( "overthrow_force_gold_drop", function(...) self:ForceSpawnGold() end, "Force gold drop.", FCVAR_CHEAT )
	Convars:RegisterCommand( "overthrow_set_timer", function(...) return SetTimer( ... ) end, "Set the timer.", FCVAR_CHEAT )
	Convars:RegisterCommand( "overthrow_force_end_game", function(...) return self:EndGame( DOTA_TEAM_GOODGUYS ) end, "Force the game to end.", FCVAR_CHEAT )
	Convars:SetInt( "dota_server_side_animation_heroesonly", 0 )

	COverthrowGameMode:SetUpFountains()
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 1 ) 

	-- Spawning monsters
	spawncamps = {}
	for i = 1, self.numSpawnCamps do
		local campname = "camp"..i.."_path_customspawn"
		spawncamps[campname] =
		{
			NumberToSpawn = RandomInt(2,6),
			WaypointName = "camp"..i.."_path_wp1"
		}
	end
end

---------------------------------------------------------------------------
-- Set up fountain regen
---------------------------------------------------------------------------
function COverthrowGameMode:SetUpFountains()

	LinkLuaModifier( "modifier_fountain_aura_lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_fountain_aura_effect_lua", LUA_MODIFIER_MOTION_NONE )

	local fountainEntities = Entities:FindAllByClassname( "ent_dota_fountain")
	for _,fountainEnt in pairs( fountainEntities ) do
		--print("fountain unit " .. tostring( fountainEnt ) )
		fountainEnt:AddNewModifier( fountainEnt, fountainEnt, "modifier_fountain_aura_lua", {} )
	end
end


---------------------------------------------------------------------------
---------------------------------------------------------------------------
function COverthrowGameMode:EndGame( victoryTeam )
	local overBoss = Entities:FindByName( nil, "@overboss" )
	if overBoss then
		local celebrate = overBoss:FindAbilityByName( 'dota_ability_celebrate' )
		if celebrate then
			overBoss:CastAbilityNoTarget( celebrate, -1 )
		end
	end

	GameRules:SetGameWinner( victoryTeam )
end


--------------------------------------------------------------------------
---------------------------------------------------------------------------
-- Simple scoreboard using debug text
---------------------------------------------------------------------------
function COverthrowGameMode:UpdateScoreboard()
	local sortedTeams = {}
	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		table.insert( sortedTeams, { teamID = team, teamScore = GetTeamHeroKills( team ) } )
	end

	-- reverse-sort by score
	table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )

	for _, t in pairs( sortedTeams ) do

		-- Scaleform UI Scoreboard
		local score = 
		{
			team_id = t.teamID,
			team_score = t.teamScore
		}
		FireGameEvent( "score_board", score )
	end
	-- Leader effects (moved from OnTeamKillCredit)
	local leader = sortedTeams[1].teamID
	--print("Leader = " .. leader)
	self.leadingTeam = leader
	self.runnerupTeam = sortedTeams[2].teamID
	self.leadingTeamScore = sortedTeams[1].teamScore
	self.runnerupTeamScore = sortedTeams[2].teamScore
	if sortedTeams[1].teamScore == sortedTeams[2].teamScore then
		self.isGameTied = true
	else
		self.isGameTied = false
	end
	local allHeroes = HeroList:GetAllHeroes()
	for _,entity in pairs( allHeroes) do
		if entity:GetTeamNumber() == leader and sortedTeams[1].teamScore ~= sortedTeams[2].teamScore then
			if entity:IsAlive() == true then
				-- Attaching a particle to the leading team heroes
				local existingParticle = entity:Attribute_GetIntValue( "particleID", -1 )
       			if existingParticle == -1 then
       				local particleLeader = ParticleManager:CreateParticle( "particles/leader/leader_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, entity )
					ParticleManager:SetParticleControlEnt( particleLeader, PATTACH_OVERHEAD_FOLLOW, entity, PATTACH_OVERHEAD_FOLLOW, "follow_overhead", entity:GetAbsOrigin(), true )
					entity:Attribute_SetIntValue( "particleID", particleLeader )
				end
			else
				local particleLeader = entity:Attribute_GetIntValue( "particleID", -1 )
				if particleLeader ~= -1 then
					ParticleManager:DestroyParticle( particleLeader, true )
					entity:DeleteAttribute( "particleID" )
				end
			end
		else
			local particleLeader = entity:Attribute_GetIntValue( "particleID", -1 )
			if particleLeader ~= -1 then
				ParticleManager:DestroyParticle( particleLeader, true )
				entity:DeleteAttribute( "particleID" )
			end
		end
	end
end

---------------------------------------------------------------------------
-- Update player labels and the scoreboard
---------------------------------------------------------------------------
function COverthrowGameMode:OnThink()

	
	self:UpdateScoreboard()
	-- Stop thinking if game is paused
	if GameRules:IsGamePaused() == true then
        return 1
    end

	if self.countdownEnabled == true then
		CountdownTimer()
		if nCOUNTDOWNTIMER == 30 then
			CustomGameEventManager:Send_ServerToAllClients( "timer_alert", {} )
		end
		if nCOUNTDOWNTIMER <= 0 then
			--Check to see if there's a tie
			if self.isGameTied == false then
				GameRules:SetCustomVictoryMessage( self.m_VictoryMessages[self.leadingTeam] )
				COverthrowGameMode:EndGame( self.leadingTeam )
				self.countdownEnabled = false
			else
				self.TEAM_KILLS_TO_WIN = self.leadingTeamScore + 1
				local broadcast_killcount = 
				{
					killcount = self.TEAM_KILLS_TO_WIN
				}
				CustomGameEventManager:Send_ServerToAllClients( "overtime_alert", broadcast_killcount )
			end
       	end
	end
	
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--Spawn Gold Bags
		COverthrowGameMode:ThinkGoldDrop()
		COverthrowGameMode:ThinkSpecialItemDrop()
	end

	return 1
end

---------------------------------------------------------------------------
-- Scan the map to see which teams have spawn points
---------------------------------------------------------------------------
function COverthrowGameMode:GatherAndRegisterValidTeams()
--	print( "GatherValidTeams:" )

	local foundTeams = {}
	for _, playerStart in pairs( Entities:FindAllByClassname( "info_player_start_dota" ) ) do
		foundTeams[  playerStart:GetTeam() ] = true
	end

	local numTeams = TableCount(foundTeams)
	print( "GatherValidTeams - Found spawns for a total of " .. numTeams .. " teams" )
	
	local foundTeamsList = {}
	for t, _ in pairs( foundTeams ) do
		table.insert( foundTeamsList, t )
	end

	if numTeams == 0 then
		print( "GatherValidTeams - NO team spawns detected, defaulting to GOOD/BAD" )
		table.insert( foundTeamsList, DOTA_TEAM_GOODGUYS )
		table.insert( foundTeamsList, DOTA_TEAM_BADGUYS )
		numTeams = 2
	end

	local maxPlayersPerValidTeam = math.floor( 10 / numTeams )

	self.m_GatheredShuffledTeams = ShuffledList( foundTeamsList )

	print( "Final shuffled team list:" )
	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		print( " - " .. team .. " ( " .. GetTeamName( team ) .. " )" )
	end

	print( "Setting up teams:" )
	for team = 0, (DOTA_TEAM_COUNT-1) do
		local maxPlayers = 0
		if ( nil ~= TableFindKey( foundTeamsList, team ) ) then
			maxPlayers = maxPlayersPerValidTeam
		end
		print( " - " .. team .. " ( " .. GetTeamName( team ) .. " ) -> max players = " .. tostring(maxPlayers) )
		GameRules:SetCustomGameTeamMaxPlayers( team, maxPlayers )
	end
end

-- Spawning individual camps
function COverthrowGameMode:spawncamp(campname)
	spawnunits(campname)
end

-- Simple Custom Spawn
function spawnunits(campname)
	local spawndata = spawncamps[campname]
	local NumberToSpawn = spawndata.NumberToSpawn --How many to spawn
    local SpawnLocation = Entities:FindByName( nil, campname )
    local waypointlocation = Entities:FindByName ( nil, spawndata.WaypointName )
	if SpawnLocation == nil then
		return
	end

    local randomCreature = 
    	{
			"basic_zombie",
			"berserk_zombie",
			"jungle_stalker",
			"elder_jungle_stalker",
			"prowler_acolyte",
			"prowler_shaman"
	    }
	local r = randomCreature[RandomInt(1,#randomCreature)]
	--print(r)
    for i = 1, NumberToSpawn do
        local creature = CreateUnitByName( "npc_dota_creature_" ..r , SpawnLocation:GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_NEUTRALS )
        --print ("Spawning Camps")
        creature:SetInitialGoalEntity( waypointlocation )
    end
end

--------------------------------------------------------------------------------
-- Event: Filter for inventory full
--------------------------------------------------------------------------------
function COverthrowGameMode:ExecuteOrderFilter( filterTable )
	--[[
	for k, v in pairs( filterTable ) do
		print("EO: " .. k .. " " .. tostring(v) )
	end
	]]

	local orderType = filterTable["order_type"]
	if ( orderType ~= DOTA_UNIT_ORDER_PICKUP_ITEM or filterTable["issuer_player_id_const"] == -1 ) then
		return true
	else
		local item = EntIndexToHScript( filterTable["entindex_target"] )
		if item == nil then
			return true
		end
		local pickedItem = item:GetContainedItem()
		--print(pickedItem:GetAbilityName())
		if pickedItem == nil then
			return true
		end
		if pickedItem:GetAbilityName() == "item_treasure_chest" then
			local player = PlayerResource:GetPlayer(filterTable["issuer_player_id_const"])
			local hero = player:GetAssignedHero()
			if hero:GetNumItemsInInventory() < 9 then
				--print("inventory has space")
				return true
			else
				--print("Moving to target instead")
				local position = item:GetAbsOrigin()
				filterTable["position_x"] = position.x
				filterTable["position_y"] = position.y
				filterTable["position_z"] = position.z
				filterTable["order_type"] = DOTA_UNIT_ORDER_MOVE_TO_POSITION
				return true
			end
		end
	end
	return true
end




 function COverthrowGameMode:OnNPCSpawned(data)
    local npc = EntIndexToHScript(data.entindex)
    if npc.bFirstSpawned == nil then ---если юнит герой и это первый его спавн находишь у него скилл и апаешь скиллу 1 уровень
       npc.bFirstSpawned = true
        if npc and npc:IsRealHero() and npc.initialize_talents == nil then
            if npc:GetUnitName() == "npc_dota_hero_bloodseeker" then
                TalentsManager:CreateChooseTalent( npc )
            end
        end
    end
    if npc:IsRealHero() then
    local playerID = npc:GetPlayerID()
    local steamID = PlayerResource:GetSteamAccountID(playerID)   
    if IsServer() then

    if npc:HasAbility("become_yellow_king") then
       local ab = npc:FindAbilityByName("become_yellow_king")
       ab:SetLevel(1)
    end

    if npc:HasAbility("medusa_mana_shield_datadriven") then
       local ab = npc:FindAbilityByName("medusa_mana_shield_datadriven")
       ab:SetLevel(1)
       CosmeticLib:ReplaceDefault( npc, npc:GetUnitName() )
    end

    if npc:HasAbility("invoke_datadriven") then
       local ab = npc:FindAbilityByName("invoke_datadriven")
       ab:SetLevel(1)
    end

    if npc:HasAbility("antimage_blink") then
       CosmeticLib:ReplaceWithSlotName( npc, "persona_selector", 13783 )
    end

    if npc:HasAbility("sige_splash") then 
       local ab = npc:FindAbilityByName("sige_splash")
       ab:SetLevel(1)
    end
    if npc:HasAbility("become_jugger") then 
     local ab = npc:FindAbilityByName("become_jugger")
     ab:SetLevel(1)
    end
    
    if npc:HasAbility("become_nova") and npc:IsRealHero() then
        local ab = npc:FindAbilityByName("become_nova")
        ab:SetLevel(1)
        local playerID = npc:GetPlayerID()
        local steamID = PlayerResource:GetSteamAccountID(playerID)
        if steamID == 150752768 then 
           CosmeticLib:EquipHeroSet( npc, 20899 )
        elseif steamID == 1248050574 then 
           CosmeticLib:EquipHeroSet( npc, 20130 )
        else
           CosmeticLib:EquipHeroSet( npc, 20321 )
        end
    end
    if npc:HasAbility("erra_to_dust") then 
        CosmeticLib:ReplaceDefault( npc, npc:GetUnitName())
    end

    if npc:HasAbility("azura_multishot_crossbow") then 
        CosmeticLib:ReplaceWithSlotName( npc, "weapon", 7238 )
    end

    if npc:HasAbility("veerah_killer_instinct") then
        CosmeticLib:EquipHeroSet( npc, 20479 )
    end
    end
end
end
