--[[Author: TheGreatGimmick
    Date: June 22, 2017
    Causes the unit to level up upon the Talent being taken]]

function TalentLevelUp(event)
	local caster = event.caster

    local current_level = caster:GetLevel()
    local starting_exp = caster:GetCurrentXP()
    
    for 1,4,1 do 
        if current_level < 25 then
            local new_level = current_level + 1
            while current_level < new_level do
                caster:AddExperience(1, 0, false, false)
                current_level = caster:GetLevel()
            end
        end
    end
    
--[[
    if current_level < 25 then
        local current_exp = caster:GetCurrentXP()
        while current_exp < starting_exp
    ]]
end