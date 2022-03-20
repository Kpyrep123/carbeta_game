

--------------------------------
--       NETHER WARD          --
--------------------------------
imba_pugna_nether_ward = class({})
function imba_pugna_nether_ward:IsHiddenWhenStolen() return false end
function imba_pugna_nether_ward:IsRefreshable() return true end
function imba_pugna_nether_ward:IsStealable() return true end
function imba_pugna_nether_ward:IsNetherWardStealable() return false end

function imba_pugna_nether_ward:GetAbilityTextureName()
	return "pugna_nether_ward"
end

-------------------------------------------

function imba_pugna_nether_ward:GetBehavior()
	if IsServer() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_OPTIONAL_POINT
	else
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET
	end
end

function imba_pugna_nether_ward:CastFilterResultTarget( target )
	if target ~= nil and target == self:GetCaster() then
		return UF_SUCCESS
	end
end

function imba_pugna_nether_ward:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local target_point = self:GetCursorPosition()
	local ability = self
	local ability_level = ability:GetLevel()
	local sound_cast = "Hero_Pugna.NetherWard"
	local ability_ward = "imba_pugna_nether_ward_aura"
	local player_id = caster:GetPlayerID()

	-- Ability specials
	local duration = ability:GetSpecialValueFor("duration")

	local point = {}
	point[1] = target_point
	point[2] = RotatePosition(target_point, QAngle(0,90,0), target_point + (target_point - caster:GetAbsOrigin()):Normalized() * 64)
	point[3] = RotatePosition(target_point, QAngle(0,-90,0), target_point + (target_point - caster:GetAbsOrigin()):Normalized() * 64)
	-- Play cast sound
	EmitSoundOn(sound_cast, caster)
	for i = 1, 1 + caster:FindTalentValue("special_bonus_imba_pugna_8") do
		local nether_ward = nil
	
		-- Spawn the Nether Ward
		if i ~= 1 or not self:GetCursorTarget() or self:GetCursorTarget() ~= self:GetCaster() then
			nether_ward = CreateUnitByName("npc_imba_pugna_nether_ward_"..(ability_level), point[i], true, caster, caster, caster:GetTeam())
		else
			-- "When double-clicking the ability, the ward is placed right in front of Pugna, 150 range away from him."
			nether_ward = CreateUnitByName("npc_imba_pugna_nether_ward_"..(ability_level), self:GetCaster():GetAbsOrigin() + (self:GetCaster():GetForwardVector() * 150), true, caster, caster, caster:GetTeam())
		end
		-- FindClearSpaceForUnit(nether_ward, point[i], true)
		nether_ward:SetControllableByPlayer(player_id, true)

		-- -- Prevent nearby units from getting stuck
		-- Timers:CreateTimer(FrameTime(), function()
			-- ResolveNPCPositions(point[i], 128)
		-- end)

		-- Apply the Nether Ward duration modifier
		nether_ward:AddNewModifier(caster, ability, "modifier_kill", {duration = duration - duration * caster:FindTalentValue("special_bonus_imba_pugna_8","duration_reduce_pct") * 0.01})
		nether_ward:AddNewModifier(caster, ability, "modifier_rooted", {})

		-- Grant the Nether Ward its aura ability
		local aura_ability = nether_ward:FindAbilityByName(ability_ward)
		aura_ability:SetLevel(ability_level)
	end
end


--------------------------------
--        NETHER AURA         --
--------------------------------
imba_pugna_nether_ward_aura = class({})
LinkLuaModifier("modifier_imba_nether_ward_aura", "components/abilities/heroes/hero_pugna.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_nether_ward_degen", "components/abilities/heroes/hero_pugna.lua", LUA_MODIFIER_MOTION_NONE)

function imba_pugna_nether_ward_aura:GetAbilityTextureName()
	return "pugna_nether_ward"
end

function imba_pugna_nether_ward_aura:GetIntrinsicModifierName()
	return "modifier_imba_nether_ward_aura"
end

function imba_pugna_nether_ward_aura:GetCastRange()
	return self:GetSpecialValueFor("radius") end
-- Aura modifier
modifier_imba_nether_ward_aura = class({})

