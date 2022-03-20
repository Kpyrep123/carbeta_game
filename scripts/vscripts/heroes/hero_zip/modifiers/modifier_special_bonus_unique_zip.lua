--[[Author: TheGreatGimmick
    Date: May 25, 2017
    Adds max attack speed to Zip during Accelleration]]

modifier_special_bonus_unique_zip = class({}) 


function modifier_special_bonus_unique_zip:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,

    }

	return funcs
end

--[[
function modifier_special_bonus_unique_zip:OnCreated( kv )   
    if IsServer() then
    	print('Slow Motion')
        self.slow1 = -(kv.S)
        self.slow3 = -2*(kv.S)
        print(kv.S)
    end
end
]]

function modifier_special_bonus_unique_zip:GetModifierAttackSpeedBonus_Constant ()
    return 1000
end

function modifier_special_bonus_unique_zip:IsHidden() 
	return true
end

function modifier_special_bonus_unique_zip:IsPurgable() 
    return false
end

function modifier_special_bonus_unique_zip:IsPurgeException() 
    return false
end

function modifier_special_bonus_unique_zip:IsDebuff() 
    return false
end