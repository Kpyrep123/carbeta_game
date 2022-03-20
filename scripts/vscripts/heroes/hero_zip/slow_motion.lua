LinkLuaModifier("modifier_slow_motion", "heroes/hero_zip/modifiers/modifier_slow_motion.lua", LUA_MODIFIER_MOTION_NONE)

--[[Author: TheGreatGimmick
    Date: May 25, 2017
    Zip's W, Slow Motion]]

function TimerSet(event)
    local caster = event.caster
    local ability = event.ability

    local slow = 100
    --get all units and buildings globally
    local all_units = FindUnitsInRadius(caster:GetTeamNumber(),
                             caster:GetAbsOrigin(),
                             nil,
                             50000,
                             DOTA_UNIT_TARGET_TEAM_BOTH,
                             DOTA_UNIT_TARGET_ALL,
                             DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD,
                             FIND_ANY_ORDER,
                             false)
    for _,unit in pairs(all_units) do
        if unit ~= caster then
        	--add slow motion modifier
            unit:AddNewModifier(caster, ability, "modifier_slow_motion", { duration = 5 })
            unit:EmitSound("Hero_ArcWarden.MagneticField.Cast")
        end
    end
end

--[[
function TimerSet(event)
    local caster = event.caster
    local ability = event.ability

    local slow = 0
    local interval = 0.5

    for c = 0.00, 5.00, interval do
        Timers:CreateTimer(c, function ()
            print('')
            print('Time: '..c)
            if c < 2 then
                slow = (c/2)*100
            end
            if c >= 2 and c <= 3 then
                slow = 100
            end
            if c > 3 then
                slow = 100 - ((c-3)/2)*100
            end
            print('Slow: '..slow)
            local all_units = FindUnitsInRadius(caster:GetTeamNumber(),
                             caster:GetAbsOrigin(),
                             nil,
                             50000,
                             DOTA_UNIT_TARGET_TEAM_BOTH,
                             DOTA_UNIT_TARGET_ALL,
                             DOTA_UNIT_TARGET_FLAG_NONE,
                             FIND_ANY_ORDER,
                             false)
            for _,unit in pairs(all_units) do
                if unit ~= caster then
                    print(unit:GetName())
                    unit:AddNewModifier(caster, ability, "modifier_slow_motion", { S = slow , duration = (interval+0.01)})
                end
            end
        end)
    end
end
]]
