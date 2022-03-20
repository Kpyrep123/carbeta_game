

LinkLuaModifier("modifier_reaver_lord_soul_devour_debuff", "heroes/reaver_lord/devour_rework.lua", LUA_MODIFIER_MOTION_NONE)

reaver_lord_soul_devour_lua = class({})

function reaver_lord_soul_devour_lua:OnSpellStart(  )
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb(ability) then
		RemoveLinkens(target)
		return
	end
	local duration = self:GetSpecialValueFor("duration") + self:GetCaster():GetTalentValue("special_bonus_unquie_devour_duration")
	target:AddNewModifier(self:GetCaster(), self, "modifier_reaver_lord_soul_devour_debuff", {duration = duration * (1 - target:GetStatusResistance())})
end

modifier_reaver_lord_soul_devour_debuff = class({})

function modifier_reaver_lord_soul_devour_debuff:IsHidden(  )
	return false
end

function modifier_reaver_lord_soul_devour_debuff:IsDebuff(  )
	return true
end

function modifier_reaver_lord_soul_devour_debuff:IsPurgable(  )
	return true
end

function modifier_reaver_lord_soul_devour_debuff:OnCreated(  )
	self.slow = self:GetAbility():GetSpecialValueFor("movespeed_slow")
	self.attack_slow = self:GetAbility():GetSpecialValueFor("attackspeed_slow")
	self.radius = self:GetAbility():GetSpecialValueFor("range")
	self:StartIntervalThink(0.5)
	self:OnIntervalThink()
	EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Hero_Terrorblade.Sunder.Target", self:GetCaster())
	self.particle_drain = "particles/econ/items/lion/lion_demon_drain/lion_spell_mana_drain_demon_beam.vpcf"

	self.particle_drain_fx = ParticleManager:CreateParticle(self.particle_drain, PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.particle_drain_fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)        
	ParticleManager:SetParticleControlEnt(self.particle_drain_fx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_mouth", self:GetCaster():GetAbsOrigin(), true)        
	self:AddParticle(self.particle_drain_fx, false, false, -1, false, false)
end

function modifier_reaver_lord_soul_devour_debuff:OnRefresh(  )
	self.slow = self:GetAbility():GetSpecialValueFor("movespeed_slow")
	self.attack_slow = self:GetAbility():GetSpecialValueFor("attackspeed_slow")
	self.radius = self:GetAbility():GetSpecialValueFor("range")
end

function modifier_reaver_lord_soul_devour_debuff:OnDestroy()
	local max_stacks = self:GetCaster():FindAbilityByName("reaver_lord_soul_collector_lua"):GetSpecialValueFor("max_souls") + self:GetCaster():GetTalentValue("special_bonus_unquie_max_souls_soul_collector")
	local stacks = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetCaster():FindAbilityByName("reaver_lord_soul_collector_lua"), "modifier_reaver_lord_soul_collector_passive_dummy", {duration = self:GetCaster():FindAbilityByName("reaver_lord_soul_collector_lua"):GetSpecialValueFor("soul_duration")})
        if stacks:GetStackCount() < max_stacks then
            stacks:SetStackCount(stacks:GetStackCount() + 1)
            Timers:CreateTimer(self:GetCaster():FindAbilityByName("reaver_lord_soul_collector_lua"):GetSpecialValueFor("soul_duration"), function()
                stacks:SetStackCount(stacks:GetStackCount() - 1)
            end)
        end
end

function modifier_reaver_lord_soul_devour_debuff:OnIntervalThink(  )
	if self:GetParent():IsMagicImmune() or self:GetParent():IsInvulnerable() or self:GetParent():IsIllusion() then
		self:Destroy()
		return
	end

	if (self:GetParent():GetOrigin()-self:GetCaster():GetOrigin()):Length2D()>(self.radius + self:GetCaster():GetTalentValue("special_bonus_unquie_devour_range")) then
		self:Destroy()
		return
	end


	local damage = self:GetAbility():GetSpecialValueFor("dps")
	local damage_pct = (self:GetAbility():GetSpecialValueFor("damage_pct") * self:GetParent():GetHealth()) / 100
	local total_damage = damage + damage_pct
	ApplyDamage({
		    victim = self:GetParent(),
		    attacker = self:GetCaster(),
		    damage = total_damage,
		    damage_type = self:GetAbility():GetAbilityDamageType(),
		    damage_flags = DOTA_DAMAGE_FLAG_NONE,
		    ability = self:GetAbility()
	  	})
end

function modifier_reaver_lord_soul_devour_debuff:DeclareFunctions(  )
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_reaver_lord_soul_devour_debuff:OnTakeDamage( params )
	if not params.target == self:GetParent() then return end
	self:GetCaster():Heal((params.damage * self:GetAbility():GetSpecialValueFor("heal_factor")) / 100, self:GetAbility())

	local particle_heal = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster())
end
function modifier_reaver_lord_soul_devour_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movespeed_slow")
end

function modifier_reaver_lord_soul_devour_debuff:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attackspeed_slow")
end

