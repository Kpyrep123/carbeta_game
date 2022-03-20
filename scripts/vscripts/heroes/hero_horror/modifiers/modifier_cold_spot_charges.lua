--[[Author: TheGreatGimmick
    Date: Feb 22, 2017
    Modifier dislays Cold Spot charges]]

modifier_cold_spot_charges = class({})

function modifier_cold_spot_charges:IsHidden() 
	return false
end

function modifier_cold_spot_charges:IsPermanent() 
	return true
end