LinkLuaModifier("modifier_status_fire", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_cold", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_toxin", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_electro", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_status_viral", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_corrupt", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_gas", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_explosion", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_radiatoin", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_magnet", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_status_bleed", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_bash", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_piercing", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)

broken_heart = class({})

function broken_heart:GetIntrinsicModifierName(  )
	return "modifier_broken_heart"
end

LinkLuaModifier("modifier_broken_heart", "custom_abilities/feral_ghoul/broken_heart.lua", LUA_MODIFIER_MOTION_NONE)

modifier_broken_heart = class({})
function modifier_broken_heart:IsHidden() return true end
function modifier_broken_heart:IsPurgable() return false end
function modifier_broken_heart:GetEffectName() return "particles/heroes/ferral_goul_bleed_bloodseeker_rupture.vpcf" end

function modifier_broken_heart:OnCreated()
	self.radius = self:GetAbility():GetSpecialValueFor("crush_radius") + self:GetCaster():GetTalentValue("special_bonus_unquie_broken_heart_rad")
	self.chance = self:GetAbility():GetSpecialValueFor("boom_chance")
end

function modifier_broken_heart:OnRefresh()
	self.radius = self:GetAbility():GetSpecialValueFor("crush_radius") + self:GetCaster():GetTalentValue("special_bonus_unquie_broken_heart_rad")
	self.chance = self:GetAbility():GetSpecialValueFor("boom_chance")
end

function modifier_broken_heart:DeclareFunctions()
 local funcs = {
 			MODIFIER_EVENT_ON_ATTACKED,
 			MODIFIER_EVENT_ON_DEATH,
 }
return funcs
end

function modifier_broken_heart:OnAttacked( p )
	if p.target ~= self:GetParent() then return end
	if self:GetParent():PassivesDisabled() then return end
	if not self:GetAbility():IsCooldownReady() then return end
	local hAbility = self:GetAbility()
	local radius = self:GetAbility():GetSpecialValueFor("crush_radius") + self:GetCaster():GetTalentValue("special_bonus_unquie_broken_heart_rad")
	local damage = self:GetCaster():GetHealth() * (self:GetAbility():GetSpecialValueFor("hp_damage_small") + self:GetCaster():GetTalentValue("special_bonus_unique_ghoul_1")) / 100
	if RollPseudoRandom(self.chance, self:GetAbility()) then
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		
			for _,enemy in ipairs(enemies) do
				if self:GetCaster():IsRealHero() then 
						ApplyDamage({
						    victim = enemy,
						    attacker = self:GetCaster(),
						    damage = damage,
						    damage_type = DAMAGE_TYPE_MAGICAL,
						    damage_flags = DOTA_DAMAGE_FLAG_NONE,
						    ability = self:GetAbility()
					  	})
					  	print(damage)
					  	print(self:GetCaster():GetHealth())
					  	if RollPercentage(25) then 
					  		if enemy:HasModifier("modifier_status_electro") then 
					  			local electro = enemy:FindModifierByName("modifier_status_electro"):GetStackCount()
					  			local mod = enemy:AddNewModifier(self:GetCaster(), self, "modifier_status_corrupt", {duration = 5})
					  			enemy:RemoveModifierByName("modifier_status_electro")
					  			mod:SetStackCount(fire + 1) 
					  		elseif enemy:HasModifier("modifier_status_cold") then 
					  			local cold = enemy:FindModifierByName("modifier_status_cold"):GetStackCount()
					  			local mod = enemy:AddNewModifier(self:GetCaster(), self, "modifier_status_viral", {duration = 5})
					  			mod:SetStackCount(cold + 1)
					  			enemy:RemoveModifierByName("modifier_status_cold")
					  		elseif enemy:HasModifier("modifier_status_fire") then 
					  			local toxin = enemy:FindModifierByName("modifier_status_fire"):GetStackCount()
					  			local mod = enemy:AddNewModifier(self:GetCaster(), self, "modifier_status_gas", {duration = 3})
					  			mod:SetStackCount(toxin + 1)
					  			enemy:RemoveModifierByName("modifier_status_fire")
					  		else
					  			local mod = enemy:AddNewModifier(self:GetCaster(), self, "modifier_status_toxin", {duration = 3})
					  			mod:SetStackCount(mod:GetStackCount() + 1)
					  		end
					  	end
				end
			end
		self:PlayEffects()
		hAbility:StartCooldown(hAbility:GetCooldown(hAbility:GetLevel()))
	end
	
end
LinkLuaModifier("modifier_broken_heart_death", "custom_abilities/feral_ghoul/broken_heart.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_broken_heart:OnDeath( p )
	if p.unit ~= self:GetCaster() then return end
	local boom = CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_broken_heart_death", {duration = 0.4}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
end



function modifier_broken_heart:PlayEffects()
	-- stop sound
	local sound_end = "Hero_LifeStealer.Rage"
	StopSoundOn( sound_end, self:GetParent() )
	-- Get Resources
	local radius = self:GetAbility():GetSpecialValueFor("crush_radius") + self:GetCaster():GetTalentValue("special_bonus_unquie_broken_heart_rad")
	local particle_cast = "particles/heroes/ferral_ghoul/broken_heart.vpcf"
	local sound_target = "Hero_LifeStealer.Rage"
	StartAnimation(self:GetCaster(), {duration=0.4, activity=ACT_DOTA_OVERRIDE_ABILITY_1, rate=1.0})
	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_target, self:GetParent() )
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


modifier_broken_heart_death = class({})
function modifier_broken_heart_death:IsHidden() return false end
function modifier_broken_heart_death:IsPurgable() return false end
function modifier_broken_heart_death:GetTexture() return end
function modifier_broken_heart_death:GetEffectName() return end

function modifier_broken_heart_death:OnCreated()
	local radius = self:GetAbility():GetSpecialValueFor("racrush_radius") + self:GetCaster():GetTalentValue("special_bonus_unquie_broken_heart_rad") + 300
	local damage = self:GetCaster():GetMaxHealth() * self:GetAbility():GetSpecialValueFor("hp_damage") / 100
	local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,enemy in ipairs(enemies) do
		if self:GetCaster():IsRealHero() then 
				ApplyDamage({
				    victim = enemy,
				    attacker = self:GetCaster(),
				    damage = damage,
				    damage_type = DAMAGE_TYPE_MAGICAL,
				    damage_flags = DOTA_DAMAGE_FLAG_NONE,
				    ability = self:GetAbility()
			  	})
			  	print(damage)
			  	print(self:GetCaster():GetHealth())
		end
	end
	self:PlayEffects()
end

function modifier_broken_heart_death:OnRefresh()

end

function modifier_broken_heart_death:DeclareFunctions()
 local funcs = {

 }
return funcs
end

function modifier_broken_heart_death:PlayEffects()
	-- stop sound
	local sound_end = "Hero_LifeStealer.Rage"
	StopSoundOn( sound_end, self:GetParent() )
	-- Get Resources
	local radius = self:GetAbility():GetSpecialValueFor("crush_radius") + self:GetCaster():GetTalentValue("special_bonus_unquie_broken_heart_rad")
	local particle_cast = "particles/heroes/ferral_ghoul/broken_heart.vpcf"
	local sound_target = "Hero_LifeStealer.Rage"
	StartAnimation(self:GetCaster(), {duration=0.4, activity=ACT_DOTA_OVERRIDE_ABILITY_1, rate=1.0})
	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_target, self:GetParent() )
end