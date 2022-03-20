LinkLuaModifier( "modifier_bleed_lua" , "components/creeps/jungle_stalker.lua" , LUA_MODIFIER_MOTION_NONE )

--[[
    Author: jhqz103
    Date: 17.10.2016
    Simply applies the lua modifier
--]]
function ApplyLuaModifier( keys )
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local modifiername = "modifier_bleed_lua"
    local duration = ability:GetSpecialValueFor("duration")
    target:AddNewModifier(caster, ability, modifiername, {duration = duration})
end