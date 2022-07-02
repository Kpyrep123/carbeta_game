LinkLuaModifier("modifier_status_fire", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_cold", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_toxin", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_electro", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_status_viral", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_corrupt", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_gas", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_explosion", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_radiatoin", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_magnet", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_status_bleed", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_bash", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_piercing", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------PRIMAL____STATUSES-----------------------------------------------------------------------------------
------------------------------------------------------------------------------PRIMAL____STATUSES-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--FIRE_STATUS--

modifier_status_fire = class({})

modifier_status_fire = class({})
function modifier_status_fire:IsHidden() return false end
function modifier_status_fire:IsPurgable() return false end
function modifier_status_fire:GetTexture() return "custom/skeleton_king_hellfire_aura" end
function modifier_status_fire:GetEffectName() return "particles/creatures/aghanim/staff_beam_tgt_fire.vpcf" end

function modifier_status_fire:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_status_fire:OnCreated()
	self.damage = self:GetParent():GetHealth() * 0.02
	self.minusarm = (-1) * 1.0
	self:StartIntervalThink(1)
	self:OnIntervalThink()
	ParticleManager:CreateParticle("particles/phoenix_fire_spirit_ground_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_fire:OnRefresh()
	self.damage = self:GetParent():GetHealth() * 0.02
	self.minusarm = (-1) * 1.0
		if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_fire:DeclareFunctions()
	 local funcs = 	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
return funcs
end

function modifier_status_fire:GetModifierPhysicalArmorBonus(  )
	return self.minusarm * self:GetStackCount()
end

function modifier_status_fire:OnIntervalThink()
	local damage = self.damage * self:GetStackCount()
		ApplyDamage({
		    victim = self:GetParent(),
		    attacker = self:GetCaster(),
		    damage = damage,
		    damage_type = DAMAGE_TYPE_PHYSICAL,
		    damage_flags = DOTA_DAMAGE_FLAG_NONE,
		    ability = self:GetAbility()
	  	})
	  	ParticleManager:CreateParticle("particles/statuses/fire.vpcf", PATTACH_ABSORIGIN, self:GetParent())
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------COLD_STATUS---------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------

modifier_status_cold = class({})
function modifier_status_cold:IsHidden() return false end
function modifier_status_cold:IsPurgable() return false end
function modifier_status_cold:GetTexture() return "wex" end
function modifier_status_cold:GetStatusEffectName() return "particles/status_fx/status_effect_iceblast.vpcf" end


function modifier_status_cold:OnCreated()
	self.ms_slow = -3
	self.as_slow = -15
		if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end


function modifier_status_cold:OnRefresh()
	self.ms_slow = -3
	self.as_slow = -15
		if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_cold:DeclareFunctions()
		local funcs = {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		}
return funcs
end

function modifier_status_cold:GetModifierMoveSpeedBonus_Percentage(  )
	return self:GetStackCount() * self.ms_slow
end

function modifier_status_cold:GetModifierAttackSpeedBonus_Constant(  )
	return self:GetStackCount() * self.as_slow
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------TOXIN_STATUS--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_status_viral", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_status_cold", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
modifier_status_toxin = class({})
function modifier_status_toxin:IsHidden() return false end
function modifier_status_toxin:IsPurgable() return false end
function modifier_status_toxin:GetTexture() return "viper_poison_attack_lua" end
function modifier_status_toxin:GetStatusEffectName() return "particles/status_fx/status_effect_poison_viper.vpcf" end

function modifier_status_toxin:OnCreated()
	self:StartIntervalThink(1)
	self:OnIntervalThink()
		if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_toxin:OnRefresh()
	if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_toxin:OnIntervalThink(  )
	local damage = 5*self:GetParent():GetLevel()*self:GetStackCount()
		ApplyDamage({
		    victim = self:GetParent(),
		    attacker = self:GetCaster(),
		    damage = damage,
		    damage_type = DAMAGE_TYPE_PHYSICAL,
		    damage_flags = DOTA_DAMAGE_FLAG_NONE,
		    ability = self:GetAbility()
	  	})
	SendOverheadEventMessage( nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self:GetParent(), damage, self:GetCaster():GetPlayerOwner() )
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------ELECTRO_STATUS------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_status_electro", "status/statuses.lua", LUA_MODIFIER_MOTION_NONE)
modifier_status_electro = class({})
function modifier_status_electro:IsHidden() return false end
function modifier_status_electro:IsPurgable() return false end
function modifier_status_electro:GetTexture() return "custom/zuus_lightning_bolt_immortal" end
function modifier_status_electro:GetStatusEffectName() return "particles/status_fx/status_effect_electrical.vpcf" end
function modifier_status_electro:GetEffectName(  )
	return "particles/units/heroes/hero_brewmaster/brewmaster_drunken_stance_storm.vpcf"
end
function modifier_status_electro:GetEffectAttachType(  )
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_status_electro:OnCreated()
	if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_electro:OnRefresh()
	if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_electro:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
return funcs
end

function modifier_status_electro:OnTakeDamage( params )
	if params.unit ~= self:GetParent() then return end
	chance = 4 * self:GetStackCount()
	if not RollPercentage(chance) then return end
	self:GetParent():AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = 0.2  * (1 - self:GetParent():GetStatusResistance())})
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------COMBINATE_STATUS-----------------------------------------------------------------------------------
------------------------------------------------------------------------------COMBINATE_STATUS-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------VIRAL_STATUS--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------

