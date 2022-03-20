parasight_combust = class({})

function parasight_combust:CastFilterResultTarget(target)
    if target == self:GetCaster() 
        or self:CheckValidTarget(target)
    then
        return UF_SUCCESS
    else
        return UF_FAIL_OTHER
    end
end

function parasight_combust:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if target == caster then
        self:CombustAll()
    else
        local modifier = target:FindModifierByName('modifier_parasight_parasitic_invasion_target')
            or target:FindModifierByName('modifier_parasight_catalytic_spore') 
            or target:FindModifierByName('modifier_parasight_fungal_pod')
            or target:FindModifierByName('modifier_parasight_sporocarp_ward')
        if modifier then
            modifier:Combust()
        end
    end
end

function parasight_combust:CombustAll()
    local caster = self:GetCaster()
    local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 80000, DOTA_UNIT_TARGET_TEAM_BOTH, 
        DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)

    for k, unit in pairs(units) do 
        if not caster:CanEntityBeSeenByMyTeam(unit) and self:CheckValidTarget(unit) then
            -- print(unit:GetName())
            caster:SetCursorCastTarget(unit)
            self:OnSpellStart()
        end
    end
    self:StartCooldown(1.0)
end

function parasight_combust:CheckValidTarget(target)
    if target:HasModifier('modifier_parasight_catalytic_spore') 
        or target:HasModifier('modifier_parasight_fungal_pod')
        or target:HasModifier('modifier_parasight_sporocarp_ward')
        or target:HasModifier('modifier_parasight_parasitic_invasion_target')
    then 
        return true
    else
        return false
    end
end

function parasight_combust:Spawn()
    if not IsServer() then return end
    self:SetLevel(1)
end