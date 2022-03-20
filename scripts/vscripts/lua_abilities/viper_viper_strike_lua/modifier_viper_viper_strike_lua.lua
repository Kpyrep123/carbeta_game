-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
LinkLuaModifier("modifier_cursed_dakra_think", "lua_abilities/viper_viper_strike_lua/modifier_viper_viper_strike_lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
modifier_cursed_dakra = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_cursed_dakra:IsHidden()
	return false
end

function modifier_cursed_dakra:IsDebuff()
	return true
end

function modifier_cursed_dakra:IsStunDebuff()
	return false
end

function modifier_cursed_dakra:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_cursed_dakra:OnCreated( kv )
	-- references
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.start_time = GameRules:GetGameTime()
	self.duration = kv.duration * (1 - self:GetParent():GetStatusResistance())
	self.mana_multiplier = self:GetAbility():GetSpecialValueFor("mana_multiplier") + self:GetCaster():GetTalentValue("special_bonus_unquie_dackra_mult")
	if not IsServer() then return end
	-- precache damage
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(), --Optional.
	}


	-- ApplyDamage(damageTable)

	-- Start interval
	self:StartIntervalThink( 1 )
	self:OnIntervalThink()
end

function modifier_cursed_dakra:OnRefresh( kv )
	-- references
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.start_time = GameRules:GetGameTime()
	self.duration = kv.duration * (1 - self:GetParent():GetStatusResistance())
	self.mana_multiplier = self:GetAbility():GetSpecialValueFor("mana_multiplier") + self:GetCaster():GetTalentValue("special_bonus_unquie_dackra_mult")
	if not IsServer() then return end
	-- update damage
	self.damageTable.damage = damage
	-- restart interval tick
	self:StartIntervalThink( 1 )
	self:OnIntervalThink()
end

function modifier_cursed_dakra:OnRemoved()
end

function modifier_cursed_dakra:OnDestroy()
end

function modifier_cursed_dakra:SetAllowFriendlyFire()
	return true
	-- body
end

function modifier_cursed_dakra:OnSpentMana( params )
	if not IsServer() then return end
	if params.unit~=self:GetParent() then return end
	if params.ability:IsItem() then return end
	local ability_cost	= 	params.cost
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_cursed_dakra_think", {duration = 2.0 * (1 - self:GetParent():GetStatusResistance())})

	ApplyDamage({attacker = self:GetCaster(),
			victim = self:GetParent(),
			ability = self:GetAbility(),
			damage = ability_cost * self.mana_multiplier,
			damage_type = DAMAGE_TYPE_MAGICAL})
	local bonus_dur = self:GetRemainingTime() + 2
	self:SetDuration(bonus_dur, true)
	local particle = ParticleManager:CreateParticle("models/veng/particles/arena/items_fx/book_of_the_guardian_2_active_intial_splash.vpcf", PATTACH_ABSORIGIN, self:GetParent())
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_cursed_dakra:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_SPENT_MANA,
	}

	return funcs
end


--------------------------------------------------------------------------------
-- Interval Effects
function modifier_cursed_dakra:OnIntervalThink()
	ApplyDamage( self.damageTable )
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_cursed_dakra:GetEffectName()
	return "particles/econ/items/queen_of_pain/qop_ti8_immortal/queen_ti8_shadow_strike_debuff.vpcf"
end

function modifier_cursed_dakra:GetEffectAttachType()
	return PATTACH_CUSTOMORIGIN
end

function modifier_cursed_dakra:GetStatusEffectName()
	return "particles/status_fx/status_effect_phase_shift.vpcf"
end

function modifier_cursed_dakra:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end







modifier_cursed_dakra_think = class({})



function modifier_cursed_dakra_think:IsHidden()
	return false
end

function modifier_cursed_dakra_think:IsDebuff()
	return true
end

function modifier_cursed_dakra_think:IsStunDebuff()
	return false
end

function modifier_cursed_dakra_think:IsPurgable()
	return true
end

function modifier_cursed_dakra_think:OnCreated( kv )
self.slow = -1 * self:GetAbility():GetSpecialValueFor( "slow" )
end

function modifier_cursed_dakra_think:OnRefresh( kv )
	self:OnCreated()
	-- body
end
function modifier_cursed_dakra_think:DeclareFunctions()
	-- body
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end
function modifier_cursed_dakra_think:CheckState()
	state = {
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_DISARMED] = true
	}
	-- body
	return state
end

function modifier_cursed_dakra_think:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_cursed_dakra_think:GetEffectName()
	return "particles/econ/items/death_prophet/death_prophet_ti9/death_prophet_silence_custom_ti9_overhead_model.vpcf"
end

function modifier_cursed_dakra_think:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end