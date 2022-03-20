require('lib/physics')
require('lib/util_dusk')
require('lib/timers')
azura_gaze_of_exile = class({})
LinkLuaModifier( "modifier_azura_gaze_of_exile", "custom_abilities/azura_gaze_of_exile/modifier_azura_gaze_of_exile", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_azura_gaze_of_exile_buff", "custom_abilities/azura_gaze_of_exile/modifier_azura_gaze_of_exile_buff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_azura_gaze_of_exile_debuff", "custom_abilities/azura_gaze_of_exile/modifier_azura_gaze_of_exile_debuff", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function azura_gaze_of_exile:OnSpellStart()
	-- unit identifier
	caster = self:GetCaster()
	target = self:GetCursorTarget()
	point = self:GetCursorPosition()
	aoe = self:GetSpecialValueFor("radius") + caster:GetTalentValue("special_bonus_unquie_gaze_radius")
	local damage = self:GetSpecialValueFor("damage") + caster:GetTalentValue("special_bonus_unquie_gaze_damage")
	local dummy = FastDummy(point, caster:GetTeam(), 2, 0)		
	local damage = {
					attacker = self:GetCaster(),
					damage = damage,
					damage_type = self:GetAbilityDamageType(),
					ability = self
					}
	local damage_creep = {
					attacker = self:GetCaster(),
					damage = damage,
					damage_type = self:GetAbilityDamageType(),
					ability = self
					}
	local target_loc    =   self:GetCursorPosition()
	AddFOWViewer(caster:GetTeamNumber(), point, 500, 1, false)
	caster:EmitSound("Ability.Starfall")
	-- load data
	local duration_tooltip = self:GetSpecialValueFor("duration_tooltip") + caster:GetTalentValue("special_bonus_unique_azura_2")
Timers:CreateTimer(0.23, function()
	local particle_cast = "particles/units/heroes/hero_sniper/sniper_shrapnel_launch.vpcf"
	local sound_cast = "Hero_Sniper.ShrapnelShoot"

	-- Get Data
	local height = 2000

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		self:GetCaster():GetOrigin(), -- unknown
		false -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, point + Vector( 0, 0, height ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end)

	




	Timers:CreateTimer(1.3, function()
		dummy:EmitSound("Ability.StarfallImpact")
		local particle_fx = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_cowlofice.vpcf", PATTACH_ABSORIGIN, caster)
							ParticleManager:SetParticleControl(particle_fx, 0, target_loc)
							ParticleManager:SetParticleControl(particle_fx, 1, Vector(self:GetSpecialValueFor("radius"), 1, 1))
							ParticleManager:ReleaseParticleIndex(particle_fx)
		local enemies = FindUnitsInRadius( caster:GetTeamNumber(), target_loc, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
				
					damage.victim = enemy
					if enemy:IsRealHero() then
					ApplyDamage( damage )
				else
					ApplyDamage( damage )
					if self:GetCaster():HasTalent("special_bonus_unquie_azura_creep_damage") then
					ApplyDamage( damage )
					ApplyDamage( damage )
				end
				end
				if enemy:IsRealHero() then
						enemy:AddNewModifier(
						caster, -- player source
						self, -- ability source
						"modifier_azura_gaze_of_exile", -- modifier name
						{ duration = duration_tooltip } -- kv
					)
						self:PlayEffects( enemy )

					end
				end
			end
		end
	end)
	Timers:CreateTimer(1.3, function()
		dummy:EmitSound("Ability.StarfallImpact")
	end)
	Timers:CreateTimer(1.4, function()
		dummy:EmitSound("Ability.StarfallImpact")
	end)
	Timers:CreateTimer(1.5, function()
		dummy:EmitSound("Ability.StarfallImpact")
	end)
	Timers:CreateTimer(1.6, function()
		dummy:EmitSound("Ability.StarfallImpact")
	end)
	Timers:CreateTimer(1.7, function()
		dummy:EmitSound("Ability.StarfallImpact")
	end)
	Timers:CreateTimer(1.8, function()
		dummy:EmitSound("Ability.StarfallImpact")
	end)
	Timers:CreateTimer(1.9, function()
		dummy:EmitSound("Ability.StarfallImpact")
	end)

	-- Add modifier

Timers:CreateTimer(1, function()
		local particle_x = ParticleManager:CreateParticle("particles/econ/items/mirana/mirana_persona/mirana_starstorm_arrow_group_persist.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_x, 0, target_loc)
	ParticleManager:SetParticleControl(particle_x, 1, Vector(self:GetSpecialValueFor("radius"), 1, 1))
	ParticleManager:ReleaseParticleIndex(particle_x)
	-- play effects

	local particle = ParticleManager:CreateParticle("particles/econ/items/mirana/mirana_persona/mirana_starstorm_moonray_arrows.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, target_loc)
	ParticleManager:SetParticleControl(particle, 1, Vector(self:GetSpecialValueFor("radius"), 1, 1))
	ParticleManager:ReleaseParticleIndex(particle)



		local particle = ParticleManager:CreateParticle("particles/econ/items/mirana/mirana_persona/mirana_starstorm_moonray_arrows.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, target_loc)
	ParticleManager:SetParticleControl(particle, 1, Vector(self:GetSpecialValueFor("radius"), 1, 1))
	ParticleManager:ReleaseParticleIndex(particle)
end)


end

--------------------------------------------------------------------------------
function azura_gaze_of_exile:PlayEffects( target )
	-- get resources
	local sound_target = "Hero_Terrorblade.Sunder.Target"

	-- play effects
	-- local nFXIndex = ParticleManager:CreateParticle( particle_target, PATTACH_WORLDORIGIN, nil )
	-- ParticleManager:SetParticleControl( nFXIndex, 0, target:GetOrigin() )
	-- ParticleManager:SetParticleControl( nFXIndex, 1, target:GetOrigin() )
	-- ParticleManager:ReleaseParticleIndex( nFXIndex )

	-- play sounds
	-- EmitSoundOnLocationWithCaster( vTargetPosition, sound_location, self:GetCaster() )
	EmitSoundOn( sound_target, target )
end