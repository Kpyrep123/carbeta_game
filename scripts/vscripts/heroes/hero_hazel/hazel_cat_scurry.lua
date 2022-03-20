--[[Author: TheGreatGimmick
    Date: Feb 16, 2017
    Hazel's Black Cat's second ability.]]

--Run constantly, checking for nearby visible enemies. 
function ScurryCheck(event)
    --Variables
    local caster = event.caster
    local pos = caster:GetAbsOrigin()
    local ability = event.ability
    --set check flag to false
    local check = 0

    --find all nearby enemies
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                             caster:GetAbsOrigin(),
                             nil,
                             900,
                             DOTA_UNIT_TARGET_TEAM_ENEMY,
                             DOTA_UNIT_TARGET_ALL,
                             DOTA_UNIT_TARGET_FLAG_NONE,
                             FIND_ANY_ORDER,
                             false)

    for _,unit in pairs(enemies) do
        --for each enemy nearby
        local see = caster:CanEntityBeSeenByMyTeam(unit)

        if see then
            --if an enemy is visible, give the speed boost and set the check flag to true. 
            check = 1
            caster:AddNewModifier(caster, nil, "modifier_bloodseeker_thirst", { duration = 3 })
            caster:SetBaseMoveSpeed(700)
        end

    end

    local speed = caster:GetBaseMoveSpeed()

    if check == 0 and speed == 700 then
        --if the check flag is false but the movement speed is still granted, remove movement speed after a delay
        Timers:CreateTimer(2, function ()
                if caster and check == 0 then
                    --if the check flag is still false, remove movement speed
                    caster:SetBaseMoveSpeed(400)
                end
        end)
    end

end

