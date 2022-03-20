if IsServer() then
	require('abilities/life_in_arena/utils')
end

function AddModifier(keys)
	local ability = keys.ability
	local target = keys.target
	local caster = keys.caster
	if target:TriggerSpellAbsorb(ability) then
		return 
	end
	
	if target:GetUnitName() == "npc_dota_roshan" then 
		return 
	end
		
	if not caster.count_ill then
		caster.count_ill=0
	end

	local durationTarget
	if target:IsHero() then
		durationTarget = ability:GetSpecialValueFor("duration_hero")
	else
		durationTarget = ability:GetSpecialValueFor("duration_other")
	end
	target:EmitSound("Hero_Pugna.Decrepify")
	ability:ApplyDataDrivenModifier(caster, target, 'modifier_illusionist_mastery_of_illusions', {duration = durationTarget} )
	

	local count_illusion = ability:GetSpecialValueFor("count_illusion") + caster:GetTalentValue("special_bonus_gaoler_bonus_ill")
	local duration = ability:GetSpecialValueFor("life_illusion")
	local outgoingDamage = ability:GetSpecialValueFor("outgoing_damage")
	local incomingDamage = ability:GetSpecialValueFor("incoming_damage")

	local origin = target:GetAbsOrigin()

	for i=1,count_illusion do
		local illus = CreateIllusion(caster,caster,origin,duration,outgoingDamage,incomingDamage)
		illus:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	end
end
