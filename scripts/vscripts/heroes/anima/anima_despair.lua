function DespairDamage(keys)
	if IsServer() then
		local caster = keys.caster
		local ability = keys.ability
		local target = keys.target
		local interval = ability:GetSpecialValueFor("interval")
		local damage = ability:GetSpecialValueFor("health_decay")
		local max_hp = target:GetMaxHealth()
		local damage_dealt = max_hp * damage * 0.01
		
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage_dealt * interval,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_HPLOSS, --Optional.
			ability = ability, --Optional.
		}

		ApplyDamage(damageTable)
	end
end

function SpawnParticle(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")
	ability.point = ability:GetCursorPosition()
	if ability.particle then
		ParticleManager:DestroyParticle(ability.particle, false)
	end
	if ability.thinker then
		if not ability.thinker:IsNull() then
			ability.thinker:ForceKill(false)
		end
	end
	
	ability.particle = ParticleManager:CreateParticle("particles/animafieldofdespair_particles/anima_field_of_despair.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(ability.particle, 0, ability.point)
	ParticleManager:SetParticleControl(ability.particle, 1, Vector(radius, radius, radius))
	ability.thinker = CreateUnitByName( "shadowdance_dummy", ability.point, false, caster, caster, caster:GetTeamNumber() )
	ability.thinker:AddNewModifier(caster, ability, "modifier_phased", {})
	ability:ApplyDataDrivenModifier(caster, ability.thinker, "dummy_invulnerability3", {})
	ability:ApplyDataDrivenModifier(caster, ability.thinker, "anima_despair_thinker", {})
end

function EndParticle(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")
	ParticleManager:DestroyParticle(ability.particle, false)
	ability.thinker:ForceKill(false)
end