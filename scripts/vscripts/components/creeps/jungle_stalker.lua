modifier_bleed_lua = class({})


function modifier_bleed_lua:IsHidden()
    return false
end

function modifier_bleed_lua:IsDebuff()
    return true
end

function modifier_bleed_lua:IsPurgable()
    return false
end

function modifier_bleed_lua:DestroyOnExpire()
    return true
end

function modifier_bleed_lua:OnCreated( kv )

    local ability_level = self:GetAbility():GetLevel() - 1
     self.base_damage = ((self:GetAbility():GetLevelSpecialValueFor("bleed_damage", ability_level) * self:GetCaster():GetAttackDamage()) / 100) * self:GetStackCount()
     self:StartIntervalThink(1) 

    if not IsServer() then return end
end

function modifier_bleed_lua:OnRefresh( kv )
    local ability_level = self:GetAbility():GetLevel() - 1
     self.base_damage = ((self:GetAbility():GetLevelSpecialValueFor("bleed_damage", ability_level) * self:GetCaster():GetAttackDamage()) / 100) * self:GetStackCount()
end

function modifier_bleed_lua:OnRemoved()
end

function modifier_bleed_lua:OnDestroy()
end

function modifier_bleed_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }

    return funcs
end

function modifier_bleed_lua:OnAttacked( params )
    if params.target == self:GetParent() then self:IncrementStackCount() end
end

function modifier_bleed_lua:OnIntervalThink( params )
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.base_damage, damage_type = DAMAGE_TYPE_MAGICAL})

    local particle = ParticleManager:CreateParticle("particles/econ/items/pudge/pudge_ti10_immortal/pudge_ti10_immortal_meathook_blood.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_weapon_particles", self:GetParent():GetOrigin(), true)
    ParticleManager:ReleaseParticleIndex(particle)
end