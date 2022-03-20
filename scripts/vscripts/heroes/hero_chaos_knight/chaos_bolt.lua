--[[Author: Pizzalol
	Date: 08.04.2015.
	Rolls the dice and then determines the damage and stun duration according to that]]
function ChaosBolt( keys )
	local caster = keys.caster
	local target = keys.target
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local stun_min = ability:GetLevelSpecialValueFor("stun_min", ability_level)
	local stun_max = ability:GetLevelSpecialValueFor("stun_max", ability_level) 
	local damage_min = ability:GetLevelSpecialValueFor("damage_min", ability_level) 
	local damage_max = ability:GetLevelSpecialValueFor("damage_max", ability_level)
	local chaos_bolt_particle = keys.chaos_bolt_particle

	-- Calculate the stun and damage values
	local random = RandomFloat(0, 1)
	local stun = stun_min + (stun_max - stun_min) * random
	local damage = damage_min + (damage_max - damage_min) * (1 - random)

	-- Calculate the number of digits needed for the particle
	local stun_digits = string.len(tostring(math.floor(stun))) + 1
	local damage_digits = string.len(tostring(math.floor(damage))) + 1

	-- Create the stun and damage particle for the spell
	local particle = ParticleManager:CreateParticle(chaos_bolt_particle, PATTACH_OVERHEAD_FOLLOW, target)
	ParticleManager:SetParticleControl(particle, 0, target_location) 

	-- Damage particle
	ParticleManager:SetParticleControl(particle, 1, Vector(9,damage,4)) -- prefix symbol, number, postfix symbol
	ParticleManager:SetParticleControl(particle, 2, Vector(2,damage_digits,0)) -- duration, digits, 0

	-- Stun particle
	ParticleManager:SetParticleControl(particle, 3, Vector(8,stun,0)) -- prefix symbol, number, postfix symbol
	ParticleManager:SetParticleControl(particle, 4, Vector(2,stun_digits,0)) -- duration, digits, 0
	ParticleManager:ReleaseParticleIndex(particle)

	-- Apply the stun duration
	target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun})

	-- Initialize the damage table and deal the damage
	local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = damage

	ApplyDamage(damage_table)
end


function Attack( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster:PassivesDisabled() then return end
	local maxStack = ability:GetLevelSpecialValueFor("max_stacks", (ability:GetLevel() - 1))
	local modifierCount = caster:GetModifierCount()
	local currentStack = 0
	local modifierBuffName = "modifier_attack_buff"
	local modifierStackName = "modifier_attack"
	local modifierName

	-- Always remove the stack modifier
	caster:RemoveModifierByName(modifierStackName) 

	-- Counts the current stacks
	for i = 0, modifierCount do
		modifierName = caster:GetModifierNameByIndex(i)

		if modifierName == modifierBuffName then
			currentStack = currentStack + 1
		end
	end

	-- Remove all the old buff modifiers
	for i = 0, currentStack do
		print("Removing modifiers")
		caster:RemoveModifierByName(modifierBuffName)
	end

	-- Always apply the stack modifier 
	ability:ApplyDataDrivenModifier(caster, caster, modifierStackName, {})

	-- Reapply the maximum number of stacks
	if currentStack >= maxStack then
		caster:SetModifierStackCount(modifierStackName, ability, maxStack)

		-- Apply the new refreshed stack
		for i = 1, maxStack do
			ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
		end
	else
		-- Increase the number of stacks
		currentStack = currentStack + 1

		caster:SetModifierStackCount(modifierStackName, ability, currentStack)

		-- Apply the new increased stack
		for i = 1, currentStack do
			ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
		end
	end
end

function Cast( params )
	local caster = params.caster
	local ability = params.ability
	if caster:PassivesDisabled() then return end
	local maxStack = ability:GetLevelSpecialValueFor("max_stacks", (ability:GetLevel() - 1))
	if params.ability:IsItem() or params.ability:IsToggle() then return end
	local modifierCount = caster:GetModifierCount()
	local currentStack = 0
	local modifierBuffName = "modifier_ability_buff"
	local modifierStackName = "modifier_ability"
	local modifierName

	-- Always remove the stack modifier
	caster:RemoveModifierByName(modifierStackName) 
	
	-- Counts the current stacks
	for i = 0, modifierCount do
		modifierName = caster:GetModifierNameByIndex(i)

		if modifierName == modifierBuffName then
			currentStack = currentStack + 1
		end
	end

	-- Remove all the old buff modifiers
	for i = 0, currentStack do
		print("Removing modifiers")
		caster:RemoveModifierByName(modifierBuffName)
	end

	-- Always apply the stack modifier 
	ability:ApplyDataDrivenModifier(caster, caster, modifierStackName, {})

	-- Reapply the maximum number of stacks
	if currentStack >= maxStack then
		caster:SetModifierStackCount(modifierStackName, ability, maxStack)

		-- Apply the new refreshed stack
		for i = 1, maxStack do
			ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
		end
	else
		-- Increase the number of stacks
		currentStack = currentStack + 1

		caster:SetModifierStackCount(modifierStackName, ability, currentStack)

		-- Apply the new increased stack
		for i = 1, currentStack do
			ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
		end
	end
end

function Attacked( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster:PassivesDisabled() then return end
	local maxStack = ability:GetLevelSpecialValueFor("max_stacks", (ability:GetLevel() - 1))
	local modifierCount = caster:GetModifierCount()
	local currentStack = 0
	local modifierBuffName = "modifier_attacked_buff"
	local modifierStackName = "modifier_attacked"
	local modifierName

	-- Always remove the stack modifier
	caster:RemoveModifierByName(modifierStackName) 

	-- Counts the current stacks
	for i = 0, modifierCount do
		modifierName = caster:GetModifierNameByIndex(i)

		if modifierName == modifierBuffName then
			currentStack = currentStack + 1
		end
	end

	-- Remove all the old buff modifiers
	for i = 0, currentStack do
		print("Removing modifiers")
		caster:RemoveModifierByName(modifierBuffName)
	end

	-- Always apply the stack modifier 
	ability:ApplyDataDrivenModifier(caster, caster, modifierStackName, {})

	-- Reapply the maximum number of stacks
	if currentStack >= maxStack then
		caster:SetModifierStackCount(modifierStackName, ability, maxStack)

		-- Apply the new refreshed stack
		for i = 1, maxStack do
			ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
		end
	else
		-- Increase the number of stacks
		currentStack = currentStack + 1

		caster:SetModifierStackCount(modifierStackName, ability, currentStack)

		-- Apply the new increased stack
		for i = 1, currentStack do
			ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
		end
	end
end