--[[Author: TheGreatGimmick
    Date: Sept 26, 2017
    Modifier that keeps track of the last allied hero to die]]

modifier_collector_lastdeath = class({}) 

function modifier_collector_lastdeath:OnCreated()
    if IsServer() then
        print('Listening for allied hero deaths.')
    end
end

function modifier_collector_lastdeath:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH
    }
    return funcs
end

function modifier_collector_lastdeath:OnDeath(kv)
    if IsServer() then
        local caster = self:GetParent()
        if kv.unit and kv.unit:IsRealHero() and kv.unit:GetTeam() == caster:GetTeam() then
        	print("An allied Hero has died.")
            self.lastdeath = kv.unit
        end
    end
end

function modifier_collector_lastdeath:RequestLastDeath()
    if IsServer() then
        if self.lastdeath then
            return self.lastdeath
        else
            return -1
        end
    end
end

function modifier_collector_lastdeath:IsHidden() 
	return true
end

function modifier_collector_lastdeath:IsPermanent() 
    return true
end