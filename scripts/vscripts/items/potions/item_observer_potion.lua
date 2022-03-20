--[[Author: TheGreatGimmick
    Date: Jan 23, 2017
    Creates the Eye of the Sun, 
    deletes the previous Eye of the Sun,
    and gives unobstructed vision and True Sight.]]

--used for unit "AI", and to give just enough vision to see the particle effects on spawn. 
function Spawn(entityKeyValues)
	AddFOWViewer(thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), 175, 2, false)
    thisEntity:AddNewModifier(thisEntity, nil, "modifier_invisible", {duration = 540})
    thisEntity:SetContextThink("ObsPotVision", ObsPotVision, 1)
end

--gives unobstructed vision while it is Day and the Eye is alive. 
function ObsPotVision()
    if thisEntity:IsAlive() then
    		AddFOWViewer(thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), 1600, 1, true)
    	return 1
    end
end