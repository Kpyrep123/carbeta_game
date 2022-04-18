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
	["npc_dota_hero_bloodseeker"] = {
		{"seeker_style_1", "pudge_style_1", {"blood_rite_datadriven", "pudge_meat_hook_lua", "huskar_berserkers_blood_lod", "ability_hero_attributes_cursed", "huskar_berserkers_blood_lod_passive", "bellatrix_live_transfusion"}, {"special_bonus_mp_400", "special_bonus_cursed_1", "special_bonus_cursed_2", "special_bonus_mp_regen_250", "special_bonus_hp_regen_16", "special_bonus_corruption_25", "special_bonus_hp_600", "special_bonus_cursed_3",}, "DOTA_ATTRIBUTE_AGILITY", {20,21,22}},
		{"seeker_style_2", "pudge_style_2", {"ability_spike_tearing_blow", "spike_heal", "angel_arena_shell", "ability_hero_attributes_spike", "generic_hidden", "spike_conclusion_lua"}, {"special_bonus_strength_6", "special_bonus_attack_damage_20", "special_bonus_unquie_spike_heal_dur", "special_bonus_unquie_blow_dur", "special_bonus_unquie_coold_red", "special_bonus_unquie_blow_dmg", "spike_special_bonus_shell_25", "spike_special_bonus_attack"}, "DOTA_ATTRIBUTE_STRENGTH", {20,29,7}},
	},
	["npc_dota_hero_drow_ranger"] = {
		{"azura_style_1", "azura", {"wave_of_silence_datadriven", "azura_gaze_of_exile", "azura_multishot_crossbow", "hoodwink_sharpshooter_release_custom", "generic_hidden", "hoodwink_sharpshooter_custom"}, {"special_bonus_unquie_gaze_damage", "special_bonus_attack_damage_25", "special_bonus_unquie_azura_creep_damage", "special_bonus_unquie_gaze_radius", "special_bonus_unique_azura_2", "special_bonus_unquie_sharo_max", "hoodwink_sharp_2", "special_bonus_Sharp_1"}, "DOTA_ATTRIBUTE_AGILITY", {22,20,15}},
	},
}

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

    for i=0,5 do
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