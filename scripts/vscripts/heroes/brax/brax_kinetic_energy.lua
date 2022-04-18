--	Thunderboar's Kinetic Energy
--	Concept by Brax
--	Implementation by Firetoad, 2018.08.21

LinkLuaModifier("modifier_kinetic_energy_self", "heroes/brax/brax_kinetic_energy.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_kinetic_energy_allies", "heroes/brax/brax_kinetic_energy.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_kinetic_energy_slow", "heroes/brax/brax_kinetic_energy.lua", LUA_MODIFIER_MOTION_NONE)

brax_kinetic_energy = class({})

-------------------------------

function brax_kinetic_energy:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function brax_kinetic_energy:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target_point = self:GetCursorPosition()
		local radius = self:GetSpecialValueFor("radius")
		local duration = self:GetSpecialValueFor("duration")
		local min_slow = self:GetSpecialValueFor("min_slow")
		local max_slow = self:GetSpecialValueFor("max_slow")
		local slow_linger = self:GetSpecialValueFor("slow_linger")
		local delta_slow = max_slow - min_slow
		local ability = self

		-- Play cast sound
		caster:EmitSound("Brax.KineticEnergyLoop")

		-- Play cast particles
		local energy_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_thunderboar/kinetic_energy.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(energy_pfx, 0, target_point)
		ParticleManager:SetParticleControl(energy_pfx, 1, Vector(duration, 0, 0))
		ParticleManager:SetParticleControl(energy_pfx, 2, Vector(radius, 0, 0))

		-- Spawn max tornados
		if caster:FindAbilityByName("brax_tornado") then
			local tornado_ability = caster:FindAbilityByName("brax_tornado")
			for i = 1, (tornado_ability:GetSpecialValueFor("max_units") + caster:GetTalentValue("special_bonus_brax_5")) do
				Timers:CreateTimer((i - 1) * (0.26 - 0.01 * i), function()
					tornado_ability:SpawnTornado(target_point + RandomVector(200))
				end)
			end
		end


		
			local dps_scepter = ability:GetSpecialValueFor("dps_scepter")
			Timers:CreateTimer(0, function()
				local units = FindUnitsInRadius(caster:GetTeamNumber(), target_point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				for _, unit in pairs(units) do
					if unit:GetTeam() ~= caster:GetTeam() then
						ApplyDamage({victim = unit, attacker = caster, damage = dps_scepter, damage_type = DAMAGE_TYPE_MAGICAL})
						local chance = self:GetSpecialValueFor("status_chance")
						if RollPercentage(chance) then 
						if unit:HasModifier("modifier_status_fire") then 
							local fire = unit:FindModifierByName("modifier_status_fire"):GetStackCount()
							local mod = unit:AddNewModifier(self:GetCaster(), self, "modifier_status_radiatoin", {duration = 5})
							unit:RemoveModifierByName("modifier_status_fire")
							mod:SetStackCount(fire + 1) 
						elseif unit:HasModifier("modifier_status_cold") then 
							local cold = unit:FindModifierByName("modifier_status_cold"):GetStackCount()
							local mod = unit:AddNewModifier(self:GetCaster(), self, "modifier_status_magnet", {duration = 5})
							mod:SetStackCount(cold + 1)
							unit:RemoveModifierByName("modifier_status_cold")
						elseif unit:HasModifier("modifier_status_toxin") then 
							local toxin = unit:FindModifierByName("modifier_status_toxin"):GetStackCount()
							local mod = unit:AddNewModifier(self:GetCaster(), self, "modifier_status_corrupt", {duration = 5})
							mod:SetStackCount(toxin + 1)
							unit:RemoveModifierByName("modifier_status_toxin")
						else
							local mod = unit:AddNewModifier(self:GetCaster(), self, "modifier_status_electro", {duration = 5})
							mod:SetStackCount(mod:GetStackCount() + 1)
						end
					end
								
					elseif unit == caster then
						ApplyDamage({victim = unit, attacker = caster, damage = dps_scepter, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL})
					end
				end
				duration = duration - 1
				if duration > 0 then
					return 1.0
				end
			end)


		-- Main ability loop
		Timers:CreateTimer(0, function()

			-- Enemy debuff
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target_point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				local enemy_slow = math.max(min_slow, min_slow + delta_slow * (1 - (enemy:GetAbsOrigin() - target_point):Length2D() / radius))
				enemy:AddNewModifier(caster, self, "modifier_kinetic_energy_slow", {duration = slow_linger*(1 - enemy:GetStatusResistance())}):SetStackCount(enemy_slow)
			end

			-- Allied buff
			--local caster_present = false
			--local allies = FindUnitsInRadius(caster:GetTeamNumber(), target_point, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)
			--for _, ally in pairs(allies) do
			--	if ally == caster then
			--		caster_present = true
			--		ally:AddNewModifier(caster, self, "modifier_kinetic_energy_self", {duration = slow_linger})
			--	else
			--		ally:AddNewModifier(caster, self, "modifier_kinetic_energy_allies", {duration = slow_linger})
			--	end
			--end

			if duration > 0 and (caster:GetAbsOrigin() - target_point):Length2D() <= radius and caster:IsAlive() then
				duration = duration - 0.1
				return 0.1
			else
				caster:StopSound("Brax.KineticEnergyLoop")
				ParticleManager:DestroyParticle(energy_pfx, true)
				ParticleManager:ReleaseParticleIndex(energy_pfx)
			end
		end)
	end
end

-------------------------------

modifier_kinetic_energy_self = class({})

function modifier_kinetic_energy_self:IsHidden() return false end
function modifier_kinetic_energy_self:IsDebuff() return false end
function modifier_kinetic_energy_self:IsPurgable() return false end

function modifier_kinetic_energy_self:GetEffectName()
	return "particles/units/heroes/hero_thunderboar/kinetic_energy_buff.vpcf"
end

function modifier_kinetic_energy_self:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_kinetic_energy_self:OnTakeDamage(keys)
	if IsServer() then
		if keys.attacker == self:GetParent() and keys.damage > 0 then
			local attacker = keys.attacker
			local target = keys.unit
			local damage = keys.damage
			local damage_flags = keys.damage_flags

			-- Calculate the amount of lifesteal
			local lifesteal_amount = self:GetAbility():GetSpecialValueFor("lifesteal")

			-- Do nothing if the victim is not a valid target, or if the lifesteal amount is nonpositive
			if target:IsBuilding() or target:IsIllusion() or (target:GetTeam() == attacker:GetTeam()) or bit.band(damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) == DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then
				return
			end

			local particle = "particles/generic_gameplay/generic_lifesteal.vpcf"

			if keys.damage_type == 2 then
				particle = "particles/items3_fx/octarine_core_lifesteal.vpcf"
			end

			-- Particle effect
			local lifesteal_pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, attacker)
			ParticleManager:SetParticleControl(lifesteal_pfx, 0, attacker:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(lifesteal_pfx)
				
			-- Actual lifesteal
			attacker:Heal(damage * lifesteal_amount * 0.01, attacker)
		end
	end
end

-------------------------------

modifier_kinetic_energy_allies = class({})

function modifier_kinetic_energy_allies:IsHidden() return false end
function modifier_kinetic_energy_allies:IsDebuff() return false end
function modifier_kinetic_energy_allies:IsPurgable() return false end

function modifier_kinetic_energy_allies:GetEffectName()
	return "particles/units/heroes/hero_thunderboar/kinetic_energy_buff.vpcf"
end

function modifier_kinetic_energy_allies:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_kinetic_energy_allies:OnTakeDamage(keys)
	if IsServer() then
		if keys.attacker == self:GetParent() and keys.damage > 0 then
			local attacker = keys.attacker
			local target = keys.unit
			local damage = keys.damage
			local damage_flags = keys.damage_flags

			-- Calculate the amount of lifesteal
			local lifesteal_amount = self:GetAbility():GetSpecialValueFor("lifesteal") * 0.5

			-- Do nothing if the victim is not a valid target, or if the lifesteal amount is nonpositive
			if target:IsBuilding() or target:IsIllusion() or (target:GetTeam() == attacker:GetTeam()) or bit.band(damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) == DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then
				return
			end

			local particle = "particles/items3_fx/octarine_core_lifesteal.vpcf"

			if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then
				particle = "particles/generic_gameplay/generic_lifesteal.vpcf"
			end

			-- Particle effect
			local lifesteal_pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, attacker)
			ParticleManager:SetParticleControl(lifesteal_pfx, 0, attacker:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(lifesteal_pfx)
				
			-- Actual lifesteal
			attacker:Heal(damage * lifesteal_amount * 0.01, attacker)
		end
	end
end

-------------------------------

modifier_kinetic_energy_slow = class({})

function modifier_kinetic_energy_slow:IsHidden() return false end
function modifier_kinetic_energy_slow:IsDebuff() return true end
function modifier_kinetic_energy_slow:IsPurgable() return true end

function modifier_kinetic_energy_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end
function modifier_kinetic_energy_slow:CheckState()
	if self:GetCaster():HasScepter() then
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
	}
	return state
	end
end

function modifier_kinetic_energy_slow:GetModifierMoveSpeedBonus_Percentage()
	return (-1) * self:GetStackCount()
end

function modifier_kinetic_energy_slow:GetEffectName()
	return "particles/units/heroes/hero_thunderboar/kinetic_energy_debuff.vpcf"
end