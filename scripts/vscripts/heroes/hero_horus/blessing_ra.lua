--[[Author: TheGreatGimmick
    Date: Jan 10, 2017
    Manages the vision granted and sounds made by Horus' 
    Blessing of Ra ability. ]]

--grant global unobstructed vision to Horus' team. Called by the Blessing of Ra buff in 0.1 second intervals. 
function RaVision(keys)
    local caster = keys.caster
    --create a grid of vision-granting nodes, since the max vision radius is not global. 
    for x = -10000, 20000, 3000 do
    	for y = -10000, 20000, 3000 do
    		AddFOWViewer(caster:GetTeam(), Vector(x, y, 0), 3000, 0.1, false)
    	end
    end

    if caster:HasScepter() then
        --apply True Sight if the caster has a scepter. 
    	local units = FindUnitsInRadius(caster:GetTeamNumber(),
                             caster:GetAbsOrigin(),
                             nil,
                             50000,
                             DOTA_UNIT_TARGET_TEAM_ENEMY,
                             DOTA_UNIT_TARGET_ALL,
                             DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                             FIND_ANY_ORDER,
                             false)
		

		for _,unit in pairs(units) do
			if not unit:IsOther() then
				unit:RemoveModifierByName('modifier_truesight')
       			unit:AddNewModifier(caster, ability, 'modifier_truesight', {duration = 0.5})
       		end
    	end
    end
end

--causes those affected by Blessing of Ra Burn debuff to emit sound. 
function RaBurn( event )
    local target = event.target
    target:EmitSound("DOTA_Item.Radiance.Target.Loop")
end

--manages sounds. Called at the start of the spell, and uses Timers to manage events. 
function RaQuench(event)
    local ability = event.ability
    local caster = event.caster
    local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))
    
    --stops the Blessing of Ra Burn sound effect on all enemy Heroes currently alive. 
    Timers:CreateTimer(duration + 0.6, function ()
        local raburns = FindUnitsInRadius(caster:GetTeamNumber(),
                             caster:GetAbsOrigin(),
                             nil,
                             50000,
                             DOTA_UNIT_TARGET_TEAM_ENEMY,
                             DOTA_UNIT_TARGET_HERO,
                             DOTA_UNIT_TARGET_FLAG_NONE,
                             FIND_ANY_ORDER,
                             false)

        for _,unit in pairs(raburns) do
            unit:StopSound("DOTA_Item.Radiance.Target.Loop")
        end
    end)

    --emits the Blessing of Ra buff sound effect over the duration. 

    Timers:CreateTimer(3, function ()
            if caster:IsAlive() then
                caster:EmitSound("Hero_ArcWarden.MagneticField")
            end
    end)

    if duration > 6 then
        Timers:CreateTimer(6, function ()
                if caster:IsAlive() then
                    caster:EmitSound("Hero_ArcWarden.MagneticField")
                end
        end)
        if duration > 9 then
            Timers:CreateTimer(9, function ()
                    if caster:IsAlive() then
                        caster:EmitSound("Hero_ArcWarden.MagneticField")
                    end
            end)
        end
    end

    --stops emitting the Blessing of Ra buff sound effect after the duration. 
    Timers:CreateTimer(duration + 0.01, function ()
            caster:StopSound("Hero_ArcWarden.MagneticField")
    end)

end

--stops Blessing of Ra buff sound on Horus' death
function RaDeath(event)
    local caster = event.caster
    caster:StopSound("Hero_ArcWarden.MagneticField")
end

--stops Blessing of Ra Burn debuff sound on victim's death
function RaKill(event)
    local unit = event.unit
    unit:StopSound("DOTA_Item.Radiance.Target.Loop")
end


