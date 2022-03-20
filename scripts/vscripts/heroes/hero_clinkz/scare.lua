
imba_clinkz_skeleton_walk = class({})
LinkLuaModifier("modifier_imba_skeleton_walk_invis", "components/abilities/heroes/hero_clinkz", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_clinkz_burning_army_skeleton_custom", "components/abilities/heroes/hero_clinkz", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_skeleton_walk_spook", "components/abilities/heroes/hero_clinkz", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_skeleton_walk_talent_root", "components/abilities/heroes/hero_clinkz", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_skeleton_walk_talent_ms", "components/abilities/heroes/hero_clinkz", LUA_MODIFIER_MOTION_NONE)

function imba_clinkz_skeleton_walk:GetAbilityTextureName()
   return "clinkz_wind_walk"
end

function imba_clinkz_skeleton_walk:IsHiddenWhenStolen()
	return false
end

function imba_clinkz_skeleton_walk:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local particle_invis = "particles/units/heroes/hero_clinkz/clinkz_windwalk.vpcf"
	local sound_cast = "Hero_Clinkz.WindWalk"
	local modifier_invis = "modifier_imba_skeleton_walk_invis"
	local scepter = caster:HasScepter()
	local modifier_mount = "modifier_imba_strafe_mount"

	-- Ability specials
	local duration = self:GetSpecialValueFor("duration")

	-- Play cast sound
	EmitSoundOn(sound_cast, caster)

	-- Add particle effect
	local particle_invis_fx = ParticleManager:CreateParticle(particle_invis, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle_invis_fx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_invis_fx, 1, caster:GetAbsOrigin())

	-- Apply invisibilty modifier on self
	caster:AddNewModifier(caster, self, modifier_invis, {duration = duration})

	-- Scepter skeleton walk on mounted 
	if scepter then        
		if caster:HasModifier(modifier_mount) then
			local modifier_mount_handler = caster:FindModifierByName(modifier_mount)
			if modifier_mount_handler then
				local mounted_ally = modifier_mount_handler.target
				mounted_ally:AddNewModifier(caster, self, modifier_invis, {duration = modifier_mount_handler:GetRemainingTime()})
			end
		end

	end
end

-- Invisibility modifier
modifier_imba_skeleton_walk_invis = class({})

function modifier_imba_skeleton_walk_invis:IsHidden() return false end
function modifier_imba_skeleton_walk_invis:IsPurgable() return false end
function modifier_imba_skeleton_walk_invis:IsDebuff() return false end

function modifier_imba_skeleton_walk_invis:OnCreated()
	-- Ability properties
	self.sound_cast = "Hero_Clinkz.WindWalk"
	self.modifier_spook = "modifier_imba_skeleton_walk_spook"        
	self.modifier_talent_ms = "modifier_imba_skeleton_walk_talent_ms"
	self.modifier_mount = "modifier_imba_strafe_mount"   

	-- Ability specials
	self.spook_radius = self:GetAbility():GetSpecialValueFor("spook_radius")
	self.base_spook_duration = self:GetAbility():GetSpecialValueFor("base_spook_duration")
	self.spook_distance_inc = self:GetAbility():GetSpecialValueFor("spook_distance_inc")
	self.spook_added_duration = self:GetAbility():GetSpecialValueFor("spook_added_duration")    
	self.ms_bonus_pct = self:GetAbility():GetSpecialValueFor("ms_bonus_pct")
	self.scepter_bonus = 0
	if self:GetCaster():HasScepter() then
		self.scepter_bonus = self:GetAbility():GetSpecialValueFor("scepter_bonus")

		if IsServer() and not self:GetParent():HasModifier("modifier_bloodseeker_thirst") then
			self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_bloodseeker_thirst", {})
		end
	end

	-- Talent: Increases Clinkz Skeleton Walk movement speed if no enemies are nearby.
	if IsServer() then
		self:StartIntervalThink(0.2)
	end
end

