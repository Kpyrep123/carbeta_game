sobek_voracious_appetite = class({})

LinkLuaModifier('modifier_sobek_voracious_appetite', 'scripts/vscripts/heroes/sobek/modifier_sobek_voracious_appetite.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_sobek_voracious_appetite_debuff', 'scripts/vscripts/heroes/sobek/modifier_sobek_voracious_appetite_debuff.lua', LUA_MODIFIER_MOTION_NONE)

function sobek_voracious_appetite:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()

	caster:StartGesture(ACT_DOTA_SLEEPING_END)

	-- Play particles
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sobek/sobek_voracious_appetite_consume_base.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:ReleaseParticleIndex(particle)

	-- Play sounds
	target:EmitSound("Hero_Koh.Voracious_Appetite.Target")

	particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sobek/sobek_voracious_appetite_consume.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack2", Vector(), true)
	ParticleManager:ReleaseParticleIndex(particle)

	if target:IsHero() or target:IsAncient() then
		target:EmitSound("Hero_Koh.Voracious_Appetite.Hero")

		local talent = caster:FindAbilityByName("special_bonus_unique_sobek_1")
		if talent and talent:GetLevel() > 0 then
			ApplyDamage({victim = target, attacker = caster, damage = target:GetHealth() * self:GetSpecialValueFor("damage") * 0.01, damage_type = DAMAGE_TYPE_PURE})
			target:AddNewModifier(caster, self, 'modifier_sobek_voracious_appetite_debuff', {duration = self:GetSpecialValueFor("slow_duration")})
		else
			if not target:IsMagicImmune() then
				target:AddNewModifier(caster, self, 'modifier_sobek_voracious_appetite_debuff', {duration = self:GetSpecialValueFor("slow_duration")})
			end
			ApplyDamage({victim = target, attacker = caster, damage = target:GetHealth() * self:GetSpecialValueFor("damage") * 0.01, damage_type = DAMAGE_TYPE_PHYSICAL})
		end
	else
		caster:EmitSound("Hero_Koh.Voracious_Appetite.Creep")
		ApplyDamage({victim = target, attacker = caster, damage = target:GetHealth(), damage_type = DAMAGE_TYPE_PURE})
	end

	local str_stacks = self:GetSpecialValueFor("bonus_str")
	local str_modifier = caster:AddNewModifier(caster, self, 'modifier_sobek_voracious_appetite', {})
	str_modifier:SetStackCount(str_modifier:GetStackCount() + str_stacks)
	caster:CalculateStatBonus(true)
end