LinkLuaModifier("modifier_parasight_catalytic_spore", "scripts/vscripts/heroes/parasight/modifier_parasight_catalytic_spore.lua", LUA_MODIFIER_MOTION_NONE)

parasight_catalytic_spore = class({})

function parasight_catalytic_spore:CastFilterResultTarget(target)
    if target == self:GetCaster() then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end

function parasight_catalytic_spore:GetCustomCastErrorTarget(target)
    return "Ability Can't Target Yourself"
end

-- function parasight_catalytic_spore:OnUpgrade()
--     local caster = self:GetCaster()
--     local combustAbility = caster:FindAbilityByName('parasight_catalytic_spore_combust')

--     if combustAbility and self:GetLevel() > 0 then
--         combustAbility:SetLevel(1)
--     end
-- end

function parasight_catalytic_spore:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    -- Remove previous spore if it still exists
    -- if self.previousSpore and not self.previousSpore:IsNull() then
    --     self.previousSpore:Destroy()
    -- end

    local max_growth_duration = self:GetSpecialValueFor('max_growth_time')

    -- Check for talent
    local talent = caster:FindAbilityByName("special_bonus_unique_parasight_4")
    if talent and talent:GetLevel() > 0 then
       max_growth_duration = max_growth_duration + talent:GetSpecialValueFor("value")
    end


    local modifier = target:AddNewModifier(caster, self, 'modifier_parasight_catalytic_spore', {
        max_growth_duration = max_growth_duration,
        min_stun = self:GetSpecialValueFor('min_stun'),
        max_stun = self:GetSpecialValueFor('max_stun'),
        radius = self:GetSpecialValueFor('radius')
    })

    -- self.previousSpore = modifier
end