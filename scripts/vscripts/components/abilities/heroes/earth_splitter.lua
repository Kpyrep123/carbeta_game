
-----------------------------
--    Earth Splitter     --
-----------------------------
imba_elder_titan_earth_splitter = class({})
LinkLuaModifier("modifier_imba_earth_splitter", "components/abilities/heroes/hero_elder_titan.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_earth_splitter_scepter", "components/abilities/heroes/hero_elder_titan.lua", LUA_MODIFIER_MOTION_NONE)

function imba_elder_titan_earth_splitter:GetAbilityTextureName()
	return "elder_titan_earth_splitter"
end

function imba_elder_titan_earth_splitter:IsHiddenWhenStolen()
	return false
end

function imba_elder_titan_earth_splitter:IsNetherWardStealable()
	return false
end

function imba_elder_titan_earth_splitter:GetCastRange(location, target)
		return self.BaseClass.GetCastRange(self, location, target)
end

function imba_elder_titan_earth_splitter:GetCooldown(level)
		return self.BaseClass.GetCooldown(self, level)
end

function imba_elder_titan_earth_splitter:OnSpellStart()
    if not IsServer() then return end
    
	-- Ability properties
	local caster = self:GetCaster()
	local caster_position = caster:GetAbsOrigin()
	local target_point = self:GetCursorPosition()
	local playerID = caster:GetPlayerID()
	local scepter = caster:HasScepter()

	-- Ability specials
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")
	local slow_duration = self:GetSpecialValueFor("slow_duration")
	if scepter then
		slow_duration = self:GetSpecialValueFor("slow_duration_scepter")
	end
	local bonus_hp_per_str = self:GetSpecialValueFor("bonus_hp_per_str")
	local effect_delay = self:GetSpecialValueFor("crack_time")
	local crack_width = self:GetSpecialValueFor("crack_width")
	local crack_distance = self:GetSpecialValueFor("crack_distance")

	local crack_damage = (self:GetSpecialValueFor("damage_pct") + self:GetCaster():GetTalentValue("special_bonus_gaoler_bonus_ill")) / 2
	local base_damage = self:GetSpecialValueFor("base_damage")
	local caster_fw = caster:GetForwardVector()
	local crack_ending = caster_position + caster_fw * crack_distance

	-- Play cast sound
	EmitGlobalSound("Hero_ElderTitan.EarthSplitter.Cast")

	-- Add start particle effect
	local particle_start_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_elder_titan/elder_titan_earth_splitter.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle_start_fx, 0, caster_position)
	ParticleManager:SetParticleControl(particle_start_fx, 1, crack_ending)
	ParticleManager:SetParticleControl(particle_start_fx, 3, Vector(0, effect_delay, 0))
	

	-- Destroy trees in the radius
	GridNav:DestroyTreesAroundPoint(target_point, radius, false)

	-- Wait for the effect delay
	Timers:CreateTimer(effect_delay, function()
		EmitGlobalSound("Hero_ElderTitan.EarthSplitter.Destroy")

		local enemies = FindUnitsInLine(caster:GetTeamNumber(), caster_position, crack_ending, nil, crack_width, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags())
		for _, enemy in pairs(enemies) do
			enemy:Interrupt()
			enemy:AddNewModifier(caster, self, "modifier_imba_earth_splitter", {duration = slow_duration * (1 - enemy:GetStatusResistance())})
			if caster:HasScepter() then
				enemy:AddNewModifier(caster, self, "modifier_imba_earth_splitter_scepter", {duration = slow_duration * (1 - enemy:GetStatusResistance())})
			end
			ApplyDamage({victim = enemy, attacker = caster, damage = caster:GetIntellect() * crack_damage * 0.01, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self})
			ApplyDamage({victim = enemy, attacker = caster, damage = caster:GetIntellect() * crack_damage * 0.01, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
			ApplyDamage({victim = enemy, attacker = caster, damage = base_damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
			local closest_point = FindNearestPointFromLine(caster_position, caster_fw, enemy:GetAbsOrigin())
			FindClearSpaceForUnit(enemy, closest_point, false)
		end

		ParticleManager:ReleaseParticleIndex(particle_start_fx)
	end)
end

-- Earth Splitter modifier
modifier_imba_earth_splitter = class({})

function modifier_imba_earth_splitter:IsHidden() return false end
function modifier_imba_earth_splitter:IsPurgable() return true end

function modifier_imba_earth_splitter:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return decFuncs
end

function modifier_imba_earth_splitter:CheckState()
	local state = {
		[MODIFIER_STATE_PASSIVES_DISABLED] = true
	}
	return state
end

function modifier_imba_earth_splitter:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow_pct")
end

-- Earth Splitter Scepter modifier
modifier_imba_earth_splitter_scepter = class({})

function modifier_imba_earth_splitter_scepter:IsHidden() return false end
function modifier_imba_earth_splitter_scepter:IsPurgable() return true end

function modifier_imba_earth_splitter_scepter:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}
	return state
end
