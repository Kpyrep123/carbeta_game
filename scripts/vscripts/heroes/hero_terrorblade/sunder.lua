--[[Author: Noya
	Date: 11.01.2015.
	Swaps the health percentage of caster and target up to a threshold
]]
function Sunder( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local hit_point_minimum_pct = ability:GetLevelSpecialValueFor( "hit_point_minimum_pct", ability:GetLevel() - 1 ) * 0.01
	local caster_maxHealth = caster:GetMaxHealth()
	local target_maxHealth = target:GetMaxHealth()
	local casterHP_percent = caster:GetHealth() / caster_maxHealth
	local targetHP_percent = target:GetHealth() / target_maxHealth


	-- Show the particle caster-> target
	local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf"	
	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, target )

	ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

	-- Show the particle target-> caster
	local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf"	
	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )

	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

end

function Sunder_damage( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local Max_mana = caster:GetMaxMana()
    local now_mana = caster:GetMana()
    local int_damage = ability:GetLevelSpecialValueFor("intellect_damage_pct", (ability:GetLevel() -1)) + caster:GetTalentValue("special_bonus_arkosh_unquie_1")
    

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = (Max_mana - now_mana) * int_damage / 100

    ApplyDamage(damage_table)

end
