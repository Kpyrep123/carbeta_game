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
--------------------------------------------------------------------------------
modifier_fairy_queen_whisk_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_fairy_queen_whisk_debuff:IsHidden()
	return false
end

function modifier_fairy_queen_whisk_debuff:IsDebuff()
	return true
end

function modifier_fairy_queen_whisk_debuff:IsPurgable()
	return true
end

function modifier_fairy_queen_whisk_debuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_fairy_queen_whisk_debuff:OnCreated( kv )
	-- references
	self.amp = self:GetAbility():GetSpecialValueFor( "enemy_amp" ) + self:GetCaster():GetTalentValue("spec_fairy_damage_amp")
end

function modifier_fairy_queen_whisk_debuff:OnRefresh( kv )
	-- references
	self.amp = self:GetAbility():GetSpecialValueFor( "enemy_amp" ) + self:GetCaster():GetTalentValue("spec_fairy_damage_amp")
end

function modifier_fairy_queen_whisk_debuff:OnRemoved()
end

function modifier_fairy_queen_whisk_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_fairy_queen_whisk_debuff:DeclareFunctions()
	local caster = self:GetCaster()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
	return funcs
end
function modifier_fairy_queen_whisk_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
	}
	if self:GetCaster():HasScepter() then
	return state
	else
		return nil
	end
end


function modifier_fairy_queen_whisk_debuff:GetModifierIncomingDamage_Percentage()
	return self.amp
end