function modifier_imba_nether_ward_aura:OnCreated()
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()

	-- Ability specials
	self.radius = self.ability:GetSpecialValueFor("radius")
	self.hero_damage = self.ability:GetSpecialValueFor("hero_damage")
	self.creep_damage = self.ability:GetSpecialValueFor("creep_damage")
end


function modifier_imba_nether_ward_aura:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,}

	return decFuncs
end

function modifier_imba_nether_ward_aura:GetModifierIgnoreCastAngle()
	return 360
end

function modifier_imba_nether_ward_aura:OnAbilityFullyCast(keys)
	if not IsServer() then
		return
	end
	if keys.unit ~= self:GetParent() then
		return
	end
end

function modifier_imba_nether_ward_aura:GetModifierIncomingDamage_Percentage()
	return -100
end

function modifier_imba_nether_ward_aura:GetDisableHealing()
	return 1
end

function modifier_imba_nether_ward_aura:OnAttackLanded(keys)
	local target = keys.target
	local attacker = keys.attacker

	-- Only apply if the target of the landed attack is the Nether Ward
	if target == self.caster then
		local damage

		-- If the attacker is a real hero, a tower or Roshan, deal hero damage
		if attacker:IsRealHero() or attacker:IsTower() or attacker:IsRoshan() then
			damage = self.hero_damage
		else
			-- Assign creep or illusion damage
			damage = self.creep_damage
		end

		-- If the damage is enough to kill the ward, destroy it
		if self.caster:GetHealth() <= damage then
			self.caster:Kill(self.ability, attacker)

			-- Else, reduce its HP
		else
			self.caster:SetHealth(self.caster:GetHealth() - damage)
		end
	end
end

function modifier_imba_nether_ward_aura:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

function modifier_imba_nether_ward_aura:IsHidden() return true end
function modifier_imba_nether_ward_aura:IsPurgable() return false end
function modifier_imba_nether_ward_aura:IsDebuff() return false end

function modifier_imba_nether_ward_aura:GetAuraRadius()
	return self.radius
end

function modifier_imba_nether_ward_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_imba_nether_ward_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_imba_nether_ward_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_imba_nether_ward_aura:GetModifierAura()
	return "modifier_imba_nether_ward_degen"
end

function modifier_imba_nether_ward_aura:IsAura()
	return true
end



-- Degen modifier
modifier_imba_nether_ward_degen = class({})


function modifier_imba_nether_ward_degen:OnCreated()
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	self.sound_zap = "Hero_Pugna.NetherWard.Attack"
	self.sound_target = "Hero_Pugna.NetherWard.Target"
	self.particle_heavy = "particles/econ/items/pugna/pugna_ward_ti5/pugna_ward_attack_heavy_ti_5.vpcf"
	self.particle_medium = "particles/econ/items/pugna/pugna_ward_ti5/pugna_ward_attack_medium_ti_5.vpcf"
	self.particle_light = "particles/econ/items/pugna/pugna_ward_ti5/pugna_ward_attack_light_ti_5.vpcf"

	-- SAFEGUARD AGAINST CRASHES
	if not self.ability then
		self:Destroy()
		return nil
	end

	-- Ability specials
	self.mana_regen_reduction = self.ability:GetSpecialValueFor("mana_regen_reduction") * (-1)
	self.hero_damage = self.ability:GetSpecialValueFor("hero_damage")
	self.creep_damage = self.ability:GetSpecialValueFor("creep_damage")
	self.spell_damage = self.ability:GetSpecialValueFor("spell_damage")
	
	if not IsServer() then return end
	
	if self:GetCaster() and self:GetCaster():GetOwner() and self:GetCaster():GetOwner():HasAbility("imba_pugna_nether_ward") then
		self.mana_multiplier = self:GetCaster():GetOwner():FindAbilityByName("imba_pugna_nether_ward"):GetTalentSpecialValueFor("mana_multiplier")
	else
		self.mana_multiplier = self.ability:GetTalentSpecialValueFor("mana_multiplier")
	end
end

