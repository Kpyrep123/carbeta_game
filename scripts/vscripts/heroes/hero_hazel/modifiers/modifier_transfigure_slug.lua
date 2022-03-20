--[[Author: TheGreatGimmick
    Date: Feb 24, 2017
    Modifier dislays transfigure charges]]

modifier_transfigure_slug = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_transfigure_slug:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		--MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE
	}

	return funcs
end

function modifier_transfigure_slug:GetModifierModelChange()
	--return "models/props_wildlife/wildlife_caterpillar001.vmdl"
	return "models/cube.vmdl"
end

function modifier_transfigure_slug:GetModifierMoveSpeedOverride()
	return self:GetAbility():GetSpecialValueFor("speed")
end

function modifier_transfigure_slug:OnCreated( kv ) 
    if IsServer() then
    	local parent = self:GetParent()
        if not parent.OriginalModelScale then
            parent.OriginalModelScale = parent:GetModelScale()
        end
    	self:GetParent():SetModelScale(3)
    end
end

function modifier_transfigure_slug:OnDestroy( kv ) 
    if IsServer() then
    	local parent = self:GetParent()
    	self:GetParent():SetModelScale(parent.OriginalModelScale)
    end
end
--[[
function modifier_transfigure_slug:GetModifierModelScale()
    return 100
end
]]
function modifier_transfigure_slug:CheckState()
	local state = {
	[MODIFIER_STATE_DISARMED] = true,
	[MODIFIER_STATE_HEXED] = true,
	[MODIFIER_STATE_MUTED] = true,
	[MODIFIER_STATE_EVADE_DISABLED] = true,
	[MODIFIER_STATE_BLOCK_DISABLED] = true,
	[MODIFIER_STATE_MAGIC_IMMUNE] = true 
	}

	return state
end

function modifier_transfigure_slug:IsHidden() 
	return false
end