if IsServer() then
	require('abilities/life_in_arena/utils')
end
function CreateRepeater( keys )
local target = keys.target
local caster = keys.caster
local ability = keys.ability
local ability_level = ability:GetLevel() - 1
local origin = ability:GetCursorPosition()
local outgoingDamage = 15
local incomingDamage = 100
local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
local player = caster:GetPlayerID()


Repeater = CreateIllusion(caster,caster,origin,duration,outgoingDamage,incomingDamage)
Repeater:SetControllableByPlayer(player, false)

ability:ApplyDataDrivenModifier(caster, Repeater, "modifier_trade_aura", {duration = duration})
end