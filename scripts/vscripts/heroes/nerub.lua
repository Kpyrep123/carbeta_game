function LocustStun( keys )
   local caster = keys.caster
   local ability = keys.ability
   local target = keys.target
   local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", ability:GetLevel() -1)
   
   if target:HasModifier("nerub_debuff_modifier") then
    ability:ApplyDataDrivenModifier(caster, target, "modifier_stunned", {duration = stun_duration})
   end
end

function ApplyCheckModifier( keys )
        local caster = keys.caster
		local ability = keys.ability
		local target = keys.target
		if target ~= caster and not target:HasModifier("beetle_debug") then
		ability:ApplyDataDrivenModifier(caster, target, "nerub_beetle_check", {duration = 0.1})
		end
end

function ScarabCharge( keys )
   local caster = keys.caster
   local ability = keys.ability
   local max_charges = ability:GetLevelSpecialValueFor("max_charges", ability:GetLevel() -1)
   local charges_modifier = "nerub_beetle_charges"
   
	   ability:ApplyDataDrivenModifier(caster, caster, charges_modifier, {})
	   local stack_count = caster:GetModifierStackCount(charges_modifier, ability)
	   if stack_count < max_charges then
	   stack_count = stack_count + 1
	   caster:SetModifierStackCount(charges_modifier, ability, stack_count)
	   end 
end

function ScarabActive( keys )
	local caster = keys.caster
	local player = caster:GetPlayerID()
	local ability = keys.ability
	local charges_modifier = "nerub_beetle_charges"
	local beetle_duration = ability:GetLevelSpecialValueFor("beetle_duration", ability:GetLevel() -1)
	local spawn_origin = caster:GetAbsOrigin() + RandomVector(200)
	local stack_count = 0
	stack_count = caster:GetModifierStackCount(charges_modifier, ability)
	print(stack_count)
	
	if caster:HasModifier(charges_modifier) and stack_count > 0 then
	--stack_count = stack_count - 1
	--caster:SetModifierStackCount(charges_modifier, ability, stack_count)
	--if stack_count == 0 then
	caster:RemoveModifierByName(charges_modifier)
	--end
	--Here we spawn the beetle :)
	for i=1,stack_count do
	local beetle = CreateUnitByName("npc_dota_nerub_beetle", spawn_origin, true, caster, caster, caster:GetTeamNumber())
	beetle:AddNewModifier(beetle, nil, "modifier_kill", {duration = beetle_duration})
	beetle:AddNewModifier(beetle, nil, "modifier_phased", {duration = 0.1})
	beetle:SetControllableByPlayer(player, true)
	ability:ApplyDataDrivenModifier(beetle, beetle, "beetle_debug", {})
	EmitSoundOn("Hero_NyxAssassin.Burrow.Out", beetle)
	local beetle_part = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_burrowstrike_ground.vpcf", PATTACH_ABSORIGIN_FOLLOW, beetle)
	ParticleManager:SetParticleControlEnt(beetle_part, 1, beetle, PATTACH_POINT_FOLLOW, "attach_origin", beetle:GetAbsOrigin(), true)
	end
	else
	ability:RefundManaCost()
	ability:EndCooldown()
	--debug
	--ability:ApplyDataDrivenModifier(caster, caster, charges_modifier, {})
	--caster:SetModifierStackCount(charges_modifier, ability, 1)
	
	end
end

function BeetleBurrow( keys )
   local caster = keys.caster
   local ability = keys.ability
   
   ability:SetActivated(false)
   caster:SetOriginalModel("models/heroes/nerubian_assassin/mound.vmdl")
   ability:ApplyDataDrivenModifier(caster, caster, "burrow_modifier", {})
end

function UltiStart( keys )
	local caster = keys.caster
	local target = keys.target
	local caster_location = caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local ability = keys.ability

	-- Apply the invlunerability modifier to the caster
	ability:ApplyDataDrivenModifier(caster, caster, "nerub_curse_finish", {duration = duration})
end

function MotionControl( keys )
	local caster = keys.target
	local ability = keys.ability

	-- Move the caster while the distance traveled is less than the original distance upon cast
	if ability.ult_traveled_distance < ability.ult_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.ult_direction * ability.ult_speed)
		ability.ult_traveled_distance = ability.ult_traveled_distance + ability.ult_speed
	else
		-- Remove the motion controller once the distance has been traveled
		caster:InterruptMotionControllers(false)
		ability:ApplyDataDrivenModifier(caster, caster, "nerub_curse_finish", {})
		EmitSoundOn("Hero_DarkWillow.Fear.Target", caster)
	end
end

function CurseFear( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	target:Stop()
	target:Interrupt()
	local direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
	local position = target:GetAbsOrigin() + direction * 500
	
	target:MoveToPosition(position)

	local order =
			{
				UnitIndex = target:entindex(),
				OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
				TargetIndex = target:entindex(),
				Queue = true
			}

			ExecuteOrderFromTable(order)
end