function modifier_imba_skeleton_walk_invis:OnIntervalThink()
	if IsServer() then
		-- If it is someone else from the caster (agh effect) then
		-- Check if the caster still has the Mounted buff. Remove it if he doesn't.    
		if self:GetParent() ~= self:GetCaster() then
			if not self:GetCaster():HasModifier(self.modifier_mount) then
				self:Destroy()
			end
		end	
	
		-- Talent: Increases Clinkz Skeleton Walk movement speed if no enemies are nearby.	
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
											self:GetCaster():GetAbsOrigin(),
											nil,
											self.spook_radius,
											DOTA_UNIT_TARGET_TEAM_ENEMY,
											DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
											DOTA_UNIT_TARGET_FLAG_NONE,
											FIND_ANY_ORDER,
											false)
											
		if self:GetCaster():HasTalent("special_bonus_imba_clinkz_2") then
			if #enemies > 0 then			    
				self:SetStackCount(self:GetCaster():FindTalentValue("special_bonus_imba_clinkz_2"))
			else
				self:SetStackCount(0)
			end
		end
			
	   -- Talent: If Clinkz passed through an enemy, root him and Clinkz loses Invisibility.	
		if self:GetCaster():HasTalent("special_bonus_imba_clinkz_3") then				
		
		local enemy_heroes = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
											self:GetParent():GetAbsOrigin(),
											nil,
											128,
											DOTA_UNIT_TARGET_TEAM_ENEMY,
											DOTA_UNIT_TARGET_HERO,
											DOTA_UNIT_TARGET_FLAG_NONE,
											FIND_CLOSEST,
											false)
											
			for _,enemy in pairs(enemy_heroes) do				
				-- Stop at the first valid enemy that isn't magic immune
				if not enemy:IsMagicImmune() then
					enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_skeleton_walk_talent_root", {duration = self:GetCaster():FindTalentValue("special_bonus_imba_clinkz_3") * (1 - enemy:GetStatusResistance())})

					-- If an enemy was rooted successfully, remove Clinkz's invisibility
					if enemy:HasModifier("modifier_imba_skeleton_walk_talent_root") then
						self:Destroy()
					end

					-- Stop the cycle!
					break
				end
			end
		end
		
		if self:GetCaster():HasScepter() and not self:GetParent():HasModifier("modifier_bloodseeker_thirst") then
			self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_bloodseeker_thirst", {})
		end
	end    
end

function modifier_imba_skeleton_walk_invis:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVISIBLE] = true
	}
end

function modifier_imba_skeleton_walk_invis:GetPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function modifier_imba_skeleton_walk_invis:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
					  MODIFIER_PROPERTY_MOVESPEED_MAX,
					  MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
					  MODIFIER_EVENT_ON_ABILITY_EXECUTED,
					  MODIFIER_EVENT_ON_ATTACK}
end

function modifier_imba_skeleton_walk_invis:GetModifierMoveSpeed_Max()
--	if self:GetStackCount() > 0 then
--		return 700
--	end

	-- Really, still not working?
	if self:GetParent():HasScepter() then
		return 5000
	end
end

function modifier_imba_skeleton_walk_invis:GetModifierInvisibilityLevel()
	return 1
end

function modifier_imba_skeleton_walk_invis:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus_pct + self:GetStackCount() + self.scepter_bonus
end

function modifier_imba_skeleton_walk_invis:OnAbilityExecuted(keys)
	if IsServer() then       
		local caster = keys.unit        

		-- Only apply when Clinkz was the one who activated an ability        
		if self:GetParent() == caster then            
			local enemy = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
											self:GetParent():GetAbsOrigin(),
											nil,
											1000,
											DOTA_UNIT_TARGET_TEAM_ENEMY,
											DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
											DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,
											FIND_CLOSEST,
											false)

			-- Check if Clinkz is visible to the enemy when appearing            
			if enemy[1] and enemy[1]:CanEntityBeSeenByMyTeam(self:GetParent()) then
				self.detected = true
			end

			-- Remove the invisibilty
			self:Destroy()        
		end        
	end
end

function modifier_imba_skeleton_walk_invis:OnAttack(keys)
	if IsServer() then
		local attacker = keys.attacker

		-- Only apply when Clinkz was the one attacking anything
		if self:GetParent() == attacker then
			-- Find nearby closest enemy
			local enemy = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
											self:GetParent():GetAbsOrigin(),
											nil,
											1000,
											DOTA_UNIT_TARGET_TEAM_ENEMY,
											DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
											DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,
											FIND_CLOSEST,
											false)
			
			-- Check if Clinkz is visible to the enemy when appearing            
			if enemy[1] and enemy[1]:CanEntityBeSeenByMyTeam(self:GetParent()) then
				self.detected = true
			end            
 
			-- Remove invisibility
			self:Destroy()
		end
	end
