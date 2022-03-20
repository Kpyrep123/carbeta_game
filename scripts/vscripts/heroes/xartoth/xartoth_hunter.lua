xartoth_hunter = class({})
LinkLuaModifier( "xartoth_hunter_passive", "heroes/xartoth/xartoth_hunter.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "xartoth_hunter_buff", "heroes/xartoth/xartoth_hunter.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "xartoth_hunter_debuff", "heroes/xartoth/xartoth_hunter.lua" ,LUA_MODIFIER_MOTION_NONE )

function xartoth_hunter:GetIntrinsicModifierName()
	return "xartoth_hunter_passive"
end

function xartoth_hunter:OnSpellStart(kv)
	local targetFlag = DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO
	local caster = self:GetCaster()
	local radius = 99999
	EmitSoundOn("hero_bloodseeker.bloodRage", caster)
	local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, targetFlag, FIND_CLOSEST, false )
	
	for k, v in pairs( units ) do
		if v:IsRealHero() then
		 v:AddNewModifier(caster, self, "xartoth_hunter_debuff", {duration = self:GetSpecialValueFor("reveal_duration")})
		break
		end
	end
end

xartoth_hunter_passive = class({})

function xartoth_hunter_passive:IsPurgable() return false end

function xartoth_hunter_passive:IsHidden() return true end

function xartoth_hunter_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ORDER,
	MODIFIER_EVENT_ON_ATTACK_START}
end

function xartoth_hunter_passive:OnOrder(kv)
		local hOrderedUnit = kv.unit 
		local hTargetUnit = kv.target
		local nOrderType = kv.order_type
		
		if kv.unit ~= self:GetParent() then
		return
		end
		
		if nOrderType == DOTA_UNIT_ORDER_MOVE_TO_TARGET then
			if hTargetUnit:HasModifier("xartoth_hunter_debuff") then
			 self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "xartoth_hunter_buff", {})
			else
			 self:GetParent():RemoveModifierByName("xartoth_hunter_buff")
			end
		elseif nOrderType == DOTA_UNIT_ORDER_ATTACK_TARGET then
			if hTargetUnit:HasModifier("xartoth_hunter_debuff") then
			 self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "xartoth_hunter_buff", {})
			else
			 self:GetParent():RemoveModifierByName("xartoth_hunter_buff")
			end
		elseif nOrderType == DOTA_UNIT_ORDER_CAST_TARGET then
			if hTargetUnit:HasModifier("xartoth_hunter_debuff") then
			 self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "xartoth_hunter_buff", {})
			else
			 self:GetParent():RemoveModifierByName("xartoth_hunter_buff")
			end
		elseif nOrderType == DOTA_UNIT_ORDER_CAST_NO_TARGET	then
		elseif nOrderType == DOTA_UNIT_ORDER_TRAIN_ABILITY	then
		elseif nOrderType == DOTA_UNIT_ORDER_PURCHASE_ITEM	then
		elseif nOrderType == DOTA_UNIT_ORDER_SELL_ITEM	then
		elseif nOrderType == DOTA_UNIT_ORDER_DISASSEMBLE_ITEM	then
		elseif nOrderType == DOTA_UNIT_ORDER_MOVE_ITEM	then
		elseif nOrderType == DOTA_UNIT_ORDER_CAST_TOGGLE	then
		elseif nOrderType == DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO	then
		else
		 self:GetParent():RemoveModifierByName("xartoth_hunter_buff")
		end
		
end

function xartoth_hunter_passive:OnAttackStart(kv)
	if kv.attacker == self:GetParent() then
		if kv.target:HasModifier("xartoth_hunter_debuff") then
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "xartoth_hunter_buff", {})
			else
			self:GetParent():RemoveModifierByName("xartoth_hunter_buff")
		end
	end
end

xartoth_hunter_debuff = class({})

function xartoth_hunter_debuff:IsDebuff() return true end

function xartoth_hunter_debuff:DeclareFunctions()
	local funcs = {
	 MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	 MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function xartoth_hunter_debuff:GetModifierProvidesFOWVision()
	return 1
end

function xartoth_hunter_debuff:OnDeath(kv)
	if kv.attacker == self:GetCaster() then
		self:GetCaster():ModifyGold(self:GetAbility():GetSpecialValueFor("gold_bonus"), true, 0)
		SendOverheadEventMessage(self:GetCaster():GetPlayerOwner(), OVERHEAD_ALERT_GOLD, self:GetCaster(), self:GetAbility():GetSpecialValueFor("gold_bonus"), self:GetCaster():GetPlayerOwner())
	end
end

function xartoth_hunter_debuff:OnDestroy()
	self:GetCaster():RemoveModifierByName("xartoth_hunter_buff")
end

function xartoth_hunter_debuff:GetEffectName()
	return "particles/xartothbloodmark_particles/xartoth_blood_mark.vpcf"
end

function xartoth_hunter_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

xartoth_hunter_buff = class({})

function xartoth_hunter_buff:DeclareFunctions()
	local funcs = {
	 MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	 MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function xartoth_hunter_buff:GetModifierDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("damage_bonus")
end

function xartoth_hunter_buff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("speed_bonus")
end