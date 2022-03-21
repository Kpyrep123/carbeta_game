LinkLuaModifier("modifier_temporal_jump", "scripts/vscripts/heroes/warp_beast/warp_beast_temporal_jump.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_temporal_jump_charges", "scripts/vscripts/heroes/warp_beast/warp_beast_temporal_jump.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_temporal_jump_scepter", "scripts/vscripts/heroes/warp_beast/warp_beast_temporal_jump.lua", LUA_MODIFIER_MOTION_NONE)

warp_beast_temporal_jump = class({})

function warp_beast_temporal_jump:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function warp_beast_temporal_jump:GetIntrinsicModifierName()
	return "modifier_temporal_jump_charges"
end

function warp_beast_temporal_jump:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local jumpTime = self:GetSpecialValueFor("jump_time")

	local point = caster:GetCursorPosition()
	local jumpHeight = self:GetSpecialValueFor("jump_height")

	local latchModifier = caster:FindModifierByName("modifier_latch")
	if latchModifier and latchModifier.target then
		latchModifier.target:RemoveModifierByNameAndCaster("modifier_latch_target", caster)
		caster:RemoveModifierByName("modifier_latch")
	end

	-- if caster:IsRooted() then 
	-- 	point = caster:GetAbsOrigin() + caster:GetForwardVector() * 10
	-- 	jumpHeight = 50
	-- end

	local latchAbility = caster:FindAbilityByName("warp_beast_latch")
	self:SetActivated(false)
	latchAbility:SetActivated(false)

	local time = 0
	local interval = 0.03

	local origin = caster:GetAbsOrigin()

	if (point - origin):Length2D() < 0.1 then point = point + RandomVector(1) end

	local forwardVec = (point - origin):Normalized()
	local distance = ((point - origin):Length2D() * interval) / jumpTime


	-- Scepter effect
	if caster:HasScepter() then
		caster:AddNewModifier(caster, self, "modifier_temporal_jump_scepter", {duration = self:GetSpecialValueFor("duration_scepter")})
	end

	--Emit sound
	caster:EmitSound("Hero_Warp_Beast.Temporal_Jump")


	local modifier = self:GetCaster():AddNewModifier(caster, self, "modifier_temporal_jump", {})
	caster:SetModel("models/items/courier/faceless_rex/faceless_rex_flying.vmdl")

	Timers:CreateTimer(time, function()

		time = time + interval

		-- if caster:HasModifier("modifier_knockback") and caster:IsStunned() then
		-- 	-- Re-activates the spell
		-- 	caster:SetModel("models/items/courier/faceless_rex/faceless_rex.vmdl")
		-- 	self:SetActivated(true)
		-- 	latchAbility:SetActivated(true)
		-- 	if modifier then modifier:Destroy() end
		-- 	FindClearSpaceForUnit(caster, point, false)

		-- 	return nil
		-- end

		local percentage = (time / jumpTime) * distance
		local height = ((4 * jumpHeight * distance * percentage) - (4 * jumpHeight * percentage * percentage)) / (distance * distance)

		local horizontalMovement = GetGroundPosition(caster:GetAbsOrigin(), caster) + forwardVec * distance
		-- if caster:IsRooted() then horizontalMovement = GetGroundPosition(caster:GetAbsOrigin(), caster) + forwardVec * 0.1 end

		
		
		caster:SetAbsOrigin(horizontalMovement + Vector(0, 0, height) )

		if time >= jumpTime then
			-- Re-activates the spell
			caster:SetModel("models/items/courier/faceless_rex/faceless_rex.vmdl")
			self:SetActivated(true)
			latchAbility:SetActivated(true)
			if modifier then modifier:Destroy() end
			FindClearSpaceForUnit(caster, point, false)

			if not caster:IsStunned() and not caster:IsDisarmed() then
				-- caster:EmitSound("Hero_Warp_Beast.Temporal_Jump.Impact")
				self:CreateAttackWave(caster:GetAbsOrigin())
			end

			return nil
		end
		return interval
	end)

	
end


function warp_beast_temporal_jump:CreateAttackWave(origin)
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius") + caster:GetTalentValue("special_bonus_unique_warp_beast_jump_radius")
	local wave_speed = self:GetSpecialValueFor("wave_speed")

	local hits = {}

	local currentRadius = 0
	local interval = 0.05
	local radiusGrowth = wave_speed * interval

	if caster:HasTalent("special_bonus_unique_warp_beast_jump_radius") then
		EmitSoundOnLocationWithCaster(origin, "Hero_Warp_Beast.Temporal_Jump.BigImpact", caster)
	else
		EmitSoundOnLocationWithCaster(origin, "Hero_Warp_Beast.Temporal_Jump.Impact", caster)
	end

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
				if not unit:IsHero() then
					ApplyDamage({attacker = caster, victim = unit, damage = self:GetSpecialValueFor("creep_damage"), damage_type = DAMAGE_TYPE_PHYSICAL})
				end
				table.insert(hits, unit:entindex(), unit)
			end
		end

		if currentRadius >= radius then
			return nil
		end

		return interval
	end)
end
------------------------------------------------------------------------------------------------------------------
modifier_temporal_jump = class({})

function modifier_temporal_jump:CheckState()
	local states = {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
	}
	return states
end

function modifier_temporal_jump:GetEffectName()
	return "particles/units/heroes/hero_warp_beast/warp_beast_temporal_jump.vpcf"
end


------------------------------------------------------------------------------------------------------------------
modifier_temporal_jump_scepter = class({})

function modifier_temporal_jump_scepter:IsDebuff() return false end
function modifier_temporal_jump_scepter:IsHidden() return false end
function modifier_temporal_jump_scepter:IsPurgable() return false end

function modifier_temporal_jump_scepter:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
	return funcs
end

function modifier_temporal_jump_scepter:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_scepter")
end