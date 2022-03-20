
function CreateAttackWave(origin)
	local caster = self.GetCaster()
	local radius = self:GetSpecialValueFor("radius") 
	local wave_speed = self:GetSpecialValueFor("wave_speed")

	local hits = {}

	local currentRadius = 0
	local interval = 0.05
	local radiusGrowth = wave_speed * interval

	-- Create wave particle 
	-- CP1: Radius
	-- CP2: Wave speed
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_warp_beast/warp_beast_temporal_jump_land_wave.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, GetGroundPosition(caster:GetAbsOrigin(), caster))
	ParticleManager:SetParticleControl(particle, 1, Vector(radius, 0, 0))
	ParticleManager:SetParticleControl(particle, 2, Vector(wave_speed, 0, 0))

	Timers:CreateTimer(interval, function()
		currentRadius = currentRadius + radiusGrowth
		local units = FindUnitsInRadius(caster:GetTeamNumber(), origin, nil, currentRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

		for k, unit in pairs(units) do
			if not hits[unit:entindex()] then
				caster:PerformAttack(unit, true, true, true, true, false, false, true)
				table.insert(hits, unit:entindex(), unit)
			end
		end

		if currentRadius >= radius then
			return nil
		end

		return interval
	end)
end