end

function modifier_imba_skeleton_walk_invis:OnRemoved()
	if IsServer() then
		if self:GetCaster():HasScepter() and self:GetCaster():FindAbilityByName("clinkz_burning_army") and self:GetCaster():FindAbilityByName("clinkz_burning_army"):IsTrained() then
			for i = 1, self:GetAbility():GetSpecialValueFor("scepter_skeleton_count") do
				local pos = self:GetCaster():GetAbsOrigin() + RandomVector(250)
				
				if i == 1 then
					pos	= self:GetCaster():GetAbsOrigin() + (self:GetCaster():GetRightVector() * 250 * (-1))
				elseif i == 2 then
					pos	= self:GetCaster():GetAbsOrigin() + (self:GetCaster():GetRightVector() * 250)
				end
				
				local archer = CreateUnitByName("npc_dota_clinkz_skeleton_archer", pos, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
				archer:AddNewModifier(self:GetCaster(), self:GetCaster():FindAbilityByName("clinkz_burning_army"), "modifier_imba_clinkz_burning_army_skeleton_custom", {})
				archer:AddNewModifier(self:GetCaster(), nil, "modifier_kill", {duration = self:GetCaster():FindAbilityByName("clinkz_burning_army"):GetSpecialValueFor("duration")})
				archer:SetForwardVector(self:GetCaster():GetForwardVector())
			end

			if self:GetParent():HasModifier("modifier_bloodseeker_thirst") then
				self:GetParent():RemoveModifierByName("modifier_bloodseeker_thirst")
			end
		end

		-- #6 Talent: Skeleton Walk move speed persists for a small period
		if self:GetCaster():HasTalent("special_bonus_imba_clinkz_6") then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), self.modifier_talent_ms, {duration = self:GetCaster():FindTalentValue("special_bonus_imba_clinkz_6")})
		end

		-- Only apply if Clinkz wasn't detected before removing modifier
		if self.detected then
			return nil
		end

		-- If Clinkz died, when it was removed, do nothing
		if not self:GetCaster():IsAlive() then
			return nil
		end

		-- Play cast sound, yes, again
		EmitSoundOn(self.sound_cast, self:GetParent())

		-- Find nearby enemies
		local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
										  self:GetParent():GetAbsOrigin(),
										  nil,
										  self.spook_radius,
										  DOTA_UNIT_TARGET_TEAM_ENEMY,
										  DOTA_UNIT_TARGET_HERO,
										  DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,
										  FIND_ANY_ORDER,
										  false)

		
		for _,enemy in pairs(enemies) do
			-- Only apply on non-magic immune enemies
			if not enemy:IsMagicImmune() then
				-- Calculate distance to each enemy
				local distance = (enemy:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D()

				-- Calculate spook duration
				local spook_duration = self.base_spook_duration + (((self.spook_radius - distance) / self.spook_distance_inc) * self.spook_added_duration)

				-- Apply spook for the duration
				enemy:AddNewModifier(self:GetParent(), self:GetAbility(), self.modifier_spook, {duration = spook_duration * (1 - enemy:GetStatusResistance())})
			end
		end
		
		-- Are we feeling extra spooky today? Did we actually spooky anyone?
		local spook_likelihood = 10
		if #enemies > 0 and RollPercentage(spook_likelihood) then
			-- sPo0kY sCaRy sKeLeToNs
			EmitSoundOn("Imba.ClinkzSpooky", self:GetParent())
		end
	end
end

function modifier_imba_skeleton_walk_invis:OnDestroy()
	if not IsServer() or not self:GetParent():IsAlive() then return end

	if self:GetAbility() and self:GetAbility():GetName() == "imba_clinkz_skeleton_walk_723" then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_clinkz_skeleton_walk_723_strafe", {duration = self:GetAbility():GetTalentSpecialValueFor("attack_speed_duration")})
	end
end
