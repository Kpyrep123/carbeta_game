
imba_phantom_assassin_stifling_dagger = class({})

LinkLuaModifier("modifier_imba_stifling_dagger_slow", "components/abilities/heroes/hero_phantom_assassin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_stifling_dagger_silence", "components/abilities/heroes/hero_phantom_assassin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_stifling_dagger_bonus_damage", "components/abilities/heroes/hero_phantom_assassin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_stifling_dagger_dmg_reduction", "components/abilities/heroes/hero_phantom_assassin", LUA_MODIFIER_MOTION_NONE)

function imba_phantom_assassin_stifling_dagger:OnSpellStart()
	local caster 	= self:GetCaster()
	local target 	= self:GetCursorTarget()
	local scepter 	= caster:HasScepter()

	--ability specials
	self.scepter_knives_interval 	=	self:GetSpecialValueFor("scepter_knives_interval")
	self.cast_range					=	self:GetCastRange() + GetCastRangeIncrease(caster)
	self.playbackrate				=	1 + self.scepter_knives_interval

	--TALENT: +35 Stifling Dagger bonus damage
	if caster:HasTalent("special_bonus_imba_phantom_assassin_1") then
		bonus_damage	=	self:GetSpecialValueFor("bonus_damage") + self:GetCaster():GetTalentValue("special_bonus_imba_phantom_assassin_1")
	else
		bonus_damage	=	self:GetSpecialValueFor("bonus_damage")
	end

	--coup de grace variables
	local ability_crit = caster:FindAbilityByName("modifier_imba_coup_de_grace")
	local ps_coup_modifier = "modifier_imba_phantom_strike_coup_de_grace"

	StartSoundEvent("Ability.Assassinate", caster)

	local extra_data = {main_dagger = true}

	self:LaunchDagger(target, extra_data)

	-- Secondary knives
	if scepter or caster:HasTalent("special_bonus_imba_phantom_assassin_3") then
		local secondary_knives_thrown = 0

		-- TALENT: +1 Stifling Dagger bonus dagger (like aghs)
		if not scepter and caster:HasTalent("special_bonus_imba_phantom_assassin_3") then
			scepter_dagger_count = self:GetCaster():GetTalentValue("special_bonus_imba_phantom_assassin_3")
			-- secondary_knives_thrown = scepter_dagger_count
		elseif scepter and caster:HasTalent("special_bonus_imba_phantom_assassin_3") then
			scepter_dagger_count = self:GetSpecialValueFor("scepter_dagger_count") + self:GetCaster():GetTalentValue("special_bonus_imba_phantom_assassin_3")
		else
			scepter_dagger_count = self:GetSpecialValueFor("scepter_dagger_count")
		end

		-- Prepare extra_data
		extra_data = {main_dagger = false}

		-- Clear marks from all enemies
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
			caster:GetAbsOrigin(),
			nil,
			self.cast_range,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_UNITS_EVERYWHERE,
			false
		)
		
		for _, enemy in pairs(enemies) do
			if enemy ~= target then
				self:LaunchDagger(enemy, extra_data)
				secondary_knives_thrown = secondary_knives_thrown + 1
			end
			
			if secondary_knives_thrown >= scepter_dagger_count then
				break
			end
		end

		-- for _, enemy in pairs (enemies) do
			-- enemy.hit_by_pa_dagger = false
		-- end

		-- -- Mark the main target, set variables
		-- target.hit_by_pa_dagger = true
		-- local dagger_target_found

		-- -- Look for a secondary target to throw a knife at
		-- Timers:CreateTimer(self.scepter_knives_interval, function()
			-- -- Set variable for clear action
			-- dagger_target_found = false

			-- -- Look for a target in the cast range of the spell
			-- local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
				-- caster:GetAbsOrigin(),
				-- nil,
				-- self.cast_range,
				-- DOTA_UNIT_TARGET_TEAM_ENEMY,
				-- DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				-- DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
				-- FIND_ANY_ORDER,
				-- false)

			-- -- Check if there's an enemy unit without a mark. Mark it and throw a dagger to it
			-- for _, enemy in pairs (enemies) do
				-- if not enemy.hit_by_pa_dagger then
					-- enemy.hit_by_pa_dagger = true
					-- dagger_target_found = true

					-- caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, self.playbackrate)

					-- self:LaunchDagger(enemy, extra_data)
					-- break -- only hit the first enemy found
				-- end
			-- end

			-- -- If all enemies were found with a mark, clear all marks from everyone
			-- if not dagger_target_found then
				-- for _, enemy in pairs (enemies) do
					-- enemy.hit_by_pa_dagger = false
				-- end

				-- -- Throw dagger at a random enemy
				-- local enemy = enemies[RandomInt(1, #enemies)]

				-- self:LaunchDagger(enemy, extra_data)
			-- end

			-- -- Check if there are knives remaining
			-- secondary_knives_thrown = secondary_knives_thrown + 1
			-- if secondary_knives_thrown < scepter_dagger_count then
				-- return self.scepter_knives_interval
			-- else
				-- return nil
			-- end
		-- end)
	end
end

function imba_phantom_assassin_stifling_dagger:LaunchDagger(enemy)
	if enemy == nil then return end

	local dagger_projectile = {
		EffectName = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf",
		Dodgeable = true,
		Ability = self,
		ProvidesVision = true,
		VisionRadius = self:GetSpecialValueFor("dagger_vision"),
		bVisibleToEnemies = true,
		iMoveSpeed = self:GetSpecialValueFor("dagger_speed"),
		Source = self:GetCaster(),
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		Target = enemy,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		bReplaceExisting = false,
		ExtraData = extra_data
	}

	ProjectileManager:CreateTrackingProjectile(dagger_projectile)
end

function imba_phantom_assassin_stifling_dagger:OnProjectileHit( target, location )

	local caster = self:GetCaster()

	if not target then
		return false
	end

	-- With 20 percentage play random stifling dagger response
	local responses = {"phantom_assassin_phass_ability_stiflingdagger_01","phantom_assassin_phass_ability_stiflingdagger_02","phantom_assassin_phass_ability_stiflingdagger_03","phantom_assassin_phass_ability_stiflingdagger_04"}
	caster:EmitCasterSound("npc_dota_hero_phantom_assassin",responses, 20, DOTA_CAST_SOUND_FLAG_NONE, 20,"stifling_dagger")

	-- If the target possesses a ready Linken's Sphere, do nothing else
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		if target:TriggerSpellAbsorb(self) then
			return false
		end
	end

	-- Apply slow and silence modifiers
	if not target:IsMagicImmune() then
		target:AddNewModifier(caster, self, "modifier_imba_stifling_dagger_silence", {duration = self:GetSpecialValueFor("silence_duration") * (1 - target:GetStatusResistance())})
		target:AddNewModifier(caster, self, "modifier_imba_stifling_dagger_slow", {duration = self:GetSpecialValueFor("slow_duration") * (1 - target:GetStatusResistance())})
	end

	caster:AddNewModifier(caster, self, "modifier_imba_stifling_dagger_dmg_reduction", {})
	caster:AddNewModifier(caster, self, "modifier_imba_stifling_dagger_bonus_damage", {})

	-- fix to not decrement phantom strike attacks on dagger hit
	if caster:HasModifier("modifier_imba_phantom_strike_coup_de_grace") then
		caster:SetModifierStackCount("modifier_imba_phantom_strike_coup_de_grace", caster, caster:GetModifierStackCount("modifier_imba_phantom_strike_coup_de_grace", caster) + 1)
	end

	-- Attack (calculates on-hit procs)
	local initial_pos = caster:GetAbsOrigin()
	local target_pos = target:GetAbsOrigin()

	-- Offset is necessary, because cleave from Battlefury doesn't work (in any direction) if you are exactly on top of the target unit
	local offset = 100 --dotameters (default melee range is 150 dotameters)

	-- Find the distance vector (distance, but as a vector rather than Length2D)
	-- z is 0 to prevent any wonkiness due to height differences, we'll use the targets height, unmodified
	local distance_vector = Vector(target_pos.x - initial_pos.x, target_pos.y - initial_pos.y, 0)
	-- Normalize it, so the offset can be applied to x/y components, proportionally
	distance_vector = distance_vector:Normalized()

	-- Offset the caster 100 units in front of the target
	target_pos.x = target_pos.x - offset * distance_vector.x
	target_pos.y = target_pos.y - offset * distance_vector.y

	caster:SetAbsOrigin(target_pos)
	caster:PerformAttack(target, true, true, true, true, true, false, true)
	caster:SetAbsOrigin(initial_pos)

	caster:RemoveModifierByName( "modifier_imba_stifling_dagger_bonus_damage" )
	caster:RemoveModifierByName( "modifier_imba_stifling_dagger_dmg_reduction" )
	return true
end

function imba_phantom_assassin_stifling_dagger:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end
-------------------------------------------
-- Stifling Dagger slow modifier
-------------------------------------------

modifier_imba_stifling_dagger_slow = class({})

function modifier_imba_stifling_dagger_slow:GetModifierProvidesFOWVision()	return true end
function modifier_imba_stifling_dagger_slow:IsDebuff()		return true end
function modifier_imba_stifling_dagger_slow:IsPurgable()	return true end

function modifier_imba_stifling_dagger_slow:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local dagger_vision = self:GetAbility():GetSpecialValueFor("dagger_vision")
		local duration = self:GetAbility():GetSpecialValueFor("slow_duration")
		self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), caster)

		-- Add vision for the duration
		-- "This vision lingers for 3.34 seconds at the target's location upon successfully hitting it."
		AddFOWViewer(caster:GetTeamNumber(), self:GetParent():GetAbsOrigin(), dagger_vision, 3.34, false)
	end
