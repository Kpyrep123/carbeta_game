modifier_parasight_parasitic_invasion_target = class({})
modifier_parasight_parasitic_invasion_control = class({})


if IsServer() then
    forward_orders = {
        [DOTA_UNIT_ORDER_MOVE_TO_POSITION] = true,
        [DOTA_UNIT_ORDER_MOVE_TO_TARGET] = true,
        [DOTA_UNIT_ORDER_ATTACK_MOVE] = true,
        [DOTA_UNIT_ORDER_ATTACK_TARGET] = true,
        [DOTA_UNIT_ORDER_HOLD_POSITION] = true,
        [DOTA_UNIT_ORDER_PICKUP_ITEM] = true,
        [DOTA_UNIT_ORDER_PICKUP_RUNE] = true,
    }

    -- Orders for ability casts
    cast_orders = {
        [DOTA_UNIT_ORDER_CAST_POSITION] = true,
        [DOTA_UNIT_ORDER_CAST_TARGET] = true,
        [DOTA_UNIT_ORDER_CAST_TARGET_TREE] = true,
        [DOTA_UNIT_ORDER_CAST_NO_TARGET] = true,
        [DOTA_UNIT_ORDER_CAST_TOGGLE] = true,
        [DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO] = true,
    }
end

function modifier_parasight_parasitic_invasion_target:IsHidden()
    return true
end

function modifier_parasight_parasitic_invasion_target:IsDebuff()
    return true
end

function modifier_parasight_parasitic_invasion_target:IsPurgable()
    return true
end

function modifier_parasight_parasitic_invasion_target:RemoveOnDeath()
    return true
end


function modifier_parasight_parasitic_invasion_target:OnDestroy()
    if not IsServer() then return end
    if self.invasion_modifier and not self.invasion_modifier.has_control then
        self.invasion_modifier:Destroy()
    end
end


function modifier_parasight_parasitic_invasion_target:Combust()
    if not IsServer() then return end

    self.invasion_modifier:TakeControl()
    self:Destroy()
end

function modifier_parasight_parasitic_invasion_control:GetTexture() 
    return "parasight_parasitic_invasion" 
end

function modifier_parasight_parasitic_invasion_control:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_STATE_CHANGED,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }
end

function modifier_parasight_parasitic_invasion_control:CheckState()
    return {
        [MODIFIER_STATE_SPECIALLY_DENIABLE] = true
    }
end

function modifier_parasight_parasitic_invasion_control:OnCreated()
    self.abilitiesCast = {}
end

-- Track abilities
function modifier_parasight_parasitic_invasion_control:OnAbilityExecuted(ability)
    -- Remember this ability was cast
    self.abilitiesCast[ability.ability] = true
end

-- Destroy if stunned
function modifier_parasight_parasitic_invasion_control:OnStateChanged(params)
    -- if params.unit == self:GetParent() then
    --     if params.unit:IsStunned() then
    --         self:Destroy()
    --     end
    -- end
end

function modifier_parasight_parasitic_invasion_control:OnDestroy()
    -- If this modifier gets purged also destroy parent modifier
    if IsServer() then
        if not self.invasion_modifier:IsNull() then
            self.invasion_modifier:Destroy()
        end
        self:GetParent():Stop()

        -- Refresh abilities
        for ability, _ in pairs(self.abilitiesCast) do
            ability:EndCooldown()
        end
    end
end

function modifier_parasight_parasitic_invasion_control:OrderFilter(order)
    if order.issuer_player_id_const ~= -1 and (forward_orders[order.order_type] or cast_orders[order.order_type]) then
        return false
    end

    return true
end
