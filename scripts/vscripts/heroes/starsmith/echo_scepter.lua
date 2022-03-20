


function scepterEcho( keys )
    local caster = keys.caster
    local player = caster:GetPlayerID()
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1
    local point = caster:GetAbsOrigin()
    local vision_range = ability:GetLevelSpecialValueFor("vision_range", (ability:GetLevel() -1))
    local trees = 4
    local radius = 600
    local rotateVar = 45
    local duration = 1.5
    local abilitySec = caster:FindAbilityByName("echo_stomp")
    local casterForwardVec = caster:GetForwardVector()

    local vSpawnPos = {}
    for i=1, trees do
        local rotate_distance = point + casterForwardVec * radius
        local rotate_angle = QAngle(0,rotateVar,0)
        rotateVar = rotateVar + 360/trees
        local rotate_position = RotatePosition(point, rotate_angle, rotate_distance)
        table.insert(vSpawnPos, rotate_position)
    end

    local angle = math.pi/trees
    -- Creates 8 temporary trees at each 45 degree interval around the clicked point
    for i=1,trees do
        local position = table.remove( vSpawnPos, 1 )
            local illusion = CreateUnitByName("ultimate_pillar", position, true, caster, caster, caster:GetTeamNumber())
            local abolka = illusion:AddAbility("echo_stomp")
            abolka:SetLevel(3)
            local explose = ability:ApplyDataDrivenModifier(caster, illusion, "modifier_explose", {duration = duration})


            Timers:CreateTimer( 0.035, function() 
                illusion:CastAbilityNoTarget(abilitySec, illusion:GetPlayerOwnerID())
            end)
        angle = angle + math.pi/trees
    end

    -- Gives vision to the caster's team in a radius around the clicked point for the duration
end