feral_ghoul_feral_hunt = class({})
LinkLuaModifier("modifier_feral_ghoul_feral_hunt", "custom_abilities/feral_ghoul/feral_ghoul_feral_hunt.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_feral_ghoul_scythe", "custom_abilities/feral_ghoul/feral_ghoul_feral_hunt.lua", LUA_MODIFIER_MOTION_NONE)

function feral_ghoul_feral_hunt:OnSpellStart(  )
	local duration = self:GetSpecialValueFor("duration")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_feral_ghoul_feral_hunt", {duration = duration})
	ParticleManager:CreateParticle("particles/ferral_ghoul/empower_cast_spirit_rig.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	if RollPercentage(50) then 
		EmitSoundOn("laugh", self:GetCaster())
	else
		EmitSoundOn("laugh1", self:GetCaster())
	end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

modifier_feral_ghoul_feral_hunt = class({})
function modifier_feral_ghoul_feral_hunt:IsHidden() return false end
function modifier_feral_ghoul_feral_hunt:IsPurgable() return true end
function modifier_feral_ghoul_feral_hunt:GetEffectName() return "particles/units/heroes/hero_skeletonking/wraith_king_ghosts_ambient.vpcf" end
function modifier_feral_ghoul_feral_hunt:GetEffectAttachType(  )
	return PATTACH_CUSTOMORIGIN
end

function modifier_feral_ghoul_feral_hunt:OnCreated()
	self.chance = self:GetAbility():GetSpecialValueFor("crit_chance") + self:GetCaster():GetTalentValue("special_bonus_unquie_ferral_hunt_chance")
	self.slow = self:GetAbility():GetSpecialValueFor("movement_slow")
	self.as_bonus = self:GetAbility():GetSpecialValueFor("attack_speed_bonus")
end

function modifier_feral_ghoul_feral_hunt:OnRefresh()
	self.chance = self:GetAbility():GetSpecialValueFor("crit_chance") + self:GetCaster():GetTalentValue("special_bonus_unquie_ferral_hunt_chance")
	self.slow = self:GetAbility():GetSpecialValueFor("movement_slow")
	self.as_bonus = self:GetAbility():GetSpecialValueFor("attack_speed_bonus")
end

function modifier_feral_ghoul_feral_hunt:DeclareFunctions()
 local funcs = {
 			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
 			MODIFIER_EVENT_ON_ATTACK,
 			
 }
return funcs
end

function modifier_feral_ghoul_feral_hunt:GetModifierAttackSpeedBonus_Constant()
	return self.as_bonus
end

function modifier_feral_ghoul_feral_hunt:OnAttack( p )
	if p.attacker ~= self:GetParent() then return end
	if p.target:IsMagicImmune() then return end
	if RollPseudoRandom(self.chance, self:GetAbility()) then
		local duration = self:GetAbility():GetSpecialValueFor("duration")
		local mod = p.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_feral_ghoul_hunted", { duration = duration  * (1 - p.target:GetStatusResistance())})
		local sthyce = p.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_feral_ghoul_scythe", { duration = duration  * (1 - p.target:GetStatusResistance())})
		mod:SetStackCount(self.slow)
	end
end



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_feral_ghoul_hunted", "custom_abilities/feral_ghoul/feral_ghoul_feral_hunt.lua", LUA_MODIFIER_MOTION_NONE)
modifier_feral_ghoul_hunted = class({})
function modifier_feral_ghoul_hunted:IsHidden() return false end
function modifier_feral_ghoul_hunted:IsPurgable() return true end
function modifier_feral_ghoul_hunted:GetEffectName() return end

function modifier_feral_ghoul_hunted:OnCreated()
	local think = self:GetAbility():GetSpecialValueFor("duration") / self:GetAbility():GetSpecialValueFor("movement_slow")
	self:OnIntervalThink()
	self:StartIntervalThink(think)
end

function modifier_feral_ghoul_hunted:OnRefresh()

end

function modifier_feral_ghoul_hunted:OnIntervalThink(  )
	if self:GetCaster():HasTalent("special_bonus_unique_ghoul_2") then return end
	local stacks = self:GetStackCount() - 1
	self:SetStackCount(stacks)
end

function modifier_feral_ghoul_hunted:DeclareFunctions()
 local funcs = {
 				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
 }
return funcs
end

function modifier_feral_ghoul_hunted:GetModifierMoveSpeedBonus_Percentage(  )
	return self:GetStackCount() * (-1)
end

modifier_feral_ghoul_scythe = class({})
function modifier_feral_ghoul_scythe:IsHidden() return true end
function modifier_feral_ghoul_scythe:IsPurgable() return true end
function modifier_feral_ghoul_scythe:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_feral_ghoul_scythe:GetEffectName() return end

function modifier_feral_ghoul_scythe:OnCreated()
	self:StartIntervalThink(1)
	self:OnIntervalThink()
end

function modifier_feral_ghoul_scythe:OnRefresh()

end

function modifier_feral_ghoul_scythe:OnIntervalThink(  )
	local damage = self:GetAbility():GetSpecialValueFor("damage_damage") + self:GetCaster():GetTalentValue("special_bonus_unquie_schyce_dmg")
	ParticleManager:CreateParticle("particles/econ/items/pudge/pudge_arcana/wood/pudge_arcana_dismember_hook_b_wood.vpcf", PATTACH_ABSORIGIN, self:GetParent())	
		ApplyDamage({
		    victim = self:GetParent(),
		    attacker = self:GetCaster(),
		    damage = damage,
		    damage_type = DAMAGE_TYPE_MAGICAL,
		    damage_flags = DOTA_DAMAGE_FLAG_NONE,
		    ability = self:GetAbility()
	  	})
	  	self:GetCaster():Heal(damage - self:GetParent():GetMagicalArmorValue(), self:GetAbility())
	  	EmitSoundOn("Hero_Pudge.DismemberSwings", self:GetParent())	
end
