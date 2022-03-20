modifier_parasight_catalytic_spore = class({})

function modifier_parasight_catalytic_spore:OnCreated(params)
    local parent = self:GetParent()
    if IsServer() then
        self.particle = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_parasight/parasight_catalytic_spore_base.vpcf", PATTACH_POINT_FOLLOW, parent, self:GetCaster():GetTeamNumber())
        parent:EmitSound("Hero_Parasight.Catalytic_Spore")
    end

    self.max_growth_duration = params.max_growth_duration
    self.min_stun = params.min_stun
    self.max_stun = params.max_stun
    self.radius = params.radius

    -- Start thinking
    if IsServer() then
        self:StartIntervalThink(0)
    end
end

function modifier_parasight_catalytic_spore:OnDestroy()
    -- Remove particle
    if IsServer() then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end
end

function modifier_parasight_catalytic_spore:OnIntervalThink()
    local percentage = math.floor(100 * self:GetElapsedTime() / self.max_growth_duration)
    self:SetStackCount(percentage)

    if self:GetElapsedTime() >= self.max_growth_duration then
        -- Stop thinking
        self:StartIntervalThink(-1)
        -- Set max stack count
        self:SetStackCount(100)
    end
end

-- Combust and apply stun
function modifier_parasight_catalytic_spore:Combust()
    local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = caster:FindAbilityByName("parasight_catalytic_spore")

    -- if not ability then return end

    -- Play particle
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_parasight/parasight_catalytic_spore_combust_base.vpcf", PATTACH_CUSTOMORIGIN, parent)
    ParticleManager:SetParticleControlEnt(particle, 3, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(particle)

    -- Play sound
    parent:EmitSound("Hero_Parasight.Catalytic_Spore.Combust")

    -- Calculate stun duration
    local percentage = self:GetStackCount()/100
    local stun_duration = self.min_stun + percentage * (self.max_stun - self.min_stun)

    if percentage == 1 and ability then
        -- If completely charged apply AOE spore
        local units = FindUnitsInRadius(caster:GetTeam(), parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

        for _, unit in pairs(units) do
            unit:AddNewModifier(caster, ability, 'modifier_parasight_catalytic_spore', {
                max_growth_duration = ability:GetSpecialValueFor('max_growth_time'),
                min_stun = ability:GetSpecialValueFor('min_stun'),
                max_stun = ability:GetSpecialValueFor('max_stun'),
                radius = ability:GetSpecialValueFor('radius')
            })
            parent:EmitSound("Hero_Parasight.Catalytic_Spore.AOE")
            --unit:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
        end
    end
    
    if parent:GetTeamNumber() ~= caster:GetTeamNumber() and not parent:IsBuilding() then
        parent:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
    end

    -- Remove modifier
    self:StartIntervalThink(-1)
    self:Destroy()
end
