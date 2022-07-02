modifier_generic_silenced_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_generic_silenced_lua:IsDebuff()
	return true
end

function modifier_generic_silenced_lua:IsStunDebuff()
	return false
end

function modifier_generic_silenced_lua:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Modifier State
function modifier_generic_silenced_lua:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics and animations
function modifier_generic_silenced_lua:GetEffectName()
	return "particles/generic_gameplay/generic_silenced.vpcf"
end

function modifier_generic_silenced_lua:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_generic_silenced_lua:DeclareFunctions(  )
	local funcs = {
		--MODIFIER_EVENT_ON_ATTACK_START,
		--MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_MISS_PERCENTAGE
	}

	return funcs
end

function modifier_generic_silenced_lua:GetModifierMiss_Percentage(  )
	if not self:GetCaster():HasTalent("special_bonus_unquie_gust_blind") then return end
	return 50
end