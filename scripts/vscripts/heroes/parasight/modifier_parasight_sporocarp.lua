modifier_parasight_sporocarp = class({})
LinkLuaModifier("modifier_parasight_catalytic_spore", "scripts/vscripts/heroes/parasight/modifier_parasight_catalytic_spore.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_parasight_sporocarp_ward", "scripts/vscripts/heroes/parasight/modifier_parasight_sporocarp_ward.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_parasight_sporocarp_truesight", "scripts/vscripts/heroes/parasight/modifier_parasight_sporocarp_truesight.lua", LUA_MODIFIER_MOTION_NONE)



local cast_orders = {}
if IsServer() then
    -- Orders for ability casts
    cast_orders = {
        [DOTA_UNIT_ORDER_CAST_POSITION] = true,
        [DOTA_UNIT_ORDER_CAST_TARGET] = true,
        [DOTA_UNIT_ORDER_CAST_TARGET_TREE] = true,
    }
end

function modifier_parasight_sporocarp:IsHidden()
    return true
end

function modifier_parasight_sporocarp:OnCreated(params)
    if IsServer() then
        -- Set event listener
    end
end

function modifier_parasight_sporocarp:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ORDER,
        MODIFIER_EVENT_ON_DEATH
    }   
    return funcs
end

-- local sporocarp = caster:FindModifierByName("modifier_parasight_sporocarp")
--     if sporocarp and not target:HasModifier('modifier_parasight_sporocarp_ward') then 
--         sporocarp:CreateSpore(target:GetAbsOrigin())
--     end

function modifier_parasight_sporocarp:OnDeath(keys)
    local unit = keys.unit
    local modifier = unit:FindModifierByName('modifier_parasight_catalytic_spore') 
    local modifier2 = unit:FindModifierByName('modifier_parasight_fungal_pod') 
    if modifier then
        modifier:Combust()
        self:CreateSpore(unit:GetAbsOrigin())
    elseif modifier2 then
        self:CreateSpore(unit:GetAbsOrigin())
    end
end

function modifier_parasight_sporocarp:OnOrder(keys)
    --Accept cast orders as valid
    if keys.unit == self:GetParent() and cast_orders[keys.order_type] then
        --print("you tried to cast " .. keys.ability:GetName())
        local caster = self:GetCaster()
        local origin = caster:GetAbsOrigin()
        local ability = keys.ability
        local target = keys.target
        local position = keys.new_pos
        if target then position = keys.target:GetAbsOrigin() end
        if ability then 
            -- Check to see if sporocarp are in range
            local wardPos = self:CheckSporocarp(position, ability:GetCastRange(position, self:GetCaster()))
            if wardPos then
                --print("found sporocarp")
                -- Simulate ability cast
                if caster:GetMana() >= ability:GetManaCost(-1) and ability:IsCooldownReady() then
                    caster:Stop()
                    caster:SetCursorPosition(position)
                    if target then caster:SetCursorCastTarget(target) end
                    caster:SetAbsOrigin(wardPos)
                    ability:UseResources(true,true,true)
                    ability:OnSpellStart()
                    caster:SetAbsOrigin(origin) 
                    Timers:CreateTimer(0.03, function ()
                        caster:Stop()
                    end)
                end
            end
        end
    end
end


function modifier_parasight_sporocarp:CheckSporocarp(position, range)
    --print("checking for sporocarp")
    local caster = self:GetCaster()
    for k, unit in pairs(caster.spores) do
        local wardPosition = unit:GetAbsOrigin()
        if (wardPosition - position):Length2D() < range then
            return wardPosition
        end
    end

    return false

end

function modifier_parasight_sporocarp:OnCreated(params)
    if IsServer() then
        -- Keep track of spores
        local caster = self:GetCaster()
        if not caster.spores then caster.spores = {} end
    end
end


