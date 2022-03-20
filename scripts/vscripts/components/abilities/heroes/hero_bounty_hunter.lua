
-------------------------------------------
--	   	       HEADHUNTER
-------------------------------------------
-- Visible Modifiers:
MergeTables(LinkedModifiers,{
	["modifier_imba_headhunter_buff_handler"] = LUA_MODIFIER_MOTION_NONE,
})
-- Hidden Modifiers:
MergeTables(LinkedModifiers,{
	["modifier_imba_headhunter_passive"] = LUA_MODIFIER_MOTION_NONE,
	["modifier_imba_headhunter_debuff_handler"] = LUA_MODIFIER_MOTION_NONE,
	["modifier_imba_headhunter_debuff_illu"] = LUA_MODIFIER_MOTION_NONE,
})
imba_bounty_hunter_headhunter = imba_bounty_hunter_headhunter or class({})
LinkLuaModifier("modifier_imba_headhunter_passive", "components/abilities/heroes/hero_bounty_hunter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_headhunter_debuff_handler", "components/abilities/heroes/hero_bounty_hunter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_headhunter_buff_handler", "components/abilities/heroes/hero_bounty_hunter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_headhunter_debuff_illu", "components/abilities/heroes/hero_bounty_hunter", LUA_MODIFIER_MOTION_NONE)

function imba_bounty_hunter_headhunter:GetAbilityTextureName()
	return "custom/bounty_hunter_headhunter"
end

function imba_bounty_hunter_headhunter:GetIntrinsicModifierName()
	return "modifier_imba_headhunter_passive"
end

function imba_bounty_hunter_headhunter:IsInnateAbility()
	return true
end

function imba_bounty_hunter_headhunter:OnProjectileHit(target, location)
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local modifier_contract_buff = "modifier_imba_headhunter_buff_handler"
	local modifier_contract_debuff = "modifier_imba_headhunter_debuff_handler"

	-- Ability specials
	local duration = ability:GetSpecialValueFor("duration")
	local vision_radius = ability:GetSpecialValueFor("vision_radius")
	local vision_linger_time = ability:GetSpecialValueFor("vision_linger_time")

	-- Check that the target exists
	if not target then
		return nil
	end

	-- Apply contract modifiers
	caster:AddNewModifier(caster, ability, modifier_contract_buff, {duration = duration})
	target:AddNewModifier(caster, ability, modifier_contract_debuff, {duration = duration * (1 - target:GetStatusResistance())})

	-- Show the area of the target
	AddFOWViewer(caster:GetTeamNumber(), target:GetAbsOrigin(), vision_radius, vision_linger_time, false)
end

--Contract buff (self)
modifier_imba_headhunter_passive = modifier_imba_headhunter_passive or class({})

function modifier_imba_headhunter_passive:OnCreated()
	if IsServer() then
		-- Ability properties
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.modifier_contract = "modifier_imba_headhunter_debuff_handler"
		self.particle_projectile = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_cast.vpcf"

		-- Ability specials
		self.projectile_speed = self.ability:GetSpecialValueFor("projectile_speed")
		self.starting_cd = self.ability:GetSpecialValueFor("starting_cd")
		self.vision_radius = self.ability:GetSpecialValueFor("vision_radius")

		-- Start the game with a cooldown
		self.ability:StartCooldown(self.starting_cd)

		self:StartIntervalThink(3)
	end
end

function modifier_imba_headhunter_passive:OnIntervalThink()
	if IsServer() then
		-- Check if the game start cooldown ended
		if not self.ability:IsCooldownReady() then
			return nil
		end

		-- if Bounty is currently broken, do nothing
		if self.caster:PassivesDisabled() then
			return nil
		end

		-- If Bounty is near the fountain, decide if a new contract should begin
		if IsNearFriendlyClass(self.caster, 1360, "ent_dota_fountain") then
			-- Find all enemy heroes and look for a contract debuff
			local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(),
				self.caster:GetAbsOrigin(),
				nil,
				50000, -- global
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO,
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO,
				FIND_ANY_ORDER,
				false)

			-- Iterate each enemy
			for _, enemy in pairs(enemies) do
				-- Check if that hero has the contract debuff, go out if it was found
				if enemy:HasModifier(self.modifier_contract) then
					return nil
				end
			end

			-- Check that an enemy really exists
			if not enemies[1] then
				return nil
			end

			-- If no enemy was found with a contract in the search, start a new contract with a random enemy
			local contract_enemy = enemies[1]

			-- Launch projectile on target
			local contract_projectile
			contract_projectile =   {
				Target = contract_enemy,
				Source = self.caster,
				Ability = self.ability,
				EffectName = self.particle_projectile,
				iMoveSpeed = self.projectile_speed,
				bDodgeable = false,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = true,
				iVisionRadius = self.vision_radius,
				iVisionTeamNumber = self.caster:GetTeamNumber()
			}

			ProjectileManager:CreateTrackingProjectile(contract_projectile)
		end
	end
