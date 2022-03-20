function DonatorCompanion(ID, unit_name)
if unit_name == nil or PlayerResource:GetPlayer(ID):GetAssignedHero() == nil then return end
local hero = PlayerResource:GetPlayer(ID):GetAssignedHero()
-- local color = hero:GetFittingColor()
local model = GetKeyValueByHeroName(unit_name, "Model")
local model_scale = GetKeyValueByHeroName(unit_name, "ModelScale")

	if hero.companion then
		hero.companion:ForceKill(false)
	end

	local companion = CreateUnitByName("npc_chp_donator_companion", hero:GetAbsOrigin() + RandomVector(200), true, hero, hero, hero:GetTeamNumber())
	companion:SetModel(model)
	companion:SetOriginalModel(model)
	companion:SetOwner(hero)
	companion:SetControllableByPlayer(hero:GetPlayerID(), true)

	local flying = 0
	if string.find(model, "flying") then
		flying = 1
	end

	local modifier = companion:AddNewModifier(companion, nil, "modifier_companion", {flying = flying})

	hero.companion = companion

	-- Cookies #42 Companion
	if unit_name == "npc_chp_donator_companion_cookies" then
		local particle_name = {}
		particle_name[0] = "particles/econ/courier/courier_donkey_ti7/courier_donkey_ti7_ambient.vpcf"
		particle_name[1] = "particles/econ/courier/courier_golden_roshan/golden_roshan_ambient.vpcf"
		particle_name[2] = "particles/econ/courier/courier_platinum_roshan/platinum_roshan_ambient.vpcf"
		particle_name[3] = "particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon.vpcf" -- particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon_flying.vpcf
		particle_name[4] = "particles/econ/courier/courier_roshan_desert_sands/baby_roshan_desert_sands_ambient.vpcf"
		particle_name[5] = "particles/econ/courier/courier_roshan_lava/courier_roshan_lava.vpcf"
		particle_name[6] = "particles/econ/courier/courier_roshan_frost/courier_roshan_frost_ambient.vpcf"
		-- also attach eyes effect later
		local random_int = RandomInt(0, #particle_name)

		local particle = ParticleManager:CreateParticle(particle_name[random_int], PATTACH_ABSORIGIN_FOLLOW, companion)
		if random_int <= 4 then
			companion:SetMaterialGroup(tostring(random_int))
		else
			companion:SetModel("models/courier/baby_rosh/babyroshan_elemental.vmdl")
			companion:SetOriginalModel("models/courier/baby_rosh/babyroshan_elemental.vmdl")
			companion:SetMaterialGroup(tostring(random_int-4))
		end
	elseif unit_name == "npc_chp_donator_companion_suthernfriend" then
		companion:SetMaterialGroup("1")
	elseif unit_name == "npc_chp_donator_companion_golden_seekling" then
		companion:SetMaterialGroup("1")
		local particle = ParticleManager:CreateParticle("particles/econ/courier/courier_seekling_gold/courier_seekling_gold_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, companion)
		ParticleManager:ReleaseParticleIndex(particle)
	elseif unit_name == "npc_chp_donator_companion_faceless_rex" then
		-- missing this particle attached to weapon, find how to attach it! -- particles/econ/courier/courier_faceless_rex/cour_rex_weapon_glow.vpcf
		local particle = ParticleManager:CreateParticle("particles/econ/courier/courier_faceless_rex/cour_rex_flying.vpcf", PATTACH_ABSORIGIN_FOLLOW, companion)
		ParticleManager:SetParticleControlEnt(particle, 0, companion, PATTACH_POINT_FOLLOW, "attach_hitloc", companion:GetOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle)

		local particle = ParticleManager:CreateParticle("particles/econ/courier/courier_faceless_rex/cour_rex_weapon_glow.vpcf", PATTACH_ABSORIGIN_FOLLOW, companion)
		ParticleManager:SetParticleControlEnt(particle, 0, companion, PATTACH_POINT_FOLLOW, "attach_weapon_particles", companion:GetOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle)
	end

	companion:SetModelScale(model_scale)

	-- ability to swap between ground and flying version!
--	if super_donator then
--		local ab = companion:FindAbilityByName("companion_morph")
--		ab:SetLevel(1)
--		ab:CastAbility()		
--	end
end

function CHPGameMode:DonatorCompanionJS(event)
	DonatorCompanion(event.ID, event.unit)
end

function CHPGameMode:DonatorCompanionToggle(event)
	if PlayerResource:GetPlayer(event.ID):GetAssignedHero().companion then
		PlayerResource:GetPlayer(event.ID):GetAssignedHero().companion:ForceKill(false)
		PlayerResource:GetPlayer(event.ID):GetAssignedHero().companion = nil
	else
		if api.get_player(event.ID).companion_file then
			DonatorCompanion(event.ID, api.get_player(event.ID).companion_file)
		end
	end
end
