--[[Author: TheGreatGimmick
    Date: Jan 23, 2017
    Causes the unit to level up upon using the Knowledge Potion]]

function KnowPotLevelUp(event)
	local target = event.target

    local current_level = target:GetLevel()
    
    if current_level < 25 then
        local new_level = current_level + 1
        while current_level < new_level do
            target:AddExperience(1, 0, false, false)
            current_level = target:GetLevel()
        end
    end
    target:RemoveModifierByName('modifier_item_knowledge_potion')
end