--[[Author: TheGreatGimmick
    Date: May 25, 2017
    Modifier that slows Turning rate, attack rate, and movement speed by massive amounts.]]

modifier_slow_motion = class({}) 


function modifier_slow_motion:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,

    }

	return funcs
end

--[[
function modifier_slow_motion:OnCreated( kv )   
    if IsServer() then
    	print('Slow Motion')
        self.slow1 = -(kv.S)
        self.slow3 = -2*(kv.S)
        print(kv.S)
    end
end
]]

function modifier_slow_motion:GetModifierMoveSpeedBonus_Percentage ()
    return (-1000) --self.slow1
end

function modifier_slow_motion:GetModifierTurnRate_Percentage ()
    return (-1000) --self.slow1
end

function modifier_slow_motion:GetModifierAttackSpeedBonus_Constant ()
    return (-1000) --self.slow3
end

function modifier_slow_motion:IsHidden() 
	return false
end

function modifier_slow_motion:IsPurgable() 
    return false
end

function modifier_slow_motion:IsPurgeException() 
    return false
end

function modifier_slow_motion:IsDebuff() 
    return true
end