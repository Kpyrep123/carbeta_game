sobek_link_of_fortitude = class({})

LinkLuaModifier("modifier_sobek_link_of_fortitude_ally", "scripts/vscripts/heroes/sobek/modifier_sobek_link_of_fortitude_ally.lua", LUA_MODIFIER_MOTION_NONE)

function sobek_link_of_fortitude:CastFilterResultTarget(target)
	local ability = self
    local caster = self:GetCaster()

    if target == caster then
        return UF_FAIL_OTHER
    else
        return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())
    end
end

function sobek_link_of_fortitude:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local modifierParams = {
        duration = self:GetSpecialValueFor("duration")
    }
    target:AddNewModifier(caster, self, 'modifier_sobek_link_of_fortitude_ally', modifierParams)
    caster:EmitSound("Hero_Koh.Link_of_Fortitude.Cast")
    target:EmitSound("Hero_Koh.Link_of_Fortitude.Target")
end