function modifier_parasight_sporocarp:CreateSpore(location)
    local caster = self:GetCaster()
    local ability = caster:FindAbilityByName("parasight_sporocarp")

    if not ability then return end

    -- Create particle
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_parasight/parasight_sporocarp_ambient.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, location)
    ParticleManager:SetParticleControl(particle, 1, Vector(30, 0, 0))

    local duration = ability:GetSpecialValueFor("duration")
    local vision = ability:GetSpecialValueFor("vision")

    CreateUnitByNameAsync("npc_parasight_sporocarp_ward", location, false, caster, caster:GetPlayerOwner(), caster:GetTeam(), function(ward)
         ward:AddNewModifier(caster, ability, "modifier_kill", { Duration = duration } )
         ward:SetDayTimeVisionRange(vision)
         ward:SetNightTimeVisionRange(vision)
         -- Check for talent
         local talent = caster:FindAbilityByName("special_bonus_unique_parasight_5")
         if talent and talent:GetLevel() > 0 then
            ward:AddNewModifier(caster, self:GetAbility(), "modifier_parasight_sporocarp_truesight", {Radius = vision})
         end

         local modifier = ward:AddNewModifier(caster, self:GetAbility(), "modifier_parasight_sporocarp_ward", {})
         modifier:AddParticle(particle, false, false, 1, false, false)

         table.insert(caster.spores, ward)
    end)
end






-- function modifier_parasight_sporocarp:DeclareFunctions()
--     return {
--         MODIFIER_EVENT_ON_HERO_KILLED
--     }
-- end


-- function modifier_parasight_sporocarp:OnIntervalThink()
--     local caster = self:GetCaster()

--     -- Loop over all spores
--     for spore, _ in pairs(self.spores) do
--         -- Check if enemy is in radius
--         local units = FindUnitsInRadius(caster:GetTeam(), spore.location, nil, 100, DOTA_UNIT_TARGET_TEAM_ENEMY, 
--         DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)

--         if #units > 0 then
--             -- Get paralytic spore ability for params
--             local ability = caster:FindAbilityByName('parasight_catalytic_spore')

--             -- Apply paralytic spore to unit
--             local modifier = units[1]:AddNewModifier(caster, ability, 'modifier_parasight_catalytic_spore', {
--                 max_growth_duration = ability:GetSpecialValueFor('max_growth_time'),
--                 min_stun = ability:GetSpecialValueFor('min_stun'),
--                 max_stun = ability:GetSpecialValueFor('max_stun'),
--                 stun_radius = ability:GetSpecialValueFor('stun_radius')
--             })

--             -- Play particle on unit affected
--             local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_death_pact.vpcf", PATTACH_ABSORIGIN_FOLLOW, units[1])
--             ParticleManager:ReleaseParticleIndex(particle)

--             -- Remove spore from ground
--             ParticleManager:DestroyParticle(spore.particle, false)
--             ParticleManager:ReleaseParticleIndex(spore.particle)

--             -- Remove from set
--             self.spores[spore] = nil
--         end
--     end
-- end

-- function modifier_parasight_sporocarp:OnHeroKilled(params)
--     if IsServer() then
--         local parent = self:GetParent()
--         if params.attacker == parent or self.assists < parent:GetAssists() then
--             self.assists = self.assists + 1
--             self:OnAssist(params.target)
--         end
--     end
-- end

-- function modifier_parasight_sporocarp:OnAssist(victim)
--     local caster = self:GetCaster()

--     -- If victim has catalytic spore modifier, spawn spore on floor
--     if victim:HasModifier('modifier_parasight_catalytic_spore') then
--         -- Create spore
--         local spore = self:CreateSpore(victim:GetAbsOrigin())

--         -- Add to spore list
--         self.spores[spore] = true
--     end

--     -- Spawn ward at corpse
--     CreateUnitByNameAsync("npc_parasight_sporocarp_ward", victim:GetAbsOrigin(), false, caster, caster:GetPlayerOwner(), caster:GetTeam(), function(ward)
--         ward:AddNewModifier(caster, self:GetAbility(), "modifier_parasight_sporocarp_ward", {})
--     end)
-- end

