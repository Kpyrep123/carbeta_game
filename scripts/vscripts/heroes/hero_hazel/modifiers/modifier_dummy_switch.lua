--[[Author: TheGreatGimmick
    Date: Feb 22, 2017
    Modifier that keeps the Black Cat's damage at 15.]]

modifier_dummy_switch = class({}) 

function modifier_dummy_switch:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, 
    }

	return funcs
end

function modifier_dummy_switch:OnCreated( kv )   
    if IsServer() then
        print("")
    	print('Cat attack modifier begun')
    	self.AttackBonus = 0
        self:StartIntervalThink(0.01)
    end
end

function modifier_dummy_switch:GetModifierBaseAttack_BonusDamage() return self.AttackBonus end

function modifier_dummy_switch:OnIntervalThink()
    if IsServer() then
    	local damage = self:GetParent():GetAverageTrueAttackDamage(self:GetParent())
    	if damage > 15 then
    		local current = self.AttackBonus
    		print('Current damage mitigation is '..current)
    		self.AttackBonus = (damage - (current + 15))*-1 --self:GetAbility():GetSpecialValueFor("attackdamage")) * -1
    		print('True Damage is '..damage..', so a damage mitigation of '..self.AttackBonus..' has been given.')
    	else
    		if damage < 15 then
    			self.AttackBonus = 0
    			print('True Damage is '..damage..', so a damage mitigation of '..self.AttackBonus..' has been given.')
    		else
    			--print('True damage is correct, so no mitigation change is needed')
    		end
    	end
    end
end

function modifier_dummy_switch:IsHidden() 
	return true
end