modifier_status_viral = class({})
function modifier_status_viral:IsHidden() return false end
function modifier_status_viral:IsPurgable() return false end
function modifier_status_viral:GetTexture() return "selfmade/apostate_passive" end
function modifier_status_viral:GetEffectName() return "particles/statuses/viral.vpcf" end
function modifier_status_viral:GetEffectAttachType(  )
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_status_viral:OnCreated()
	self.incoming = 6
		if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_viral:OnRefresh()
	self.incoming = 6
		if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_viral:DeclareFunctions()
		local funcs = {
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		}
return funcs
end

function modifier_status_viral:GetModifierIncomingDamage_Percentage(  )
	return self:GetStackCount() * self.incoming
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------CORRUPT_STATUS------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------

modifier_status_corrupt = class({})
function modifier_status_corrupt:IsHidden() return false end
function modifier_status_corrupt:IsPurgable() return false end
function modifier_status_corrupt:GetTexture() return "selfmade/lancer_ghost" end
function modifier_status_corrupt:GetStatusEffectName() return "particles/status_fx/status_effect_maledict.vpcf" end

function modifier_status_corrupt:OnCreated()
	self.mag_res = (-1) * 8
		if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_corrupt:OnRefresh()
	self.mag_res = (-1) * 8
		if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_corrupt:DeclareFunctions()
 local funcs = {
 		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
 }
return funcs
end

function modifier_status_corrupt:GetModifierMagicalResistanceBonus(  )
	return self:GetStackCount() * self.mag_res
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------GAS_STATUS----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------

modifier_status_gas = class({})
function modifier_status_gas:IsHidden() return false end
function modifier_status_gas:IsPurgable() return false end
function modifier_status_gas:GetTexture() return "custom/summons_attack_magical" end
function modifier_status_gas:GetEffectName() return "particles/statuses/gas.vpcf" end
function modifier_status_gas:GetEffectAttachType(  )
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_status_gas:OnCreated()
	self:StartIntervalThink(1)
	self:OnIntervalThink()
	if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_gas:OnRefresh()
	if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end


function modifier_status_gas:OnIntervalThink()
	local heroes = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, 400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )

	  	for _,hero in pairs(heroes) do
			ApplyDamage({
		    victim = hero,
		    attacker = self:GetCaster(),
		    damage = 1*self:GetParent():GetLevel() * self:GetStackCount(),
		    damage_type = DAMAGE_TYPE_PHYSICAL,
		    damage_flags = DOTA_DAMAGE_FLAG_NONE,
		    ability = self:GetAbility()
	  	})
	end
end


--------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------EXPLOSION_STATUS----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------

modifier_status_explosion = class({})
function modifier_status_explosion:IsHidden() return false end
function modifier_status_explosion:IsPurgable() return false end
function modifier_status_explosion:GetTexture() return "custom/scaldris_scorch" end
function modifier_status_explosion:GetEffectName() return "particles/ambient/tower_laser_blind.vpcf" end
function modifier_status_explosion:GetEffectAttachType(  )
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_status_explosion:OnCreated()
	self.miss = 6
	self.disarm = (-1) * 1.5
	if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_explosion:OnRefresh()
	self.miss = 6
	self.disarm = (-1) * 1.5
	if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_explosion:DeclareFunctions()
 local funcs = {
 				MODIFIER_PROPERTY_MISS_PERCENTAGE,
 				MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
 }
return funcs
end

function modifier_status_explosion:GetModifierMiss_Percentage(  )
	return self.miss * self:GetStackCount()
end

function modifier_status_explosion:GetModifierPhysicalArmorBonus(  )
	return self.disarm * self:GetStackCount()
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------RAD_STATUS-----------------------------------------------------------------------------------
------------------------------------------------------------------------------RAD_STATUS-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

modifier_status_radiatoin = class({})
function modifier_status_radiatoin:IsHidden() return false end
function modifier_status_radiatoin:IsPurgable() return false end
function modifier_status_radiatoin:GetTexture() return "trueshot" end
function modifier_status_radiatoin:GetEffectName(  )
	return "particles/units/heroes/hero_abaddon/abaddon_curse_frostmourne_debuff.vpcf"
end

