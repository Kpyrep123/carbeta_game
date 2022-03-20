function VoidBeam(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if target:TriggerSpellAbsorb(ability) then
		RemoveLinkens(target)
		return
	else 
	local stacks = ability:GetLevelSpecialValueFor( "instances", ability:GetLevel() - 1 )

    local int_damage = ability:GetLevelSpecialValueFor("stack_damage", (ability:GetLevel() -1)) + caster:GetTalentValue("special_bonus_unquie_void_beam_damage")
    local base_damage = ability:GetLevelSpecialValueFor("base_damage", (ability:GetLevel() -1)) 
    local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1)) + caster:GetTalentValue("special_bonus_unquie_void_beam_duration")
    
    if caster:HasModifier("modifier_warpath_datadriven_counter") then

	local modifier = caster:FindModifierByName("modifier_warpath_datadriven_counter")
	local int_caster = modifier:GetStackCount()

    local damage_table = {}
	
    	damage_table.attacker = caster
    	damage_table.damage_type = ability:GetAbilityDamageType()
    	damage_table.ability = ability
    	damage_table.victim = target
	
    	damage_table.damage = int_caster * int_damage + base_damage
	
    	ApplyDamage(damage_table)
    	local stackssb = caster:FindModifierByName("modifier_warpath_datadriven_counter")
	    local x = caster:GetModifierStackCount("modifier_warpath_datadriven_counter", ability)
	    caster:SetModifierStackCount("modifier_warpath_datadriven_counter", ability, x * 0.8)
	else
		local damage_table = {}
	
	    damage_table.attacker = caster
	    damage_table.damage_type = ability:GetAbilityDamageType()
	    damage_table.ability = ability
	    damage_table.victim = target
	
	    damage_table.damage = int_damage + base_damage
	
	    ApplyDamage(damage_table)
	
	end
end
end

function VoidBeam_sec( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1)) + caster:GetTalentValue("special_bonus_unquie_void_beam_duration")
		-- Attaches the particle to the caster
	ability.particle = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(ability.particle, 1, target, PATTACH_POINT_FOLLOW, "attach_origin", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(ability.particle, 2, target, PATTACH_POINT_FOLLOW, "attach_origin", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(ability.particle, 3, target, PATTACH_POINT_FOLLOW, "attach_origin", target:GetAbsOrigin(), true)


	if target:TriggerSpellAbsorb(ability) then
		RemoveLinkens(target)
		return
	else 

		if target:HasModifier("modifier_void_hit") then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_void_mark_stable", {duration = duration *(1 - target:GetStatusResistance())})
			target:RemoveModifierByName("modifier_void_hit")
		else
			ability:ApplyDataDrivenModifier(caster, target, "modifier_void_mark", {duration = duration* (1- target:GetStatusResistance())})
		end
	end
end
