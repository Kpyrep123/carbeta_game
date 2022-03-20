--[[Author: TheGreatGimmick
    Date: Jan 15, 2017
    Play sound and give mana]]
    
function RestoreMana( event )
    local target = event.target
    local mana = event.ReplenishAmount
    target:EmitSound("DOTA_Item.Mango.Activate")
    target:GiveMana(mana)
end
