--[[
	Author: kritth
	Date: 10.01.2015.
	Burn mana and damage enemies with the same amount
]]
function Redesign( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local max_mana = target:GetMaxMana()
	local max_health = target:GetMaxHealth()
	local current_mana = target:GetMana()
	local current_health = target:GetHealth()
	local this_ability = keys.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local minimum = this_ability:GetLevelSpecialValueFor("minimum_percent", this_ability:GetLevel() -1) * 0.01
	
	--local multiplier = keys.ability:GetLevelSpecialValueFor( "float_multiplier", keys.ability:GetLevel() - 1 )
	--local number_particle_name = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn_msg.vpcf"
	local burn_particle_name = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf"
	--local damageType = keys.ability:GetAbilityDamageType()
	local mana_percent = ( current_mana / max_mana )
	local health_percent = ( current_health / max_health )
	
	if mana_percent < minimum then
	mana_percent = minimum
	end
	if health_percent < minimum then
	health_percent = minimum
	end
	
	local new_health = ( max_health * mana_percent )
	local new_mana = ( max_mana * health_percent )
	
	-- Calculation
	--local mana_to_burn = keys.ability:GetLevelSpecialValueFor( "mana_burn", keys.ability:GetLevel() - 1 )
	--local life_time = 2.0
	--local digits = string.len( math.floor( mana_to_burn ) ) + 1
	
	-- Fail check
	--if target:IsMagicImmune() then
		--mana_to_burn = 0
	--end
	--if new_health > 1 then
	-- Apply effect of ability
	target:SetMana( new_mana )
	target:SetHealth( new_health )
	--else
	--target:Kill( this_ability , caster )
	--end
	
	-- Show VFX
	--local numberIndex = ParticleManager:CreateParticle( number_particle_name, PATTACH_OVERHEAD_FOLLOW, target )
	--ParticleManager:SetParticleControl( numberIndex, 1, Vector( 1, mana_to_burn, 0 ) )
    --ParticleManager:SetParticleControl( numberIndex, 2, Vector( life_time, digits, 0 ) )
	--local burnIndex = ParticleManager:CreateParticle( burn_particle_name, PATTACH_ABSORIGIN, target )
	
	-- Create timer to properly destroy particles
	--Timers:CreateTimer( life_time, function()
			--ParticleManager:DestroyParticle( numberIndex, false )
			--ParticleManager:DestroyParticle( burnIndex, false)
			--return nil
		--end
	--)
end