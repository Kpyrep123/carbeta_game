--[[Author: YOLOSPAGHETTI
	Date: February 5, 2016
	Puts Riki behind the target, if the target is an enemy, applies the bonus damage, 
	and queues up an attack order on the target]]
	if IsServer() then
		require('abilities/life_in_arena/utils')
	end

LinkLuaModifier( "generic_lua_silence", "abilities/overflow/generic_stun.lua", LUA_MODIFIER_MOTION_NONE )

function BlinkStrike( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local bonus_damage = ability:GetLevelSpecialValueFor("bonus_damage", ability_level) + caster:GetTalentValue("special_bonus_unquie_veerah_blink_bonus")
	local victim_angle = target:GetAnglesAsVector()
	local victim_forward_vector = target:GetForwardVector()
	local modifiername = "modifier_generic_silenced_lua"
	-- Angle and positioning variables
	local victim_angle_rad = victim_angle.y*math.pi/180
	local victim_position = target:GetAbsOrigin()
	local duration = 1.0
	local attacker_new = Vector(victim_position.x - 100 * math.cos(victim_angle_rad), victim_position.y - 100 * math.sin(victim_angle_rad), 0)
	
	if caster:HasTalent("special_bonus_unquie_veerah_splash") then 
		local origin = caster:GetAbsOrigin()
		local endPos = target:GetAbsOrigin()
		local enemies = FindUnitsInLine(caster:GetTeam(), origin, endPos, nil, 150, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0)
		for _, enemy in pairs(enemies) do
			caster:PerformAttack(enemy, true, true, true, true, false, false, true)
			ApplyDamage({victim = enemy, attacker = caster, damage = bonus_damage, damage_type = ability:GetAbilityDamageType()})

			if caster:HasTalent("special_bonus_unquie_blink_silence") then 

			enemy:AddNewModifier( caster, nil, "generic_lua_silence", { duration = duration , stacking = 1 } )
		end
		end
	else
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
	
		ApplyDamage({victim = target, attacker = caster, damage = bonus_damage, damage_type = ability:GetAbilityDamageType()})
		caster:PerformAttack(target, true, true, true, true, false, false, true)
		if caster:HasTalent("special_bonus_unquie_blink_silence") then 

			target:AddNewModifier( caster, nil, "generic_lua_silence", { duration = duration , stacking = 1 } )
		end
	end
		
end


	-- Sets Riki behind the victim and facing it
	caster:SetAbsOrigin(attacker_new)
	FindClearSpaceForUnit(caster, attacker_new, true)
	caster:SetForwardVector(victim_forward_vector)
	
	-- If the target is an enemy then apply the bonus damage

	
	-- Order the caster to attack the target
	-- Necessary on jumps to allies as well (does not actually attack), otherwise Riki will turn back to his initial angle
	order = 
	{
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = ability,
		Queue = true
	}

	ExecuteOrderFromTable(order)

end



LinkLuaModifier("modifier_illusion_squal_lua", "heroes/hero_riki/blink_strike.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_outdmg", "heroes/hero_riki/blink_strike.lua", LUA_MODIFIER_MOTION_NONE)

ability_illusion_squal_lua = class({})

function ability_illusion_squal_lua:OnSpellStart()
	local target = self:GetCursorTarget()	
	local caster = self:GetCaster()
	local ability = self
	local ability_level = ability:GetLevel() - 1
	if target:TriggerSpellAbsorb(ability) then
		RemoveLinkens(target)
		return
	end
	target:AddNewModifier(caster, self, "modifier_illusion_squal_lua", {})
end

modifier_illusion_squal_lua = class({})
function modifier_illusion_squal_lua:IsHidden() return true end
function modifier_illusion_squal_lua:IsPurgable() return false end
function modifier_illusion_squal_lua:GetTexture() return end
function modifier_illusion_squal_lua:GetEffectName() return end

function modifier_illusion_squal_lua:OnCreated()
if not IsServer() then return end
self.count = 0
self.count_max = self:GetAbility():GetSpecialValueFor("max_attacks") + self:GetCaster():GetTalentValue("special_bonus_unquie_2_attacks")
self:StartIntervalThink(0.2)
self:OnIntervalThink()
end

function modifier_illusion_squal_lua:OnRefresh()
if not IsServer() then return end
end

function modifier_illusion_squal_lua:OnIntervalThink()
	if self.count >= self.count_max then 
	self:Destroy()
	local outgoingDamage = self:GetAbility():GetSpecialValueFor("outgoingDamage")
	local incomingDamage = self:GetAbility():GetSpecialValueFor("incomingDamage")
	return end

	self.count = self.count + 1
	local rand_distance = math.random(800, 900)
	local origin = self:GetParent():GetAbsOrigin() + RandomVector(rand_distance)
	local illusion = CreateIllusion(self:GetCaster(),self:GetCaster(),origin, 0.7,outgoingDamage,incomingDamage)
	local subab = illusion:FindAbilityByName("blink_strike_datadriven_ills")
	local point = self:GetParent():GetAbsOrigin()
	local dmg = illusion:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_outdmg", {duration = 1})
	dmg:SetStackCount(self:GetAbility():GetSpecialValueFor("outgoingDamage")) + self:GetCaster():GetTalentValue("special_bonus_unquie_sqwal_dmg")
	local forward = (point - origin):Normalized()
		illusion:SetForwardVector(forward)
		illusion:SetControllableByPlayer(0, false)
	local p = ParticleManager:CreateParticle("particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step_dmg_smoke_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, illusion)
	print(self.count)
	if subab then
		subab:SetHidden(false)
		Timers:CreateTimer(0.035, function()
			illusion:CastAbilityOnTarget(self:GetParent(), subab, -1)
		end)
	end
end

function modifier_illusion_squal_lua:DeclareFunctions()
return
	{
		
	}
end

modifier_outdmg = class({})

modifier_outdmg = class({})
function modifier_outdmg:IsHidden() return true end
function modifier_outdmg:IsPurgable() return false end
function modifier_outdmg:GetTexture() return end
function modifier_outdmg:GetEffectName() return end

function modifier_outdmg:OnCreated()
if not IsServer() then return end
self.out = self:GetAbility():GetSpecialValueFor("outgoingDamage")
self.inc = self:GetAbility():GetSpecialValueFor("incomingDamage")
end

function modifier_outdmg:OnRefresh()
if not IsServer() then return end
end

function modifier_outdmg:DeclareFunctions()
return
	{
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
end

function modifier_outdmg:GetModifierDamageOutgoing_Percentage(  )
	return -1 * self:GetStackCount()
end

function modifier_outdmg:GetModifierIncomingDamage_Percentage(  )
	return self.inc
end