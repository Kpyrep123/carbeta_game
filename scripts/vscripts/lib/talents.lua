if TalentsManager == nil then
    _G.TalentsManager = class({})
end

-- Таблица делится на название героя в коде
-- Внутри героя делится на максимум 3-5 таланта и каждый талант делится на 1) название, 2) иконка в panorama/images/custom_game/talents_icon/, 3) 6 способностей которые будут у героя "generic_hidden" - пустая, 4) таланты героя распредление ниже 5) Новый атрибут


-- 8) ЛЕВЫЙ 25 7) ПРАВЫЙ
-- 6) ЛЕВЫЙ 20 5) ПРАВЫЙ
-- 4) ЛЕВЫЙ 15 3) ПРАВЫЙ
-- 2) ЛЕВЫЙ 10 1) ПРАВЫЙ


ALL_HERO_TALENTS = {
["npc_dota_hero_bloodseeker"] = 
{{"seeker_style_1", 
"pudge_style_1", 
{"blood_rite_datadriven", 
"pudge_meat_hook_lua", 
"huskar_berserkers_blood_lod", 
"ability_hero_attributes_cursed", 
"huskar_berserkers_blood_lod_passive", 
"bellatrix_live_transfusion"}, 
{"special_bonus_mp_400", 
"special_bonus_cursed_1", 
"special_bonus_cursed_2", 
"special_bonus_mp_regen_250", 
"special_bonus_hp_regen_16", 
"special_bonus_corruption_25", 
"special_bonus_hp_600", 
"special_bonus_cursed_3",}, 
"DOTA_ATTRIBUTE_AGILITY", 
{20,21,22}},
{"seeker_style_2", 
"pudge_style_2", 
{"ability_spike_tearing_blow", 
"spike_heal", 
"angel_arena_shell", 
"ability_hero_attributes_spike", 
"generic_hidden", 
"spike_conclusion_lua"}, 
{"special_bonus_strength_6", 
"special_bonus_attack_damage_20", 
"special_bonus_unquie_spike_heal_dur", 
"special_bonus_unquie_blow_dur", 
"special_bonus_unquie_coold_red", 
"special_bonus_unquie_blow_dmg", 
"spike_special_bonus_shell_25", 
"spike_special_bonus_attack"}, 
"DOTA_ATTRIBUTE_STRENGTH", 
{20,29,7}},

{"Blood_seeker_default", -- Название стиля
"BS_default", -- Экран
{"imba_bloodseeker_bloodrage", -- 1 скилл
"imba_bloodseeker_blood_bath", -- 2 скилл
"ability_bloodseeker_thirst", -- 3 скилл
"hero_attributes_bs", -- 4 скилл
"imba_bloodseeker_rupture_scepter", -- 5 скилл
"imba_bloodseeker_rupture"}, -- 6 скилл
{"special_bonus_unique_bloodseeker_4", -- Правый 10 лвл
"special_bonus_imba_bloodseeker_2", -- Левый 10 лвл
"special_bonus_imba_bloodseeker_4", -- Правый 15 лвл
"special_bonus_imba_bloodseeker_7", -- Левый 15 лвл
"special_bonus_imba_bloodseeker_rupture_cast_range", -- Правый 20 лвл
"special_bonus_imba_bloodseeker_3", -- Левый 20 лвл
"special_bonus_imba_bloodseeker_9", -- Правый 25 лвл
"special_bonus_imba_bloodseeker_5",}, -- Левый 25 лвл
"DOTA_ATTRIBUTE_AGILITY", -- Основной атрибут
{24,22,17}},},-- Начальные статы

["npc_dota_hero_drow_ranger"] = 
{{"azura_style_1", "azura", {"wave_of_silence_datadriven", "azura_gaze_of_exile", "azura_multishot_crossbow", "hoodwink_sharpshooter_release_custom", "ability_hero_attributes_azura", "hoodwink_sharpshooter_custom"}, 
{"special_bonus_unquie_gaze_damage", "special_bonus_attack_damage_25", 
"special_bonus_unquie_azura_creep_damage", "special_bonus_unquie_gaze_radius", --герой
"special_bonus_unique_azura_2", "special_bonus_unquie_sharo_max", 
"hoodwink_sharp_2", "special_bonus_Sharp_1"}, "DOTA_ATTRIBUTE_AGILITY", {22,20,15}},
{"azura_style_2", "drow_ranger", {"imba_drow_ranger_frost_arrows_723", "imba_drow_ranger_gust", "imba_drow_ranger_multishot", "imba_drow_ranger_deadeye", "ability_hero_attributes_drow_ranger", "imba_drow_ranger_marksmanship_723"}, 
{"special_bonus_imba_drow_ranger_2", "special_bonus_imba_drow_ranger_frost_arrows_damage", 
"special_bonus_imba_drow_ranger_4", "special_bonus_imba_drow_ranger_7", 
"special_bonus_imba_drow_ranger_1", "special_bonus_imba_drow_ranger_9", 
"special_bonus_imba_drow_ranger_5", "special_bonus_imba_drow_ranger_3"}, "DOTA_ATTRIBUTE_AGILITY", {22,20,15}},},

["npc_dota_hero_terrorblade"] = 
{{"Reaver_Lord", 
"Reaver_lord", 
{"reaver_lord_soul_devour_lua", 
"reaver_lord_twink", 
"reaver_lord_superiority_instinct_lua", 
"reaver_lord_soul_collector_lua", 
"reaver_lord_soul_burn", 
"reaver_lord_attract_lua",
"hero_attributes_rl"}, 
{"special_bonus_unquie_devour_range", 
"special_bonus_hp_250", 
"special_bonus_unquie_instinct_damage", 
"special_bonus_unquie_devour_duration", 
"special_bonus_unquie_instinct_lifesteal", 
"special_bonus_unquie_attrackt_rad", 
"special_bonus_unquie_max_souls_soul_collector", 
"reaver_lord_special_bonus_blink_range",}, 
"DOTA_ATTRIBUTE_AGILITY", 
{18,24,13}},

{"Terrorblade", 
"Terrorblade", 
{"imba_terrorblade_reflection", 
"imba_terrorblade_conjure_image", 
"imba_terrorblade_metamorphosis", 
"imba_terrorblade_terror_wave", 
"imba_terrorblade_power_rend", 
"imba_terrorblade_sunder",
"hero_attributes_tb"}, 
{"special_bonus_unquie_counter_image_duration", 
"special_bonus_mp_regen_250", 
"special_bonus_unquie_conjure_nomana", 
"special_bonus_unquie_reflection_slow", 
"special_bonus_unquie_conjure_double", 
"special_bonus_imba_terrorblade_reflection_cooldown", 
"special_bonus_imba_terrorblade_sunder_cooldown", 
"special_bonus_imba_terrorblade_metamorphosis_attack_range"}, 
"DOTA_ATTRIBUTE_AGILITY", 
{16,22,19}},},

-- ["npc_dota_hero_sniper"] = --герой

-- {{"sniper_default", -- Название стиля
-- "", -- Экран
-- {"", -- 1 скилл
-- "", -- 2 скилл
-- "", -- 3 скилл
-- "", -- 4 скилл
-- "", -- 5 скилл
-- ""}, -- 6 скилл
-- {"", -- Правый 10 лвл
-- "", -- Левый 10 лвл
-- "", -- Правый 15 лвл
-- "", -- Левый 15 лвл
-- "", -- Правый 20 лвл
-- "", -- Левый 20 лвл
-- "", -- Правый 25 лвл
-- "",}, -- Левый 25 лвл
-- "", -- Основной атрибут
-- {,,}},

-- {{"nova_swift", -- Название стиля
-- "", -- Экран
-- {"", -- 1 скилл
-- "", -- 2 скилл
-- "", -- 3 скилл
-- "", -- 4 скилл
-- "", -- 5 скилл
-- ""}, -- 6 скилл
-- {"", -- Правый 10 лвл
-- "", -- Левый 10 лвл
-- "", -- Правый 15 лвл
-- "", -- Левый 15 лвл
-- "", -- Правый 20 лвл
-- "", -- Левый 20 лвл
-- "", -- Правый 25 лвл
-- "",}, -- Левый 25 лвл
-- "", -- Основной атрибут
-- {,,}},
-- 
-- {{"nova_techies", -- Название стиля
-- "", -- Экран
-- {"", -- 1 скилл
-- "", -- 2 скилл
-- "", -- 3 скилл
-- "", -- 4 скилл
-- "", -- 5 скилл
-- ""}, -- 6 скилл
-- {"", -- Правый 10 лвл
-- "", -- Левый 10 лвл
-- "", -- Правый 15 лвл
-- "", -- Левый 15 лвл
-- "", -- Правый 20 лвл
-- "", -- Левый 20 лвл
-- "", -- Правый 25 лвл
-- "",}, -- Левый 25 лвл
-- "", -- Основной атрибут
-- {,,}},},
}-- Начальные статы


HEROES_TALENT_INFORMATION = {}
HEROES_HIDDEN_ABILITIES = {}


function TalentsManager:InitTalentsSystem()
	-- ListenToGameEvent("npc_spawned", Dynamic_Wrap(self,"OnEntitySpawned"), self)
	CustomGameEventManager:RegisterListener( "event_activate_talent", Dynamic_Wrap(TalentsManager,'SelectTalent'))
	TalentsManager:ParseTalentsInfor()
end

function TalentsManager:CreateChooseTalent( hero )
    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(hero:GetPlayerID()), "event_choose_talent", {talents = ALL_HERO_TALENTS[hero:GetUnitName()], talents_values = HEROES_TALENT_INFORMATION[hero:GetUnitName()], hidden_abilities = HEROES_HIDDEN_ABILITIES[hero:GetUnitName()]} )
end

function TalentsManager:SelectTalent(kv)
    local hero = PlayerResource:GetSelectedHeroEntity(kv.PlayerID)

    if hero == nil then return end

    local abilities = ALL_HERO_TALENTS[hero:GetUnitName()][kv.number][3]
    local attribute = ALL_HERO_TALENTS[hero:GetUnitName()][kv.number][5]
    local talents = ALL_HERO_TALENTS[hero:GetUnitName()][kv.number][4]

    -- Замена абилок на новые

    for i=0,9 do
        local ability = hero:GetAbilityByIndex(i)
        if ability then
            hero:RemoveAbility(ability:GetAbilityName())
        end
    end

    for _, new_ability in pairs(abilities) do
        hero:AddAbility(new_ability)
    end


    -- Удаление старых и добавление новых талантов

    for i=0,24 do
        local ability = hero:GetAbilityByIndex(i)
        if ability then
            if string.find(ability:GetAbilityName(), "special_bonus_") and ability:GetAbilityName() ~= "special_bonus_attributes" then
                print("Удален талант: ", ability:GetAbilityName())
                hero:RemoveAbility(ability:GetAbilityName())
            end
        end
    end

    for _, new_talent in pairs(talents) do
        hero:AddAbility(new_talent)
    end

    for i=0,24 do
        local ability = hero:GetAbilityByIndex(i)
        if ability then
            if string.find(ability:GetAbilityName(), "special_bonus_") then
                print("Новый талант", ability:GetAbilityName())
            end
        end
    end
    hero:AddAbility("special_bonus_attributes")
    -- Замена Уникального атрибута

    if attribute == "DOTA_ATTRIBUTE_STRENGTH" then
        hero:SetPrimaryAttribute(0)
    elseif attribute == "DOTA_ATTRIBUTE_AGILITY" then
        hero:SetPrimaryAttribute(1)
    elseif attribute == "DOTA_ATTRIBUTE_INTELLECT" then
        hero:SetPrimaryAttribute(2)
    end

    for i=0,40 do
       local ability = hero:GetAbilityByIndex(i)
        if ability then
            print(i, ability:GetAbilityName())    
        end
    end

    hero:SetBaseStrength(ALL_HERO_TALENTS[hero:GetUnitName()][kv.number][6][1])
    hero:SetBaseAgility(ALL_HERO_TALENTS[hero:GetUnitName()][kv.number][6][2])
    hero:SetBaseIntellect(ALL_HERO_TALENTS[hero:GetUnitName()][kv.number][6][3])
end
function TalentsManager:ParseTalentsInfor()
      local abilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
      for id, hero_info in pairs(ALL_HERO_TALENTS) do
          local hero_bonus_talents_value ={ {}, {}, {} }
          local hero_hidden_abilities = {}
          for talent_id, talent in pairs(hero_info) do
              for talent_id_bonus, talent_bonus_name in pairs(talent[4]) do
                  table.insert(hero_bonus_talents_value[talent_id], FindSpecialTalentValue(abilityKV,talent_bonus_name)  ) 
              end
              for hidden_id, hidden_ability_name in pairs(talent[3]) do
                if abilityKV[hidden_ability_name] then
                    if abilityKV[hidden_ability_name].AbilityBehavior and abilityKV[hidden_ability_name].AbilityBehavior:find('DOTA_ABILITY_BEHAVIOR_HIDDEN') then
                        table.insert(hero_hidden_abilities, hidden_ability_name)
                    end
                end
              end
          end
          HEROES_HIDDEN_ABILITIES[id] = hero_hidden_abilities
          HEROES_TALENT_INFORMATION[id] = hero_bonus_talents_value 
      end
end

function FindSpecialTalentValue(abilityKV,sTalentName)
    local specialVal = abilityKV[sTalentName]["AbilitySpecial"]
    local result = {}
    for l, m in pairs(specialVal) do
        for k,v in pairs(m) do
          if k~="var_type" and k~="ad_linked_ability" and k~="linked_ad_abilities" then
            if tonumber(v) then
                if v == math.floor(v) then
                   table.insert(result, v)
                else
                   table.insert(result, string.format("%.1f", v))
                end
            else
               table.insert(result, v)
            end
          end
        end
    end
    return result
end















































TalentsManager:InitTalentsSystem()