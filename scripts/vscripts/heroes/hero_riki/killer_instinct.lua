veerah_killer_instinct_lua = class({})
LinkLuaModifier("modifier_shard_evasion", "heroes/hero_riki/killer_instinct.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_veerah_killer_instinct_lua_buff", "heroes/hero_riki/killer_instinct.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_bleed", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_veerah_killer_instinct_lua", "heroes/hero_riki/killer_instinct.lua", LUA_MODIFIER_MOTION_NONE)
function veerah_killer_instinct_lua:GetIntrinsicModifierName(  )
	return "modifier_veerah_killer_instinct_lua"
end

modifier_veerah_killer_instinct_lua = class({})

modifier_veerah_killer_instinct_lua = class({})
function modifier_veerah_killer_instinct_lua:IsHidden() return true end
function modifier_veerah_killer_instinct_lua:IsPurgable() return false end
function modifier_veerah_killer_instinct_lua:GetEffectName() return end

function modifier_veerah_killer_instinct_lua:OnCreated()
if not IsServer() then return end
	self:StartIntervalThink(0.03)
	self:OnIntervalThink()
end

function modifier_veerah_killer_instinct_lua:OnRefresh()
if not IsServer() then return end
end

function modifier_veerah_killer_instinct_lua:OnIntervalThink()
	local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), self:GetCaster(), 400,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
	local count = 0
	for k, v in pairs( units ) do
		count = count + 1
	end
	if count > 0 and not self:GetCaster():HasModifier( "modifier_veerah_killer_instinct_lua_buff" ) then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_veerah_killer_instinct_lua_buff", {})
		if self:GetCaster():HasModifier("modifier_shard_evasion") then 
			self:GetCaster():RemoveModifierByName("modifier_shard_evasion")
		end
	elseif count == 0 then
		if self:GetCaster():HasModifier("modifier_veerah_killer_instinct_lua_buff") then
			self:GetCaster():RemoveModifierByName("modifier_veerah_killer_instinct_lua_buff")
		end
		if self:GetCaster():HasTalent("special_bonus_unquie_evasion") then 
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_shard_evasion", {})
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
modifier_veerah_killer_instinct_lua_buff = class({})

modifier_veerah_killer_instinct_lua_buff = class({})
function modifier_veerah_killer_instinct_lua_buff:IsHidden() return false end
function modifier_veerah_killer_instinct_lua_buff:IsPurgable() return false end
function modifier_veerah_killer_instinct_lua_buff:GetEffectName() return "particles/units/heroes/hero_drow/drow_marksmanship.vpcf" end
function modifier_veerah_killer_instinct_lua_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_veerah_killer_instinct_lua_buff:OnCreated()
if not IsServer() then return end
	self.ms_bonus = self:GetAbility():GetSpecialValueFor("ms_bonus")
	self.as_bonus = self:GetAbility():GetSpecialValueFor("as_bonus")
	if not IsServer() then return 
	self:GetParent():CalculateStatBonus( true )
end
	ParticleManager:CreateParticle("particles/units/heroes/hero_drow/drow_marksmanship_start.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
end

function modifier_veerah_killer_instinct_lua_buff:OnRefresh()

	self.ms_bonus = self:GetAbility():GetSpecialValueFor("ms_bonus")
	self.as_bonus = self:GetAbility():GetSpecialValueFor("as_bonus")
	if not IsServer() then return 
	self:GetParent():CalculateStatBonus( true )
end
end

function modifier_veerah_killer_instinct_lua_buff:DeclareFunctions()
	local funcs = 	{ 
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK,
	}
return funcs

end

function modifier_veerah_killer_instinct_lua_buff:GetModifierMoveSpeedBonus_Constant(  )
	if self:GetCaster():PassivesDisabled() then return end 
	return self.ms_bonus
end

function modifier_veerah_killer_instinct_lua_buff:GetModifierAttackSpeedBonus_Constant(  )
	if self:GetCaster():PassivesDisabled() then return end 
	return self.as_bonus
end

function modifier_veerah_killer_instinct_lua_buff:OnAttack( params )
	if params.attacker == self:GetParent() then 
		local duration = self:GetAbility():GetSpecialValueFor("duration")
		local chance = self:GetAbility():GetSpecialValueFor("chance_pct") + self:GetCaster():GetTalentValue("special_bonus_unquie_bleed_chance")
	if RollPseudoRandom(chance, self:GetAbility()) then
		params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_status_bleed", {duration = duration})
	end
end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
modifier_shard_evasion = class({})

modifier_shard_evasion = class({})
function modifier_shard_evasion:IsHidden() return false end
function modifier_shard_evasion:IsPurgable() return false end
function modifier_shard_evasion:GetEffectName() return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_blur.vpcf" end
function modifier_shard_evasion:GetEffectAttachType(  )
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_shard_evasion:OnCreated()
if not IsServer() then return end

end

function modifier_shard_evasion:OnRefresh()
if not IsServer() then return end
end

function modifier_shard_evasion:DeclareFunctions()
return
	{
		MODIFIER_PROPERTY_EVASION_CONSTANT,
	}
end

function modifier_shard_evasion:GetModifierEvasion_Constant()
	return 50
end