end

function modifier_imba_stifling_dagger_slow:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_STATE_PROVIDES_VISION }
	return funcs
end

function modifier_imba_stifling_dagger_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("move_slow");
end

function modifier_imba_stifling_dagger_slow:OnDestroy()
	if not IsServer() then return end

	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
end

-------------------------------------------
-- Stifling Dagger silence modifier
-------------------------------------------

modifier_imba_stifling_dagger_silence = class({})

function modifier_imba_stifling_dagger_silence:OnCreated()
	self.stifling_dagger_modifier_silence_particle = ParticleManager:CreateParticle("particles/generic_gameplay/generic_silenced.vpcf", PATTACH_OVERHEAD_FOLLOW, self.target, self:GetCaster())
	ParticleManager:ReleaseParticleIndex(self.stifling_dagger_modifier_silence_particle)
end

function modifier_imba_stifling_dagger_silence:CheckState()
	return {[MODIFIER_STATE_SILENCED] = true}
end

function modifier_imba_stifling_dagger_silence:IsDebuff() 	return true end

function modifier_imba_stifling_dagger_silence:IsPurgable()	return true end

function modifier_imba_stifling_dagger_silence:IsHidden()		return true end

-------------------------------------------
-- Stifling Dagger bonus damage modifier
-------------------------------------------

modifier_imba_stifling_dagger_bonus_damage = class({})

function modifier_imba_stifling_dagger_bonus_damage:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_imba_stifling_dagger_bonus_damage:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_imba_stifling_dagger_bonus_damage:IsBuff()			return true end

function modifier_imba_stifling_dagger_bonus_damage:IsPurgable() 	return false end

function modifier_imba_stifling_dagger_bonus_damage:IsHidden() 	  return true end

-------------------------------------------
-- Stifling Dagger damage reduction modifier
-------------------------------------------

modifier_imba_stifling_dagger_dmg_reduction = class({})

function modifier_imba_stifling_dagger_dmg_reduction:OnCreated()
	self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
end

function modifier_imba_stifling_dagger_dmg_reduction:DeclareFunctions()
	local decFunc = {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
	return decFunc
end

function modifier_imba_stifling_dagger_dmg_reduction:GetModifierBaseDamageOutgoing_Percentage()
	return self.damage_reduction * (-1)
end