function modifier_imba_nether_ward_degen:IsHidden() return false end
function modifier_imba_nether_ward_degen:IsPurgable() return false end
function modifier_imba_nether_ward_degen:IsDebuff() return true end

function modifier_imba_nether_ward_degen:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_imba_nether_ward_degen:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
		MODIFIER_EVENT_ON_SPENT_MANA
	}
end


function modifier_imba_nether_ward_degen:GetModifierTotalPercentageManaRegen()
	return self.mana_regen_reduction
end

function modifier_imba_nether_ward_degen:OnSpentMana(keys)
	if IsServer() then
		local target 		= 	keys.unit
		local cast_ability 	= 	keys.ability
		local ability_cost	= 	keys.cost
		-- If there is no target ability, or the ability costs no mana, do nothing
		if not target or not cast_ability or not ability_cost or ability_cost == 0 then
			return nil
		end

		-- If the caster of the event is not the one holding the modifier, do nothing
		if target ~= self.parent then
			return nil
		end

		-- If the caster of the ability is a Nether Ward, do nothing
		if string.find(target:GetUnitName(), "npc_imba_pugna_nether_ward") then
			return nil
		end
		
		-- Check if the ability is tagged as an allowed ability for Nether Ward through the ability definition
		if cast_ability.IsNetherWardStealable then
			if not cast_ability:IsNetherWardStealable() then
				return nil
			end
		end

		local ward = self.caster
		local caster = ward:GetOwnerEntity()
		local ability_zap = self.ability
		if caster:HasTalent("special_bonus_imba_pugna_6") then
			ward:AddNewModifier(ward, nil, "modifier_pugna_decrepify", {duration = caster:FindTalentValue("special_bonus_imba_pugna_6")})
		end

		-- Deal damage
		ApplyDamage({attacker = ward,
			victim = target,
			ability = ability_zap,
			damage = ability_cost * self.mana_multiplier,
			damage_type = DAMAGE_TYPE_MAGICAL})

		-- Play zap sounds
		ward:EmitSound(self.sound_zap)
		target:EmitSound(self.sound_target)

		-- Play zap particle
		if ability_cost < 200 then
			local zap_pfx = ParticleManager:CreateParticle(self.particle_light, PATTACH_ABSORIGIN, target)
			ParticleManager:SetParticleControlEnt(zap_pfx, 0, ward, PATTACH_POINT_FOLLOW, "attach_hitloc", ward:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(zap_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(zap_pfx)
		elseif ability_cost < 400 then
			local zap_pfx = ParticleManager:CreateParticle(self.particle_medium, PATTACH_ABSORIGIN, target)
			ParticleManager:SetParticleControlEnt(zap_pfx, 0, ward, PATTACH_POINT_FOLLOW, "attach_hitloc", ward:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(zap_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(zap_pfx)
		else
			local zap_pfx = ParticleManager:CreateParticle(self.particle_heavy, PATTACH_ABSORIGIN, target)
			ParticleManager:SetParticleControlEnt(zap_pfx, 0, ward, PATTACH_POINT_FOLLOW, "attach_hitloc", ward:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(zap_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(zap_pfx)
		end

		-- If the ward does not have enough health to survive a spell cast, do nothing
		if ward:GetHealth() <= self.spell_damage then
			return nil
		end

		-- Iterate through the ability list
		local cast_ability_name = cast_ability:GetName()
		local forbidden_abilities = {
			"ancient_apparition_ice_blast",
			"furion_teleportation",
			"furion_wrath_of_nature",
			"life_stealer_infest",
			"life_stealer_assimilate",
			"life_stealer_assimilate_eject",
			"storm_spirit_static_remnant",
			"storm_spirit_ball_lightning",
			"invoker_ghost_walk",
			"shadow_demon_shadow_poison",
			"shadow_demon_demonic_purge",
			"phantom_lancer_doppelwalk",
			"chaos_knight_phantasm",
			"wisp_relocate",
			"templar_assassin_refraction",
			"templar_assassin_meld",
			"naga_siren_mirror_image",
			"imba_ember_spirit_activate_fire_remnant",
			"legion_commander_duel",
			"phoenix_fire_spirits",
			"terrorblade_conjure_image",
			"winter_wyvern_arctic_burn",
			"beastmaster_call_of_the_wild",
			"beastmaster_call_of_the_wild_boar",
			"dark_seer_ion_shell",
			"dark_seer_wall_of_replica",
			"morphling_waveform",
			"morphling_adaptive_strike",
			"morphling_replicate",
			"morphling_morph_replicate",
			"morphling_hybrid",
			"leshrac_pulse_nova",
			"rattletrap_power_cogs",
			"rattletrap_rocket_flare",
			"rattletrap_hookshot",
			"spirit_breaker_charge_of_darkness",
			"shredder_timber_chain",
			"shredder_chakram",
			"shredder_chakram_2",
			"spectre_haunt",
			"windrunner_focusfire",
			"viper_poison_attack",
			"arc_warden_tempest_double",
			"broodmother_insatiable_hunger",
			"weaver_time_lapse",
			"death_prophet_exorcism",
			"treant_eyes_in_the_forest",
			"treant_living_armor",
			"imba_enchantress_impetus",
			"chen_holy_persuasion",
			"batrider_firefly",
			"undying_decay",
			"undying_tombstone",
			"tusk_walrus_kick",
			"tusk_walrus_punch",
			"tusk_frozen_sigil",
			"gyrocopter_flak_cannon",
			"elder_titan_echo_stomp_spirit",
			"imba_elder_titan_ancestral_spirit",
			"visage_soul_assumption",
			"visage_summon_familiars",
			"earth_spirit_geomagnetic_grip",
			"keeper_of_the_light_recall",
			"monkey_king_boundless_strike",
			"monkey_king_mischief",
			"monkey_king_tree_dance",
			"monkey_king_primal_spring",
			"monkey_king_wukongs_command",
			"doom_doom",
			"zuus_cloud",
			"void_spirit_aether_remnant",
			"imba_rubick_spellsteal",
			"rubick_spell_steal",
			"imba_bristleback_bristleback",
			
			"lone_druid_spirit_bear",
			"imba_lone_druid_spirit_bear",
			"lone_druid_true_form",
			"imba_lone_druid_true_form",
			"terrorblade_metamorphosis",
			"imba_terrorblade_metamorphosis",
			"undying_flesh_golem",
			"imba_undying_flesh_golem",
			"dragon_knight_elder_dragon_form",
			"imba_dragon_knight_elder_dragon_form",
			
			"imba_alchemist_unstable_concoction",
			"imba_alchemist_chemical_rage"
		}

		-- Ignore items
		if string.find(cast_ability_name, "item") then
			return nil
		end

		if target:IsMagicImmune() then
			return
		end


		-- If the ability is on the list of uncastable abilities, do nothing
		for _,forbidden_ability in pairs(forbidden_abilities) do
			if cast_ability_name == forbidden_ability then
				return nil
			end
		end

		-- Look for the cast ability in the Nether Ward's own list
		local ability = ward:FindAbilityByName(cast_ability_name)

		-- If it was not found, add it to the Nether Ward
		if not ability then
			ward:AddAbility(cast_ability_name)
			ability = ward:FindAbilityByName(cast_ability_name)

			-- Else, activate it
		else
			ability:SetActivated(true)
		end

		-- Level up the ability
		ability:SetLevel(cast_ability:GetLevel())

		-- Refresh the ability
		ability:EndCooldown()

		if cast_ability.GetAutoCastState and cast_ability:GetAutoCastState() and ability.GetAutoCastState and not ability:GetAutoCastState() then
			ability:ToggleAutoCast()
		end

		local ability_range = ability:GetCastRange(ward:GetAbsOrigin(), target)
		local target_point = target:GetAbsOrigin()
		local ward_position = ward:GetAbsOrigin()

		-- Special cases

		-- Dark Ritual: target a random nearby creep
		if cast_ability_name == "imba_lich_dark_ritual" then
			local creeps = FindUnitsInRadius(   caster:GetTeamNumber(),
				ward:GetAbsOrigin(),
				nil,
				ability_range,
				DOTA_UNIT_TARGET_TEAM_BOTH,
				DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS + DOTA_UNIT_TARGET_FLAG_NOT_SUMMONED,
				FIND_CLOSEST,
				false)

			-- If there are no creeps nearby, do nothing (ward also counts as a creep)
			if #creeps == 1 then
				return nil
			end

			-- Find the SECOND closest creep and set it as the target (since the ward counts as a creep)
			target = creeps[2]
			target_point = target:GetAbsOrigin()
			ability_range = ability:GetCastRange(ward:GetAbsOrigin(), target)
		end

		-- Nether Strike: add greater bash
		if cast_ability_name == "spirit_breaker_nether_strike" then
			ward:AddAbility("spirit_breaker_greater_bash")
			local ability_bash = ward:FindAbilityByName("spirit_breaker_greater_bash")
			ability_bash:SetLevel(4)
		end

		-- Repel: Find a target to cast it on
		if cast_ability_name == "imba_omniknight_repel" then
			local allies = FindUnitsInRadius(caster:GetTeamNumber(),
				ward:GetAbsOrigin(),
				nil,
				ability_range,
				DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
				FIND_CLOSEST,
				false)

			-- If there are no allies nearby, cast on self
			if #allies == 1 then
				target = allies[1]
				target_point = target:GetAbsOrigin()
				ability_range = ability:GetCastRange(ward:GetAbsOrigin(), target)
			else
				-- Find the closest ally and set it as the target
				target = allies[2]
				target_point = target:GetAbsOrigin()
				ability_range = ability:GetCastRange(ward:GetAbsOrigin(), target)
			end
		end


		-- Meat Hook: ignore cast range
		if cast_ability_name == "imba_pudge_meat_hook" then
			ability_range = ability:GetLevelSpecialValueFor("base_range", ability:GetLevel() - 1)
		end

		-- Earth Splitter: ignore cast range
		if cast_ability_name == "elder_titan_earth_splitter" then
			ability_range = 25000
		end

		-- Shadowraze: face the caster
		if cast_ability_name == "imba_nevermore_shadowraze_close" or cast_ability_name == "imba_nevermore_shadowraze_medium" or cast_ability_name == "imba_nevermore_shadowraze_far" then
			ward:SetForwardVector((target_point - ward_position):Normalized())
		end

		-- Reqiuem of Souls: Get target's Necromastery stack count
		if cast_ability_name == "imba_nevermore_requiem" and not ward:HasModifier("modifier_imba_necromastery_souls") and target:HasAbility("imba_nevermore_necromastery") then
			local ability_handle = ward:AddAbility("imba_nevermore_necromastery")
			ability_handle:SetLevel(7)

			-- Find target's modifier and its stacks
			if target:HasModifier("modifier_imba_necromastery_souls") then
				local stacks = target:GetModifierStackCount("modifier_imba_necromastery_souls", target)

				-- Set the ward stacks count to be the same as the caster
				if ward:HasModifier("modifier_imba_necromastery_souls") then
					local modifier_souls_handler = ward:FindModifierByName("modifier_imba_necromastery_souls")
					if modifier_souls_handler then
						modifier_souls_handler:SetStackCount(stacks)
					end
				end
			end
		end

		-- Storm Bolt: choose another target
		if cast_ability_name == "imba_sven_storm_bolt" then
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), ward_position, nil, ability_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			if #enemies > 0 then
				if enemies[1]:FindAbilityByName("imba_sven_storm_bolt") then
					if #enemies > 1 then
						target = enemies[2]
					else
						return nil
					end
				else
					target = enemies[1]
				end
			else
				return nil
			end
		end

		-- Sun Strike: global cast range
		if cast_ability_name == "invoker_sun_strike" then
			ability_range = 25000
		end

		-- Eclipse: add lucent beam before cast
		if cast_ability_name == "luna_eclipse" then
			if not ward:FindAbilityByName("luna_lucent_beam") then
				ward:AddAbility("luna_lucent_beam")
			end
			local ability_lucent = ward:FindAbilityByName("luna_lucent_beam")
			ability_lucent:SetLevel(4)
		end

		-- Decide which kind of targetting to use
		local ability_behavior = ability:GetBehavior()
		local ability_target_team = ability:GetAbilityTargetTeam()

		-- If the ability is hidden, reveal it and remove the hidden binary sum
		if ability:IsHidden() then
			ability:SetHidden(false)
			ability_behavior = ability_behavior - 1
		end

		-- Memorize if an ability was actually cast
		local ability_was_used = false

		if ability_behavior == DOTA_ABILITY_BEHAVIOR_NONE then
		--Do nothing, not suppose to happen

		-- Toggle ability
		elseif ability_behavior % DOTA_ABILITY_BEHAVIOR_TOGGLE == 0 then
			ability:ToggleAbility()
			ability_was_used = true

			-- Point target ability
		elseif ability_behavior % DOTA_ABILITY_BEHAVIOR_POINT == 0 then

			-- If the ability targets allies, use it on the ward's vicinity
			if ability_target_team == DOTA_UNIT_TARGET_TEAM_FRIENDLY then
				ExecuteOrderFromTable({ UnitIndex = ward:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_CAST_POSITION, Position = ward:GetAbsOrigin(), AbilityIndex = ability:GetEntityIndex(), Queue = queue})
				ability_was_used = true

				-- Else, use it as close as possible to the enemy
			else

				-- If target is not in range of the ability, use it on its general direction
				if ability_range > 0 and (target_point - ward_position):Length2D() > ability_range then
					target_point = ward_position + (target_point - ward_position):Normalized() * (ability_range - 50)
				end
				ExecuteOrderFromTable({ UnitIndex = ward:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_CAST_POSITION, Position = target_point, AbilityIndex = ability:GetEntityIndex(), Queue = queue})
				ability_was_used = true
			end

			-- Unit target ability
		elseif ability_behavior % DOTA_ABILITY_BEHAVIOR_UNIT_TARGET == 0 then

			-- If the ability targets allies, use it on a random nearby ally
			if ability_target_team == DOTA_UNIT_TARGET_TEAM_FRIENDLY then

				-- Find nearby allies
				local allies = FindUnitsInRadius(caster:GetTeamNumber(), ward_position, nil, ability_range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

				-- If there is at least one ally nearby, cast the ability
				if #allies > 0 then
					ExecuteOrderFromTable({ UnitIndex = ward:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_CAST_TARGET, TargetIndex = allies[1]:GetEntityIndex(), AbilityIndex = ability:GetEntityIndex(), Queue = queue})
					ability_was_used = true
				end

				-- If not, try to use it on the original caster
			elseif (target_point - ward_position):Length2D() <= ability_range then
				ExecuteOrderFromTable({ UnitIndex = ward:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_CAST_TARGET, TargetIndex = target:GetEntityIndex(), AbilityIndex = ability:GetEntityIndex(), Queue = queue})
				ability_was_used = true

				-- If the original caster is too far away, cast the ability on a random nearby enemy
			else

				-- Find nearby enemies
				local enemies = FindUnitsInRadius(caster:GetTeamNumber(), ward_position, nil, ability_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

				-- If there is at least one ally nearby, cast the ability
				if #enemies > 0 then
					ExecuteOrderFromTable({ UnitIndex = ward:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_CAST_TARGET, TargetIndex = enemies[1]:GetEntityIndex(), AbilityIndex = ability:GetEntityIndex(), Queue = queue})
					ability_was_used = true
				end
			end

			-- No-target ability
		elseif ability_behavior % DOTA_ABILITY_BEHAVIOR_NO_TARGET == 0 then
			ability:CastAbility()
			ability_was_used = true
		end

		-- Very edge cases in which the nether ward is silenced (doesn't actually cast a spell)
		if ward:IsSilenced() then
			ability_was_used	=	false
		end

		-- If an ability was actually used, reduce the ward's health
		if ability_was_used then
			ward:SetHealth(ward:GetHealth() - self.spell_damage)
		end

		-- Refresh the ability's cooldown and set it as inactive
		local cast_point = ability:GetCastPoint()
		Timers:CreateTimer(cast_point + 0.5, function()
			ability:SetActivated(false)
		end)
	end
end
