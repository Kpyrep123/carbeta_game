sobek_absorption = class({})


function sobek_absorption:GetCooldown( level )
	local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_sobek_4")
	if talent and talent:GetLevel() > 0 then
		return self:GetSpecialValueFor( "cd" )
	end

	return self.BaseClass.GetCooldown( self, level )
end


function sobek_absorption:OnSpellStart()
	local caster = self:GetCaster()
	local remaining_duration = self:GetSpecialValueFor("duration") + 1
	local effect_radius = self:GetSpecialValueFor("effect_radius")
	local base_damage = self:GetSpecialValueFor("base_damage")
	local tick_damage = caster:GetMaxHealth() * self:GetSpecialValueFor("damage_pct") * 0.01

	-- Emit sound
	EmitGlobalSound("Hero_Koh.Absorption")

	-- Create particle
	local aoe_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sobek/sobek_absorption_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(aoe_particle, 2, caster, 1, "attach_hitloc", caster:GetAbsOrigin(), false)
	ParticleManager:SetParticleControl(aoe_particle, 3, Vector(effect_radius, 0, 0))

	Timers:CreateTimer(0, function()

		-- Calculate damage
		local tick_damage = caster:GetMaxHealth() * self:GetSpecialValueFor("damage_pct") * 0.01
		local enemies = {}
		if caster:HasScepter() then
			enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, effect_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			if #enemies <= 0 then
				enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, effect_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			end
		else
			enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, effect_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		end

		-- Apply damage and effects
		if #enemies > 0 then
			local damage = tick_damage / #enemies
			for _, enemy in pairs(enemies) do
				ApplyDamage({victim = enemy, attacker = caster, damage = damage + base_damage, damage_type = DAMAGE_TYPE_MAGICAL})

				if enemy:IsHero() then
					local drain_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sobek/sobek_absorption_base.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
					ParticleManager:SetParticleControlEnt(drain_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack2", Vector(), true)
					ParticleManager:ReleaseParticleIndex(drain_particle)
				else
					local drain_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sobek/sobek_absorption_creep.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
					ParticleManager:SetParticleControlEnt(drain_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack2", Vector(), true)
					ParticleManager:ReleaseParticleIndex(drain_particle)
				end

				enemy:EmitSound("Hero_Koh.Absorption.Tick")
			end
		end
		
		-- End effect if the duration has elapsed
		remaining_duration = remaining_duration - 1
		if remaining_duration > 0 then
			return 1
		else
			ParticleManager:DestroyParticle(aoe_particle, false)
			ParticleManager:ReleaseParticleIndex(aoe_particle)
		end
	end)
end