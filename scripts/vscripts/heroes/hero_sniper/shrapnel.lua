
function shrapnel_fire( keys )
		-- variables
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
		local dummyModifierName = "modifier_shrapnel_dummy_datadriven"
		local casterLoc = caster:GetAbsOrigin()
		local radius = ability:GetLevelSpecialValueFor( "radius", ( ability:GetLevel() - 1 ) )
		local dummy_duration = ability:GetLevelSpecialValueFor( "duration", ( ability:GetLevel() - 1 ) ) + 0.1
		local damage_delay = ability:GetLevelSpecialValueFor( "damage_delay", ( ability:GetLevel() - 1 ) ) + 0.1
		local launch_particle_name = "particles/units/heroes/hero_sniper/sniper_shrapnel_launch.vpcf"
		local launch_sound_name = "Hero_Sniper.ShrapnelShoot"
		
		
	-- Create particle at caster
		local fxLaunchIndex = ParticleManager:CreateParticle( launch_particle_name, PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( fxLaunchIndex, 0, casterLoc )
		ParticleManager:SetParticleControl( fxLaunchIndex, 1, Vector( casterLoc.x, casterLoc.y, 800 ) )
		StartSoundEvent( launch_sound_name, caster )
		
		-- Deal damage
		shrapnel_damage( caster, ability, target, damage_delay, dummyModifierName, dummy_duration )
		keys.ability:RefundManaCost()
	end

--[[
	Author: kritth
	Date: 6.1.2015.
	Main: Create dummy to apply damage
]]
function shrapnel_damage( caster, ability, target, damage_delay, dummyModifierName, dummy_duration )
	Timers:CreateTimer( damage_delay, function()
			-- create dummy to do damage and apply debuff modifier
			local dummy = CreateUnitByName( "npc_dummy_unit", target, false, caster, caster, caster:GetTeamNumber() )
			ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
			Timers:CreateTimer( dummy_duration, function()
					dummy:ForceKill( true )
					return nil
				end
			)
			return nil
		end
	)
end
