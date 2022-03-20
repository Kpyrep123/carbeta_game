--[[Author: TheGreatGimmick
    Date: Jan 21, 2017
    Creates dummy for particle effects and executes teleportation if sucessful.]]
    
function PortalStart( event )
    -- Variables
    local caster = event.caster
    --local point = event.target_points[1]
    local ability = event.ability

      --local target_point = ability:GetCursorPosition()
    local target_point = event.target_points[1]
    local hero_pos = caster:GetAbsOrigin()

    local buildings = FindUnitsInRadius(caster:GetTeamNumber(),
                             hero_pos,
                             nil,
                             50000,
                             DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                             DOTA_UNIT_TARGET_BUILDING,
                             DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                             FIND_ANY_ORDER,
                             false)
		
    	local dist_min = 60000
    	local target_build = target_point
		for _,unit in pairs(buildings) do
			local build_pos = unit:GetAbsOrigin()

			local dist_check = target_point - build_pos
			dist_check = dist_check:Length2D()

			if dist_check < dist_min then 
				dist_min = dist_check
				target_build = build_pos
			end

    	end

    	if dist_min > 575 then
    		target_point = target_build + (target_point - target_build):Normalized() * 575
    	end

    caster.point = target_point	
    --caster.horus = caster
    caster.portalp_dummy = CreateUnitByName("portal_potion_dummy", target_point, false, caster, caster, caster:GetTeam())

	event.ability:ApplyDataDrivenModifier(caster, caster.portalp_dummy, "modifier_portalp_thinker", nil)
	AddFOWViewer(caster:GetTeamNumber(), target_point, 200, 3, false)

end


function Teleport( event )
    local ability = event.ability
    local caster = event.caster

    local target_point = caster.point

    	caster:SetAbsOrigin(target_point) --We move the caster instantly to the location
    	FindClearSpaceForUnit(caster, target_point, false) --This makes sure our caster does not get stuck
end

--remove dummy once the spell is over. 
function PortalEnd( event )
    local caster = event.caster
    print("")
    print("portal dummy removed")
    caster.portalp_dummy:RemoveSelf()
end