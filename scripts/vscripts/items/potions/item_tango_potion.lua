--[[Author: YOLOSPAGHETTI; slightly edited by TheGreatGimmick
    Date: March 22, 2016 ; slightly edited 1/18/2017
    Creates the sprout]]
function CreateSprout(keys)
    local caster = keys.caster
    local ability = keys.ability
    local point = ability:GetCursorPosition()
    local duration = ability:GetSpecialValueFor("duration")
    local vision_range = 300 --edited from dynamic to static value 1/18/2017
    local trees = 8
    local radius = 150
    local angle = math.pi/4
    
    -- Creates 8 temporary trees at each 45 degree interval around the clicked point
    for i=1,trees do
        local position = Vector(point.x+radius*math.sin(angle), point.y+radius*math.cos(angle), point.z)
        CreateTempTree(position, duration)
        angle = angle + math.pi/4
    end
    -- Gives vision to the caster's team in a radius around the clicked point for the duration
    AddFOWViewer(caster:GetTeam(), point, vision_range, duration, false)
end