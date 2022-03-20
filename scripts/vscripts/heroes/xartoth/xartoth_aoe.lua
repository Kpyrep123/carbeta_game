function ExplodeStun(keys)
	local caster = keys.caster
	local ability = caster:FindAbilityByName("xartoth_aoe")
	local damage = ability:GetSpecialValueFor("damage")
	local radius = ability:GetSpecialValueFor("radius")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	if caster:HasModifier("xartoth_test") then
	--nothing lol
	else
	
	if caster:IsAlive() then
		
		local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false )
		
		-- Seek out target
		for k, v in pairs( units ) do
				local damageTable = {
					victim = v,
					attacker = caster,
					damage = damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
					ability = ability, --Optional.
				}

				ApplyDamage(damageTable)
				v:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
		end
		
	end
	ParticleManager:DestroyParticle(ability.particle, false)
	if IsServer() then
		local boom_particle = ParticleManager:CreateParticle("particles/xartothaoeexplosion_particles/xartoth_aoe_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(boom_particle, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(boom_particle, 2, Vector(radius,1,radius))
		StopSoundEvent("Hero_Grimstroke.InkSwell.Cast", caster)
		caster:EmitSound("Xartoth.AoE.Stun")
	end
	caster:SwapAbilities("xartoth_aoe", "xartoth_aoe_activate", true, false)
	end
end

function ExplodeSlow(keys)
	local caster = keys.caster
	local ability = caster:FindAbilityByName("xartoth_aoe")
	local damage = ability:GetSpecialValueFor("damage")
	local radius = ability:GetSpecialValueFor("radius")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	if caster:IsAlive() then
		
		local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false )
		
		-- Seek out target
		for k, v in pairs( units ) do
				local damageTable = {
					victim = v,
					attacker = caster,
					damage = damage * 0.5,
					damage_type = DAMAGE_TYPE_MAGICAL,
					damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
					ability = ability, --Optional.
				}

				ApplyDamage(damageTable)
				ability:ApplyDataDrivenModifier(caster, v, "xartoth_slow_mod", {duration = stun_duration})
		end
		
	end
	ParticleManager:DestroyParticle(ability.particle, false)
	if IsServer() then
		local boom_particle = ParticleManager:CreateParticle("particles/xartothaoeexplosion_particles/xartoth_aoe_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(boom_particle, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(boom_particle, 2, Vector(radius,1,radius))
		StopSoundEvent("Hero_Grimstroke.InkSwell.Cast", caster)
		EmitSoundOn("Hero_Grimstroke.DarkArtistry.Projectile", caster)
	end
	caster:SwapAbilities("xartoth_aoe", "xartoth_aoe_activate", true, false)
	ability:ApplyDataDrivenModifier(caster, caster, "xartoth_test", {})
	caster:RemoveModifierByName("xartoth_aoe_charge")
end

function ChargeStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	EmitSoundOn("Hero_Grimstroke.InkSwell.Cast", caster)
	caster:FindAbilityByName("xartoth_aoe_activate"):StartCooldown(0.5)
	caster:SwapAbilities("xartoth_aoe", "xartoth_aoe_activate", false, true)
	ability.particle = ParticleManager:CreateParticle("particles/xartothaoecharge_particles/xartoth_aoe_charge.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(ability.particle, 0, caster, PATTACH_OVERHEAD_FOLLOW, "follow_overhead", (caster:GetAbsOrigin() + Vector(0,0,200)), true)
	ParticleManager:SetParticleControlEnt(ability.particle, 3, caster, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", caster:GetAbsOrigin(), true)
end