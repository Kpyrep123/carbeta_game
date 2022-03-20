parasight_parasitic_invasion = class({})
LinkLuaModifier("modifier_parasight_parasitic_invasion", "scripts/vscripts/heroes/parasight/modifier_parasight_parasitic_invasion.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_parasight_parasitic_invasion_target", "scripts/vscripts/heroes/parasight/modifier_parasight_parasitic_invasion_target.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_parasight_parasitic_invasion_control", "scripts/vscripts/heroes/parasight/modifier_parasight_parasitic_invasion_target.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_parasight_parasitic_invasion_control_buff", "scripts/vscripts/heroes/parasight/modifier_parasight_parasitic_invasion.lua", LUA_MODIFIER_MOTION_NONE)


function parasight_parasitic_invasion:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_parasight/parasight_parasitic_invasion.vpcf", PATTACH_CENTER_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_head", Vector(), true)
    ParticleManager:ReleaseParticleIndex(particle)

    -- Play sounds
    EmitGlobalSound("Hero_Parasight.Parasitic_Invasion.Cast")
    -- target:EmitSound("Hero_Parasight.Parasitic_Invasion.Target")

    -- Get duration
    local duration = self:GetSpecialValueFor("invasion_duration")
    local max_growth_duration = self:GetSpecialValueFor("max_growth_duration")

    -- Check for talent
    local talent = caster:FindAbilityByName("special_bonus_unique_parasight_4")
    if talent and talent:GetLevel() > 0 then
       max_growth_duration = max_growth_duration + talent:GetSpecialValueFor("value")
    end

    local max_control_duration = self:GetSpecialValueFor('max_control_duration')

    -- print(duration)
    local modifier = caster:AddNewModifier(caster, self, "modifier_parasight_parasitic_invasion", {
        duration = duration,
        max_growth_duration = max_growth_duration,
        max_control_duration = max_control_duration,
        target = target})
    modifier:SetTarget(target)
end