end

function modifier_imba_headhunter_passive:IsDebuff()
	return false
end

function modifier_imba_headhunter_passive:IsPurgable()
	return false
end

function modifier_imba_headhunter_passive:IsHidden()
	return true
end

-- Contract self buff
modifier_imba_headhunter_buff_handler = class({})

function modifier_imba_headhunter_buff_handler:IsDebuff()
	return false
end

function modifier_imba_headhunter_buff_handler:IsPurgable()
	return false
end

function modifier_imba_headhunter_buff_handler:IsHidden()
	return false
end


-- Contract debuff
modifier_imba_headhunter_debuff_handler = modifier_imba_headhunter_debuff_handler or class({})

function modifier_imba_headhunter_debuff_handler:OnCreated()
	if IsServer() then
		-- Ability properties
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.particle_contract = "particles/hero/bounty_hunter/bounty_hunter_headhunter_scroll.vpcf"
		self.modifier_contract_buff = "modifier_imba_headhunter_buff_handler"
		self.track_debuff = "modifier_imba_track_debuff_mark"
		self.track_ability_name = "imba_bounty_hunter_track"
		self.modifier_dummy = "modifier_imba_headhunter_debuff_illu"

		-- Ability specials
		self.gold_minimum = self.ability:GetSpecialValueFor("gold_minimum")
		self.contract_vision_timer = self.ability:GetSpecialValueFor("contract_vision_timer")
		self.contract_vision_linger = self.ability:GetSpecialValueFor("contract_vision_linger")
		self.vision_radius = self.ability:GetSpecialValueFor("vision_radius")
		self.contract_gold_mult = self.ability:GetSpecialValueFor("contract_gold_mult")
		self.projectile_speed = self.ability:GetSpecialValueFor("projectile_speed")
		
		-- Apply particles visible only to the caster's team
		self.particle_contract_fx = ParticleManager:CreateParticleForTeam(self.particle_contract, PATTACH_OVERHEAD_FOLLOW, self.parent, self.caster:GetTeamNumber())
		ParticleManager:SetParticleControl(self.particle_contract_fx, 0, self.parent:GetAbsOrigin())
		ParticleManager:SetParticleControl(self.particle_contract_fx, 2, self.parent:GetAbsOrigin())

		self:AddParticle(self.particle_contract_fx, false, false, -1, false, true)

		self.time_passed = 0
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_headhunter_debuff_handler:OnIntervalThink()
	if IsServer() then
		if not self:GetAbility() then 
			self:StartIntervalThink(-1)
			self:Destroy()
			return
		end
		
		-- Find all heroes in the parent's team
		local heroes = FindUnitsInRadius(self.parent:GetTeamNumber(),
			self.parent:GetAbsOrigin(),
			nil,
			FIND_UNITS_EVERYWHERE, -- global
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED,
			FIND_ANY_ORDER,
			false)

		-- Check which of them are controlled by the same player and are illusions of the hero
		for _, hero in pairs(heroes) do
			if self.parent:GetPlayerID() == hero:GetPlayerID() and self.parent:GetUnitName() == hero:GetUnitName() and hero:IsIllusion() then
				-- Apply the debuff modifiers on those illusions as well, if they don't have it,
				-- however we apply dummy ones that only show particles
				hero:AddNewModifier(self.caster, self.ability, self.modifier_dummy, {duration = self:GetRemainingTime()})
			end
		end

		-- Count time!
		self.time_passed = self.time_passed + 0.1

		-- If enough time passed, show the target
		if self.time_passed >= self.contract_vision_timer then
			self.time_passed = 0

			ProjectileManager:CreateTrackingProjectile({
				Target = self.parent,
				Source = self.caster,
				Ability = self.ability,
				EffectName = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_cast.vpcf",
				iMoveSpeed = self.projectile_speed,
				bDodgeable = false,
				bVisibleToEnemies = false,
				bReplaceExisting = false
			})
			
			AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetAbsOrigin(), self.vision_radius, self.contract_vision_linger, false)
		end
	end
