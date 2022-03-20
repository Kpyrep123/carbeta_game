modifier_activatable = class({})

function modifier_activatable:OnCreated(params)
    if params.alliedOnly then self.alliedOnly = params.alliedOnly else self.alliedOnly = true end
    self.cooldown = params.cooldown or 0
    self.distance = params.distance or 200

    self.lastActivation = -1000
end

function modifier_activatable:CanActivate(activator)
    return activator:GetTeam() == self:GetParent():GetTeam() or not self.alliedOnly
end

function modifier_activatable:IsInRange(activator)
    local parent = self:GetParent()
    local distance = (parent:GetAbsOrigin() - activator:GetAbsOrigin()):Length2D()
    return distance <= self.distance
end

function modifier_activatable:IsCooldownReady()
    return GameRules:GetGameTime() - self.lastActivation > self.cooldown
end

function modifier_activatable:Activate(activator)
    -- Check cooldown
    if not self:IsCooldownReady() then
        return false
    end

    -- Check if can be activated by this activator
    if not self:CanActivate(activator) then
        return false
    end

    -- Activate
    local parent = self:GetParent()
    self.lastActivation = GameRules:GetGameTime()

    if self.OnActivate then
        self.OnActivate(parent, activator)
    end
end