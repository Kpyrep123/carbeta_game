function LevelUpTeleport( keys )
 keys.caster:FindAbilityByName("eldritch_teleport"):SetLevel(1)
end

function PlayDecayAnim( keys )
   keys.caster:StartGesture(ACT_DOTA_UNDYING_DECAY)
end

function PlaySoulRipAnim( keys )
   keys.caster:StartGesture(ACT_DOTA_UNDYING_SOUL_RIP)
end

function PlayTombstoneAnim( keys )
   keys.caster:StartGesture(ACT_DOTA_UNDYING_TOMBSTONE)
end

function UltimateCast( keys )
    local caster = keys.caster
	local target = keys.target
	local point = keys.ability:GetCursorPosition()
	local fall_delay = keys.ability:GetSpecialValueFor("fall_delay")
	local radius = 550
	
	EmitSoundOnLocationWithCaster(point, "DOTA_Item.MeteorHammer.Channel", caster)
	
	AddFOWViewer(caster:GetTeam(), point, radius, fall_delay + 1, false)
	
	local particle1 = ParticleManager:CreateParticle("particles/eldritchendofall_cast_particles/eldritch_endofall_cast.vpcf", PATTACH_CUSTOMORIGIN, nil)
					ParticleManager:SetParticleControl(particle1, 0, point)
					
					Timers:CreateTimer( fall_delay, function()
					
					StopSoundEvent("DOTA_Item.MeteorHammer.Channel", caster)
					
		local x = math.random(-radius,radius)
		local y = math.random(-radius,radius)
		local height = 500
		local heightPoint = Vector(x, y, height)

		EmitSoundOn("DOTA_Item.MeteorHammer.Cast", caster)
		local particle2 = ParticleManager:CreateParticle("particles/eldritchendofall_particle/eldritch_endofall_spell.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(particle2, 0, point+heightPoint)
		ParticleManager:SetParticleControl(particle2, 1, point)
		ParticleManager:SetParticleControl(particle2, 2, Vector(0.5,0,0))
		ParticleManager:SetParticleControl(particle2, 3, point)
		Timers:CreateTimer(0.5, function()
		
		    ParticleManager:DestroyParticle(particle1, true)
			EmitSoundOnLocationWithCaster(point, "DOTA_Item.MeteorHammer.Impact", caster)
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
			for _,enemy in pairs(enemies) do
				keys.ability:ApplyDataDrivenModifier(caster, enemy, "meteor_burn", {})
			end
		end)
		
					return nil
					end
					)
end

function CreatedAbom(keys)
	local target = keys.target
	local origin = target:GetAbsOrigin()
	
	FindClearSpaceForUnit(target, origin, true)
end