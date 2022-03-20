xartoth_artery = class({})
LinkLuaModifier( "xartoth_artery_debuff", "heroes/xartoth/xartoth_artery.lua" ,LUA_MODIFIER_MOTION_NONE )

function xartoth_artery:OnSpellStart(kv)
	if IsServer() then
		local target = self:GetCursorTarget()
		EmitSoundOn("hero_bloodseeker.rupture", target)
		local duration = self:GetSpecialValueFor("duration")
		target:AddNewModifier(self:GetCaster(), self, "xartoth_artery_debuff", {duration = duration})
	end
end

xartoth_artery_debuff = class({})

function xartoth_artery_debuff:IsDebuff() return true end

function xartoth_artery_debuff:IsPurgable() return false end

function xartoth_artery_debuff:OnCreated(kv)
	local caster = self:GetParent()
	self.particle = ParticleManager:CreateParticle("particles/xartotharteryburst_particles/xartoth_artery_burst_blood.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.particle, 1, caster, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", (caster:GetAbsOrigin() + Vector(0,0,55)), true)
	ParticleManager:SetParticleControlEnt(self.particle, 3, caster, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.particle, 4, caster, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.particle, 5, caster, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.particle, 6, caster, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", caster:GetAbsOrigin(), true)
	self:StartIntervalThink(0.03)
end

function xartoth_artery_debuff:OnDestroy(kv)
	ParticleManager:DestroyParticle(self.particle, false)
end

function xartoth_artery_debuff:DeclareFunctions()
	local funcs = {
	MODIFIER_EVENT_ON_ATTACK_LANDED,
	MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function xartoth_artery_debuff:OnAttackLanded(kv)
	if kv.target == self:GetParent() and kv.attacker:IsRealHero() then
		local damage_dealt = kv.target:GetHealth() * self:GetAbility():GetSpecialValueFor("current_hp_damage") * 0.01
		local damageTable = {
			victim = self:GetParent(),
			attacker = kv.attacker,
			damage = damage_dealt,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
			ability = self:GetAbility(), --Optional.
		}

		ApplyDamage(damageTable)
	end
end

function xartoth_artery_debuff:OnDeath(kv)
	if kv.unit == self:GetParent() then
		local caster = self:GetCaster()
		EmitSoundOn("Xartoth.Artery.Heal", caster)
		ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN, caster)
		caster:Heal((caster:GetMaxHealth() * self:GetAbility():GetSpecialValueFor("execute_healing") * 0.01), self:GetAbility())
	end
end

function xartoth_artery_debuff:OnIntervalThink()
	local target = self:GetParent()
	local caster = self:GetCaster()
	local percentage = self:GetAbility():GetSpecialValueFor("execute_health")
	if target:GetHealthPercent() <= percentage then
		target:Kill(self:GetAbility(), self:GetCaster())
	end
end