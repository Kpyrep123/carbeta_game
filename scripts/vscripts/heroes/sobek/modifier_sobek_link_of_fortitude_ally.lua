modifier_sobek_link_of_fortitude_ally = class({})

function modifier_sobek_link_of_fortitude_ally:OnCreated(params)
    self.self_damage = self:GetAbility():GetSpecialValueFor("self_damage")
    self.allied_damage = self:GetAbility():GetSpecialValueFor("allied_damage")
    self.tether_distance = self:GetAbility():GetSpecialValueFor("tether_distance")

    -- Start thinking
    self:StartIntervalThink(0.1)

    -- Create particle on self
    self.caster_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sobek/sobek_link_of_fortitude.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(self.caster_particle, 14, Vector(1,1,1))
    ParticleManager:SetParticleControl(self.caster_particle, 15, Vector(255,255,255))
    self.caster_shield_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sobek/sobek_link_of_fortitude_buff.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster())
    self.parent_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sobek/sobek_link_of_fortitude.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.parent_particle, 14, Vector(1,1,1))
    ParticleManager:SetParticleControl(self.parent_particle, 15, Vector(255,255,255))
    self.parent_shield_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sobek/sobek_link_of_fortitude_buff.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())

end

function modifier_sobek_link_of_fortitude_ally:OnDestroy()
    -- Stop thinking
    self:StartIntervalThink(-1)

    -- Remove particles
    ParticleManager:DestroyParticle(self.caster_particle, false)
    ParticleManager:DestroyParticle(self.caster_shield_particle, false)
    ParticleManager:ReleaseParticleIndex(self.caster_particle)
    ParticleManager:ReleaseParticleIndex(self.caster_shield_particle)
    
    ParticleManager:DestroyParticle(self.parent_particle, false)
    ParticleManager:DestroyParticle(self.parent_shield_particle, false)
    ParticleManager:ReleaseParticleIndex(self.parent_particle)
    ParticleManager:ReleaseParticleIndex(self.parent_shield_particle)
end

function modifier_sobek_link_of_fortitude_ally:OnIntervalThink()
    -- Check distance between parent and caster
    local distance = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length()

    -- Set particle CP
    local p = distance/self.tether_distance
    local intensity = 255 * (1 - p*p)
    ParticleManager:SetParticleControl(self.caster_particle, 14, Vector(1 - p, 0, 0))
    ParticleManager:SetParticleControl(self.parent_particle, 14, Vector(1 - p, 0, 0))
    ParticleManager:SetParticleControl(self.caster_particle, 15, Vector(intensity, intensity, intensity))
    ParticleManager:SetParticleControl(self.parent_particle, 15, Vector(intensity,intensity,intensity))

    if IsServer() then
        -- Break link if distance is too big
        if distance > self.tether_distance then
            self:Destroy()
        end
    end
end

function modifier_sobek_link_of_fortitude_ally:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end

function modifier_sobek_link_of_fortitude_ally:GetModifierIncomingDamage_Percentage()
    return -self.allied_damage
end

function modifier_sobek_link_of_fortitude_ally:OnTakeDamage(params)
    -- Only consider damage the parent receives
    if params.unit == self:GetParent() then
        -- Redirect part of the damage to sobek (caster)
        ApplyDamage({
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage = params.original_damage * (self.self_damage / 100),
            victim = self:GetAbility():GetCaster(),
            attacker = params.attacker,
            ability = self:GetAbility(), 
            damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_REFLECTION
        })
    end
end