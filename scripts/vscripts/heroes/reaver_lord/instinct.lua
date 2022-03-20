LinkLuaModifier("reaver_lord_superiority_instinct_modifier_lua", "heroes/reaver_lord/instinct.lua", LUA_MODIFIER_MOTION_NONE)

reaver_lord_superiority_instinct_lua = class({})

function reaver_lord_superiority_instinct_lua:GetIntrinsicModifierName()
	return "reaver_lord_superiority_instinct_modifier_lua"
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
reaver_lord_superiority_instinct_modifier_lua = class({})

function reaver_lord_superiority_instinct_modifier_lua:IsHidden(  )
	return true
end

function reaver_lord_superiority_instinct_modifier_lua:OnCreated(  )
	self.lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal") + self:GetCaster():GetTalentValue("special_bonus_unquie_instinct_lifesteal")
	self.dmg_pct = self:GetAbility():GetSpecialValueFor("damage_pct") + self:GetCaster():GetTalentValue("special_bonus_unquie_instinct_damage")
end

function reaver_lord_superiority_instinct_modifier_lua:OnRefresh(  )
	self.lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal") + self:GetCaster():GetTalentValue("special_bonus_unquie_instinct_lifesteal")
	self.dmg_pct = self:GetAbility():GetSpecialValueFor("damage_pct") + self:GetCaster():GetTalentValue("special_bonus_unquie_instinct_damage")
end

function reaver_lord_superiority_instinct_modifier_lua:DeclareFunctions(  )
	return {
		MODIFIER_EVENT_ON_ATTACK,
	}
end

function reaver_lord_superiority_instinct_modifier_lua:OnAttack( params )
	if not IsServer() then return end
    if self:GetCaster() ~= params.attacker then return end
    if self:GetCaster():IsIllusion() then return end
    if params.target:IsMagicImmune() then return end
    if params.target:IsBuilding() then return end
    if self:GetCaster():PassivesDisabled() then return end

    hero_hp = self:GetCaster():GetHealth()
    enemy_hp = params.target:GetHealth()
    local heal = ((hero_hp - enemy_hp) * self.lifesteal) / 100
    local damage = ((hero_hp - enemy_hp) * self.dmg_pct) / 100
    if self:GetCaster():GetHealth() > params.target:GetHealth() then
    	ApplyDamage({
    	    victim = params.target,
    	    attacker = self:GetCaster(),
    	    damage = damage,
    	    damage_type = DAMAGE_TYPE_PURE,
    	    damage_flags = DOTA_DAMAGE_FLAG_NONE,
    	    ability = self:GetAbility()
      	})
    	self:GetCaster():Heal(heal, self:GetCaster())
    	local particle = ParticleManager:CreateParticle("particles/vampiremistressbloodsuckheal_particles/vampire_bloodsuck_heal.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
    	local terget_part = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_mirror_image_c.vpcf", PATTACH_ABSORIGIN, params.target)
    	SendOverheadEventMessage(params.target, OVERHEAD_ALERT_DAMAGE, params.target, damage, self:GetCaster())
	else
		return nil 
	end
end