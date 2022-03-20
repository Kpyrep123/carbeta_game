--[[Author: TheGreatGimmick
    Date: Feb 24, 2017
    Modifier dislays transfigure charges]]
LinkLuaModifier("modifier_transfigure_rat_root", "heroes/hero_hazel/modifiers/modifier_transfigure_rat_root.lua", LUA_MODIFIER_MOTION_NONE)

modifier_transfigure_rat = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_transfigure_rat:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
        --MODIFIER_PROPERTY_MODEL_SCALE,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACKED 
	}

	return funcs
end

function modifier_transfigure_rat:GetModifierModelChange()
	return "models/props_wildlife/wildlife_rat001.vmdl"
end

function modifier_transfigure_rat:GetModifierMoveSpeedBonus_Percentage ()
	return self:GetAbility():GetSpecialValueFor("speed")
end

function modifier_transfigure_rat:CheckState()
	local state = {
	[MODIFIER_STATE_HEXED] = true,
	[MODIFIER_STATE_MUTED] = true,
	[MODIFIER_STATE_EVADE_DISABLED] = true,
	[MODIFIER_STATE_BLOCK_DISABLED] = true,
	[MODIFIER_STATE_SILENCED] = true, 
	}

	return state
end

function modifier_transfigure_rat:IsHidden() 
	return false
end

function modifier_transfigure_rat:OnCreated( kv ) 
    if IsServer() then
        if kv then 
            print(kv)
        else
            print('No kv')
        end
        self.AttackBonus = (self:GetParent():GetAttackRange() - self:GetAbility():GetSpecialValueFor("attack_range")) * -1
        --We get original attack range and substract away the wanted attack range, then negate the result.
        --YAY Math!
        self.OriginalAtkCap = self:GetParent():GetAttackCapability() 
        --Save original so we can set it back.
        self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)

        local parent = self:GetParent()
        if not parent.OriginalModelScale then
            parent.OriginalModelScale = parent:GetModelScale()
        end
        self:GetParent():SetModelScale(3) 
    end
end

function modifier_transfigure_rat:OnDestroy()
    if IsServer() then
        local parent = self:GetParent()
        self:GetParent():SetAttackCapability(self.OriginalAtkCap)
        self:GetParent():SetModelScale(parent.OriginalModelScale)
    end
end

function modifier_transfigure_rat:GetModifierAttackRangeBonus() return self.AttackBonus end
--[[
function modifier_transfigure_rat:GetModifierModelScale()
    return 100
end
]]
function modifier_transfigure_rat:OnAttacked(event)

    local attacker = event.attacker
    local victim = event.target

    local return_damage = (event.original_damage)
    local damage_type = DAMAGE_TYPE_PHYSICAL --event.damage_type
    --local damage_flags = event.damage_flags
    local ability = self:GetAbility()
    local parent = self:GetParent()

    local damageTable = {
        victim = victim, 
        attacker = attacker,
        damage = self:GetAbility():GetSpecialValueFor("catdamage"),
        damage_type = damage_type,
        --damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
        ability = ability 
    }

    if victim == parent then 
        print('Rat Attacked')
        local attacker_check = attacker:GetName()
        if attacker_check ~= nil then
        	print('Attacker: '..attacker_check)
        else
        	print('No attacker found')
        end

        local iscat = attacker:FindAbilityByName("hazel_cat_elusive")

        if iscat then
            print('Cat (confirmation: '..iscat:GetName()..' )')
        else
            print('Not cat')
        end

        if  iscat then
        	print('Damage Dealt and rooted')
        	ApplyDamage(damageTable)
            victim:AddNewModifier(attacker, ability, "modifier_transfigure_rat_root", {duration = 1})
        end
    end 
end 