-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
lanaya_cursed_dakra = class({})
LinkLuaModifier( "modifier_cursed_dakra", "lua_abilities/viper_viper_strike_lua/modifier_viper_viper_strike_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function lanaya_cursed_dakra:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function lanaya_cursed_dakra:GetCastRange( vLocation, hTarget )

	return self.BaseClass.GetCastRange( self, vLocation, hTarget )
end

function lanaya_cursed_dakra:GetCooldown( level )

	return self.BaseClass.GetCooldown( self, level )

end

function lanaya_cursed_dakra:GetManaCost( level )
	return self.BaseClass.GetManaCost( self, level )
end

--------------------------------------------------------------------------------
-- Ability Start
function lanaya_cursed_dakra:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- load data
	-- local projectile_name = "particles/units/heroes/hero_viper/viper_viper_strike.vpcf"
	local projectile_name = "particles/econ/items/templar_assassin/templar_assassin_butterfly/templar_assassin_meld_attack_butterfly.vpcf"
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )

	-- Play Effects
	local effect = self:PlayEffects( target )

	-- create projectile
	local info = {
		Target = target,
		Source = caster,
		Ability = self,	
		
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = true,                           -- Optional

		ExtraData = {
			effect = effect,
		}
	}
	ProjectileManager:CreateTrackingProjectile(info)

end
--------------------------------------------------------------------------------
-- Projectile
function lanaya_cursed_dakra:OnProjectileHit_ExtraData( target, location, ExtraData )
	-- stop effects
	self:StopEffects( ExtraData.effect )

	if not target then return end

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then return end

	-- references
	local duration = self:GetSpecialValueFor( "duration" )

	-- add debuff
	target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_cursed_dakra", -- modifier name
		{ duration = duration * (1 - target:GetStatusResistance()) } -- kv
	)

	-- play sound
	local sound_cast = "Hero_TemplarAssassin.Meld.Attack"
	EmitSoundOn( sound_cast, target )
end

--------------------------------------------------------------------------------
function lanaya_cursed_dakra:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/econ/items/lanaya/lanaya_epit_trap/templar_assassin_epit_trap.vpcf"
	local sound_cast = "Hero_TemplarAssassin.Meld"

	-- Get Data
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 6, Vector( projectile_speed, 0, 0 ) )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)

	-- "attach_barb<1/2/3/4>" is unique to viper model, so use something else
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		2,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		3,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		4,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack2",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		5,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack3",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	-- ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, target )

	-- return the particle index
	return effect_cast
end

function lanaya_cursed_dakra:StopEffects( effect_cast )
	ParticleManager:DestroyParticle( effect_cast, false )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end