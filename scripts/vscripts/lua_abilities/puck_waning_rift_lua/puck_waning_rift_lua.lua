lanaya_sparks_lua = class({})
LinkLuaModifier( "modifier_generic_silenced_lua", "lua_abilities/generic/modifier_generic_silenced_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_angel_arena_archmage_anomaly_thinker", "abilities/angel_arena_reborn/angel_arena_archmage_anomaly.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_archmage_anomaly", "abilities/angel_arena_reborn/angel_arena_archmage_anomaly.lua", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------
-- Ability Start
function lanaya_sparks_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local radius = self:GetSpecialValueFor("radius") + self:GetCaster():GetTalentValue("special_bonus_unquie_lanaya_sparks_radius")
	local duration = self:GetSpecialValueFor("duration")
	local damage = self:GetSpecialValueFor("damage")

	-- logic
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	-- precache damage
	local damageTable = {
		-- victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, --Optional.
		damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
	}
	for _,enemy in pairs(enemies) do
		-- damage
		damageTable.victim = enemy
		ApplyDamage(damageTable)

		-- silence
	end
	self.duration = self:GetSpecialValueFor("duration")
	local dummy = CreateUnitByName( "dummy_unit", self:GetCaster():GetAbsOrigin(), false, nil, nil, self:GetCaster():GetTeamNumber() )
	dummy:AddNewModifier(self:GetCaster(), self, "modifier_angel_arena_archmage_anomaly_thinker", {duration = duration})
	dummy:AddNewModifier(self:GetCaster(), nil, "modifier_phased", {duration = duration})
	dummy:AddNewModifier(self:GetCaster(), nil, "modifier_invulnerable", {duration = duration})
	self:PlayEffects( radius )
end

function lanaya_sparks_lua:PlayEffects( radius )
	local particle_cast = "particles/units/heroes/hero_puck/puck_waning_rift.vpcf"
	local sound_cast = "Hero_Puck.Waning_Rift"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), sound_cast, self:GetCaster() )
end