function modifier_status_radiatoin:GetEffectAttachType(  )
	return PATTACH_CUSTOMORIGIN
end

function modifier_status_radiatoin:GetStatusEffectName() return "particles/status_fx/status_effect_abaddon_frostmourne.vpcf" end


function modifier_status_radiatoin:OnCreated()
	self.chance = 4
		if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_radiatoin:OnRefresh()
	self.chance = 4
		if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_radiatoin:DeclareFunctions()
 local funcs = {
 			MODIFIER_EVENT_ON_TAKEDAMAGE,
 }
return funcs
end

function modifier_status_radiatoin:OnTakeDamage( p )
	if p.attacker ~= self:GetParent() then return end
	if not IsServer() then return end
	local chance = self.chance * self:GetStackCount()
	local damage_flags	= DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
	if not RollPercentage(chance) then return end
	
		ApplyDamage({
			victim = p.attacker,
			attacker = p.unit,
			damage = p.damage,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags	= DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
		})

end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------MAGNET_STATUS-----------------------------------------------------------------------------------
------------------------------------------------------------------------------MAGNET_STATUS-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

modifier_status_magnet = class({})
function modifier_status_magnet:IsHidden() return false end
function modifier_status_magnet:IsPurgable() return false end
function modifier_status_magnet:GetTexture() return "HotSIcons/DetonateTwistingNether" end
function modifier_status_magnet:GetStatusEffectName() return "particles/status_fx/status_effect_arc_warden_tempest.vpcf" end

function modifier_status_magnet:OnCreated()
	if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_magnet:OnRefresh()
	if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_magnet:DeclareFunctions()
 local funcs = {
 			MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE,
 			MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
 }
return funcs
end

function modifier_status_magnet:GetModifierPercentageManaRegen(  )
	return -4 * self:GetStackCount()
end

function modifier_status_magnet:GetModifierPercentageManacost( )
	return -4 * self:GetStackCount()
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------PHYSICAL_STATUS-----------------------------------------------------------------------------------
------------------------------------------------------------------------------PHYSICAL_STATUS-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

modifier_status_bleed = class({})
function modifier_status_bleed:IsHidden() return false end
function modifier_status_bleed:IsPurgable() return true end
function modifier_status_bleed:GetTexture() return "custom/vowen_from_blood_steal_blood" end
function modifier_status_bleed:GetAttributes()	
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_status_bleed:OnCreated()
if not IsServer() then return end
	self.count = 0
	self.count_max = 7
	self:StartIntervalThink(0.5)
	self:OnIntervalThink()
end

function modifier_status_bleed:OnRefresh()
if not IsServer() then return end
end

function modifier_status_bleed:OnIntervalThink(  )
	if self:GetCaster():IsIllusion() then 
	self.count = self.count + 1
	print(self.count)
	if self.count >= self.count_max then 
		self:Destroy()
	end
	local damage = self:GetCaster():GetAttackDamage() * 0.175
		ApplyDamage({
		    victim = self:GetParent(),
		    attacker = self:GetCaster(),
		    damage = damage,
		    damage_type = DAMAGE_TYPE_MAGICAL,
		    damage_flags = DOTA_DAMAGE_FLAG_NONE,
		    ability = self:GetAbility()
	  	})
	else
	self.count = self.count + 1
	print(self.count)
	if self.count >= self.count_max then 
		self:Destroy()
	end
	local damage = self:GetCaster():GetAttackDamage() * 0.35
		ApplyDamage({
		    victim = self:GetParent(),
		    attacker = self:GetCaster(),
		    damage = damage,
		    damage_type = DAMAGE_TYPE_MAGICAL,
		    damage_flags = DOTA_DAMAGE_FLAG_NONE,
		    ability = self:GetAbility()
	  	})
	end
	ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_shard_hunter_bloodspray_lv.vpcf", PATTACH_ABSORIGIN, self:GetParent())
end

modifier_status_bash = class({})
function modifier_status_bash:IsHidden() return false end
function modifier_status_bash:IsPurgable() return false end
function modifier_status_bash:GetTexture() return "custom/zuus_lightning_bolt_immortal" end
function modifier_status_bash:GetStatusEffectName() return "particles/status_fx/status_effect_electrical.vpcf" end
function modifier_status_bash:GetEffectAttachType(  )
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_status_bash:OnCreated()
	if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_bash:OnRefresh()
	if self:GetStackCount() > 10 then 
		self:SetStackCount(10)
	end
end

function modifier_status_bash:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
return funcs
end

function modifier_status_bash:OnAttackLanded( params )
	if params.target ~= self:GetParent() then return end
	if not params.attacker:IsRealHero() then return end
	chance = 4 * self:GetStackCount()
	if not RollPercentage(chance) then return end
	self:GetParent():AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = 0.7  * (1 - self:GetParent():GetStatusResistance())})
end