end

function modifier_imba_headhunter_debuff_handler:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_HERO_KILLED}

	return decFuncs
end

function modifier_imba_headhunter_debuff_handler:OnHeroKilled(keys)
	if IsServer() then
		local attacker = keys.attacker
		local target = keys.target
		local reincarnate = keys.reincarnate

		if self.parent == target then

			-- If the target is reincarnating, do nothing
			if reincarnate then
				return nil
			end

			-- Only apply if Bounty was the killer, OR the target had Track on it
			if self.caster == attacker or self.parent:HasModifier(self.track_debuff) then

				-- Check if the caster has Track as an ability
				if self.caster:HasAbility(self.track_ability_name) then

					-- Get ability handle
					self.track_ability = self.caster:FindAbilityByName("imba_bounty_hunter_track")

					-- Check if the ability has at least one level in it, if so, fetch allies gold value
					if self.track_ability:GetLevel() > 0 then
						self.contract_gold = self.track_ability:GetSpecialValueFor("bonus_gold_allies")
					end
				end

				-- If Track gold is defined, use it, otherwise use Headhunter's skill's minimum gold
				if not self.contract_gold then
					self.contract_gold = self.gold_minimum
				end

				-- Multiply the gold on the contract multiplier
				self.contract_gold = self.contract_gold * self.contract_gold_mult

				-- Grant Bounty Hunter the gold for completing the contract
				self.caster:ModifyGold(self.contract_gold, true, DOTA_ModifyGold_Unspecified)
				SendOverheadEventMessage(self.caster, OVERHEAD_ALERT_GOLD, self.caster, self.contract_gold, nil)

				-- Remove the contract modifier from Bounty Hunter
				if self.caster:HasModifier(self.modifier_contract_buff) then
					self.caster:RemoveModifierByName(self.modifier_contract_buff)
				end
			end

			-- Either way, destroy the modifier
			self:Destroy()
		end
	end
end

function modifier_imba_headhunter_debuff_handler:IsDebuff()
	return true
end

function modifier_imba_headhunter_debuff_handler:IsPurgable()
	return false
end

function modifier_imba_headhunter_debuff_handler:RemoveOnDeath()
	return false
end

function modifier_imba_headhunter_debuff_handler:IsHidden()
	return true
end

modifier_imba_headhunter_debuff_illu = modifier_imba_headhunter_debuff_illu or class({})

function modifier_imba_headhunter_debuff_illu:OnCreated()
	if IsServer() then
		self.caster = self:GetCaster()
		self.parent = self:GetParent()
		self.particle_contract = "particles/hero/bounty_hunter/bounty_hunter_headhunter_scroll.vpcf"

		self.particle_contract_fx = ParticleManager:CreateParticleForTeam(self.particle_contract, PATTACH_OVERHEAD_FOLLOW, self.parent, self.caster:GetTeamNumber())
		ParticleManager:SetParticleControl(self.particle_contract_fx, 0, self.parent:GetAbsOrigin())
		ParticleManager:SetParticleControl(self.particle_contract_fx, 2, self.parent:GetAbsOrigin())

		self:AddParticle(self.particle_contract_fx, false, false, -1, false, true)
	end
end

function modifier_imba_headhunter_debuff_illu:IsDebuff()
	return true
end

function modifier_imba_headhunter_debuff_illu:IsPurgable()
	return false
end

function modifier_imba_headhunter_debuff_illu:IsHidden()
	return true
end
-------------------------------------------
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
	LinkLuaModifier(LinkedModifier, "components/abilities/heroes/hero_bounty_hunter", MotionController)
end
