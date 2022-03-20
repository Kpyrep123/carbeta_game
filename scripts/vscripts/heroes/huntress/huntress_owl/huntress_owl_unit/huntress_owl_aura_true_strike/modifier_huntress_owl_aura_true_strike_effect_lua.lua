modifier_huntress_owl_aura_true_strike_effect_lua = modifier_huntress_owl_aura_true_strike_effect_lua or class({})

--------------------------------------------------------------------------------
function modifier_huntress_owl_aura_true_strike_effect_lua:IsHidden()
    local parent = self:GetParent()
    if parent:IsRangedAttacker() then
        return false
    end
    return true
end

--------------------------------------------------------------------------------
function modifier_huntress_owl_aura_true_strike_effect_lua:IsDebuff()
    return false
end

--------------------------------------------------------------------------------
function modifier_huntress_owl_aura_true_strike_effect_lua:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
function modifier_huntress_owl_aura_true_strike_effect_lua:IsDebuff()
    return false
end

--------------------------------------------------------------------------------
function modifier_huntress_owl_aura_true_strike_effect_lua:CheckState()
    local parent = self:GetParent()
    local state = {
        [MODIFIER_STATE_CANNOT_MISS] = true,
    }
    if parent:IsRangedAttacker() then
        return state
    end
    state = {}
    return state

end

function modifier_huntress_owl_aura_true_strike_effect_lua:GetEffectName()
    return "particles/econ/items/omniknight/omniknight_fall20_immortal/omniknight_fall20_immortal_degen_aura_debuff_sparkle.vpcf"
    -- body
end

function modifier_huntress_owl_aura_true_strike_effect_lua:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
    -- body
end

function modifier_huntress_owl_aura_true_strike_effect_lua:OnCreated()
    local subability = self:GetCaster():FindAbilityByName("huntress_hunting_spirit")
    if self:GetCaster():HasScepter() and self:GetParent():IsRangedAttacker() then 
        self:GetParent():AddNewModifier(self:GetCaster(), subability, "modifier_huntress_hunting_spirit", {})
    end
end

function modifier_huntress_owl_aura_true_strike_effect_lua:OnDestroy()
    if self:GetParent():HasModifier("modifier_huntress_hunting_spirit") then
    self:GetParent():RemoveModifierByName("modifier_huntress_hunting_spirit")
    end
end
--------------------------------------------------------------------------------