--	Troy's Fury
--	by Firetoad, 2018.06.21

LinkLuaModifier("modifier_fury_knockback", "heroes/troy/troy_fury.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fury_talent", "heroes/troy/troy_fury.lua", LUA_MODIFIER_MOTION_NONE)

troy_fury = troy_fury or class({})

function troy_fury:OnSpellStart()			
	if IsServer() then
		-- Ability properties
		local caster = self:GetCaster()

		-- Ability specials
		local delay = self:GetSpecialValueFor("delay")
		local radius = self:GetSpecialValueFor("radius")
		local creep_damage = self:GetSpecialValueFor("base_damage")
		local hero_damage = creep_damage + caster:GetMaxHealth() * (self:GetSpecialValueFor("health_as_damage") + caster:GetTalentValue("special_bonus_troy_fury")) * 0.01
		local cast_damage = caster:GetMaxHealth() * self:GetSpecialValueFor("health_cost") * 0.01
		local knockback_distance = self:GetSpecialValueFor("knockback_distance")
		local knockback_height = self:GetSpecialValueFor("knockback_height")
		local knockback_duration = self:GetSpecialValueFor("knockback_duration")

		-- Pay health cost
		ApplyDamage({victim = caster, attacker = caster, damage = cast_damage, 
			damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS})

		-- Add immolation stacks from the health cost
		if caster:FindAbilityByName("troy_immolation") then
			local immolation_ability = caster:FindAbilityByName("troy_immolation")
			if immolation_ability:GetLevel() > 0 then
				local duration = immolation_ability:GetSpecialValueFor("duration") + caster:GetTalentValue("special_bonus_troy_immolation_duration")
				caster:AddNewModifier(caster, immolation_ability, "modifier_immolation_stacks", {duration = duration}):SetStackCount(cast_damage)
			end
		end

		-- Play cast sound
		caster:EmitSound("Hero_Jeremy.Fury")

		-- Play cast particle
		local impact_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_troy/troy_fury.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(impact_pfx, 0, Vector(radius, 0, 0))
		ParticleManager:ReleaseParticleIndex(impact_pfx)

		-- Wait [delay]
		Timers:CreateTimer(delay, function()
			-- Calculate knockback
			local center = caster:GetAbsOrigin()
			local knockback = {
				center_x = center.x,
				center_y = center.y,
				center_z = center.z,
				knockback_duration = knockback_duration,
				knockback_distance = knockback_distance,
				knockback_height = knockback_height,
				should_stun = 1,
				duration = knockback_duration
			}
			local rad = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
					ParticleManager:SetParticleControl(rad, 0, Vector(radius, 0, 0))
					ParticleManager:ReleaseParticleIndex(rad)
					self:GetCaster():EmitSound("Hero_Beastmaster.Primal_Roar")
			-- Hero effect
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), center, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				ApplyDamage({victim = enemy, attacker = caster, damage = hero_damage, damage_type = DAMAGE_TYPE_MAGICAL})
				enemy:EmitSound("Hero_Spirit_Breaker.Charge.Impact")
				enemy:RemoveModifierByName("modifier_knockback")
				enemy:AddNewModifier(caster, self, "modifier_knockback", knockback)
				enemy:AddNewModifier(caster, self, "modifier_fury_knockback", {duration = knockback_duration})
			end

			-- Creep effect
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), center, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				ApplyDamage({victim = enemy, attacker = caster, damage = creep_damage, damage_type = DAMAGE_TYPE_MAGICAL})
				enemy:EmitSound("Hero_Spirit_Breaker.Charge.Impact")
				enemy:RemoveModifierByName("modifier_knockback")
				enemy:AddNewModifier(caster, self, "modifier_knockback", knockback)
				enemy:AddNewModifier(caster, self, "modifier_fury_knockback", {duration = knockback_duration})
				if self:GetCaster():HasTalent("special_bonus_troy_instant_arena") then 
					local heal = enemy:GetHealth() * 0.06
					self:GetCaster():Heal(heal, self)
					local heal_part = ParticleManager:CreateParticle("models/veng/particles/arena/items_fx/tango_arena_cast_flare.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
					ParticleManager:SetParticleControl(heal_part, 0, Vector(radius, 0, 0))
					ParticleManager:ReleaseParticleIndex(heal_part)
				end
			end
		end)
	end
end

-- Deprecated talent
--function troy_fury:GetIntrinsicModifierName()
--	return "modifier_fury_talent"
--end

-------------------------------

modifier_fury_knockback = class({})

function modifier_fury_knockback:IsHidden() return false end
function modifier_fury_knockback:IsDebuff() return false end
function modifier_fury_knockback:IsPurgable() return false end

function modifier_fury_knockback:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true}
end

-------------------------------

modifier_fury_talent = class({})

function modifier_fury_talent:IsHidden() return true end
function modifier_fury_talent:IsDebuff() return false end
function modifier_fury_talent:IsPurgable() return false end

function modifier_fury_talent:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH
	}

	return funcs
end

function modifier_fury_talent:OnDeath(keys)
	if IsServer() then
		if keys.unit == self:GetParent() then
			local caster = self:GetParent()
			local talent = caster:FindAbilityByName("special_bonus_troy_death_fury")
			if talent and talent:GetLevel() > 0 then

				local ability = self:GetAbility()
				local radius = ability:GetSpecialValueFor("radius")
				local damage = (ability:GetSpecialValueFor("base_damage") + caster:GetMaxHealth() * (ability:GetSpecialValueFor("health_as_damage") + caster:GetTalentValue("special_bonus_troy_fury"))) * 0.01
				local knockback_distance = ability:GetSpecialValueFor("knockback_distance")
				local knockback_height = ability:GetSpecialValueFor("knockback_height")
				local knockback_duration = ability:GetSpecialValueFor("knockback_duration")

				-- Play cast sound
				--caster:EmitSound()

				-- Play cast particle
				--

				-- Calculate knockback
				local center = caster:GetAbsOrigin()
				local knockback = {
					center_x = center.x,
					center_y = center.y,
					center_z = center.z,
					knockback_duration = knockback_duration,
					knockback_distance = knockback_distance,
					knockback_height = knockback_height,
					should_stun = 0,
					duration = knockback_duration
				}

				-- Apply effect
				local enemies = FindUnitsInRadius(caster:GetTeamNumber(), center, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				for _, enemy in pairs(enemies) do
					ApplyDamage({victim = enemy, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
					enemy:EmitSound("Hero_Spirit_Breaker.Charge.Impact")
					enemy:RemoveModifierByName("modifier_knockback")
					enemy:AddNewModifier(caster, ability, "modifier_knockback", knockback)
					enemy:AddNewModifier(caster, ability, "modifier_fury_knockback", {duration = knockback_duration})
				end
			end
		end
	end
end