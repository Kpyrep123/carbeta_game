--[[Author: TheGreatGimmick
    Date: Feb 24, 2017
    Modifier dislays transfigure charges]]

modifier_transfigure_rat_root = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	]]

function modifier_transfigure_rat_root:CheckState()
	local state = {
	[MODIFIER_STATE_DISARMED] = true,
	[MODIFIER_STATE_ROOTED] = true,
	[MODIFIER_STATE_INVISIBLE] = false 
	}

	return state
end

function modifier_transfigure_rat_root:IsHidden() 
	return false
end