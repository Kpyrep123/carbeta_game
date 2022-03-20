--[[Author: TheGreatGimmick
    Date: Jan 15, 2017
    Creates the relevent Potions and removes the relevent ingredient items.
    Also manages sound effects.]]
    
function RainWash( event )
    local caster = event.caster

    local RemovePositiveBuffs = false
    local RemoveDebuffs = true
    local BuffsCreatedThisFrameOnly = false
    local RemoveStuns = false
    local RemoveExceptions = false

    caster:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
end
