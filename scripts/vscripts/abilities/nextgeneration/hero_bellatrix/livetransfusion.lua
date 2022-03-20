

function DamageInterval (keys)
	local caster = keys.caster
	local target = keys.target
	
	if target:HasModifier("modifier_roshan_bash") then return end

	local ability = keys.ability
	local target_max_hp = target:GetMaxHealth() /100
	local effect_damage = ability:GetLevelSpecialValueFor("PercentDamage", ability:GetLevel() - 1 )
	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = DAMAGE_TYPE_PURE
	damage_table.ability = ability
	damage_table.damage = target_max_hp * effect_damage * 0.1
	damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS -- Doesnt trigger abilities and items that get disabled by damage

	ApplyDamage(damage_table)

	if caster:HasScepter() then
		caster:Heal(damage_table.damage, ability)
	end
end


function LiveTransfusion( keys )
	
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability
	local casterLoc = caster:GetAbsOrigin()
	local modifierName = "modifier_live_transfusion_stack_counter_datadriven"

	local range = ability:GetLevelSpecialValueFor( "range", ( ability:GetLevel() - 1 ) )
	local radius = ability:GetLevelSpecialValueFor( "radius", ( ability:GetLevel() - 1 ) )

	local ability_level = ability:GetLevel() - 1
	local target = keys.target_points[ 1 ]
	local direction = caster:GetForwardVector()
	local speed = (ability:GetLevelSpecialValueFor("transfusion_speed", ability:GetLevel() - 1 ) / 33)
	local projectilespeed = ability:GetLevelSpecialValueFor("transfusion_speed", ability:GetLevel() - 1 )
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability:GetLevel() - 1 )
	local hp_per_distance = ability:GetLevelSpecialValueFor("hp_cost", ability:GetLevel() - 1 )
	local damage_radius = ability:GetLevelSpecialValueFor("effect_radius", ability:GetLevel() - 1 )
	local duration = ability:GetDuration()
	if caster:HasScepter() then
		local effect_radius =  ability:GetLevelSpecialValueFor("effect_radius", ability:GetLevel() - 1 )
	else
		local effect_radius = ability:GetLevelSpecialValueFor("effect_radius_scepter", ability:GetLevel() - 1 )
	end
	local max_range = ability:GetLevelSpecialValueFor("transfusion_range", ability:GetLevel() - 1 )



	distance = (casterLoc - target):Length()
	traveled = 0
	travel_counter = 0

	projectiledistance = distance
	
	local projectileTable =
		{
		EffectName = "particles/bellatrix/bellatrix_live_transfusion.vpcf",
		Ability = ability,
		vSpawnOrigin = caster:GetAbsOrigin(),
		vVelocity = projectilespeed * direction,
		fDistance = projectiledistance,
		fStartRadius = damage_radius,
		fEndRadius = damage_radius,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = true,
		bProvidesVision = true,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		iVisionRadius = vision_radius,
		iVisionTeamNumber = caster:GetTeamNumber()
		}
	local projectileID = ProjectileManager:CreateLinearProjectile( projectileTable )
	local i = 1

	ProjectileManager:ProjectileDodge(caster)
	ability:ApplyDataDrivenModifier(caster, caster, "Blood_Visual", {})
	caster:AddNoDraw()
	Timers:CreateTimer(function()
		if traveled < distance then
			traveled = traveled + speed
			travel_counter = travel_counter + speed
			caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * speed)

			while travel_counter > 100 do
				travel_counter = travel_counter - 100

				local damage_table = {}

					damage_table.attacker = caster
					damage_table.victim = caster
					damage_table.ability = ability
					damage_table.damage = hp_per_distance
					damage_table.damage_type = DAMAGE_TYPE_PURE
										
				ApplyDamage(damage_table)
			end

			i = i + 1
			if i == 3 then
				if caster:HasScepter() then
					ability:ApplyDataDrivenThinker(caster, caster:GetAbsOrigin(), "modifier_bellatrix_thinker_buff_aura_scepter", {duration = duration})
					ability:ApplyDataDrivenThinker(caster, caster:GetAbsOrigin(), "modifier_bellatrix_thinker_debuff_aura_scepter", {duration = duration})
				else
					ability:ApplyDataDrivenThinker(caster, caster:GetAbsOrigin(), "modifier_bellatrix_thinker_buff_aura", {duration = duration})
					ability:ApplyDataDrivenThinker(caster, caster:GetAbsOrigin(), "modifier_bellatrix_thinker_debuff_aura", {duration = duration})
				end		
				i = 1
			end
			return 0.03
		else
			caster:RemoveModifierByName("Blood_Visual")
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), false)
			caster:RemoveNoDraw()
			return nil
		end
	end)
end

function Healup(keys)
	local caster = keys.caster
	local target = keys.attacker
	local ability = keys.ability
	local damagedone = keys.DamageDone
	local healpercent = ability:GetSpecialValueFor("impact_heal") / 100

	if target:IsHero() then
		caster:Heal(damagedone * healpercent, caster)
	end
end