


--[[Author: TheGreatGimmick
    Date: March 1, 2017
    Modifier that keeps track of the last spell/item used]]

modifier_horror_lastspell = class({}) 

function modifier_horror_lastspell:OnCreated()
    if IsServer() then
        print('Listening for spells or items.')
        --self.lastspell = -1
    end
end

function modifier_horror_lastspell:IsPermanent()
    return true
end

function modifier_horror_lastspell:DeclareFunctions()
    local funcs = {
    MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }
    return funcs
end

function modifier_horror_lastspell:OnAbilityExecuted(kv)
    if IsServer() then
        local caster = self:GetParent()
        if kv.unit == caster then
            --variables 
            local a = kv.ability
            local name = a:GetName()
            local cd = a:GetCooldown(a:GetLevel())

            --if the ability used has a cooldown, is not toggled, and is not a Refresher Orb nor a Bottle
            --OR
            --if the ability is Skulk
            --OR
            --If the ability is Cold Spot with no charges remaining, 
            local check = 0
            if (( not a:IsToggle() ) and cd > 0 and name ~= "item_refresher" and name ~= "item_bottle") or ( name == "horror_skulk" ) then
                check = 1
            end
            if name == "horror_cold_spot" then
                --local charges = caster.cold_spot_charges
                --print('Last spell checker: Charges : '..charges)
                --if charges <= 0 then
                    check = 1
                --end
            end
         
            if check == 1 then
                --record last spell or item cast
                self.lastspell = kv.ability
                print("")
                print('Last Spell is now '..self.lastspell:GetName()..'.')
            else
                --do nothing s
                print("")
                print('A spell has been rejected by Last Spell.')
            end
        end
    end
end

function modifier_horror_lastspell:RequestLastSpell()
    if IsServer() then
        if self.lastspell then
            return self.lastspell
        else
            return -1
        end
    end
end

function modifier_horror_lastspell:IsHidden() 
	return true
end