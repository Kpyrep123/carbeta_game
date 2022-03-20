mifune_zanmato = class({})

LinkLuaModifier("modifier_zanmato","heroes/mifune/mifune_zanmato",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_zanmato_debuff","heroes/mifune/mifune_zanmato",LUA_MODIFIER_MOTION_NONE)

function mifune_zanmato:GetIntrinsicModifierName()
	return "modifier_zanmato"
end



modifier_zanmato = class({})

function modifier_zanmato:IsDebuff() return false end
function modifier_zanmato:IsHidden() return true end
function modifier_zanmato:IsPurgable() return false end

function modifier_zanmato:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_zanmato:OnAttackLanded(keys)
	if IsServer() then
		if keys.attacker == self:GetParent() and self:GetAbility():IsCooldownReady() and keys.attacker:GetTeam() ~= keys.target:GetTeam() and (not keys.target:IsBuilding()) then

			-- Put the ability on cooldown
			self:GetAbility():UseResources(true, true, true)

			-- Minislow
			local duration = self:GetAbility():GetSpecialValueFor("slow_duration") + self:GetParent():GetTalentValue("special_bonus_mifune_7")
			keys.target:AddNewModifier(keys.attacker, self:GetAbility(), "modifier_zanmato_debuff", {duration = duration *(1 - keys.target:GetStatusResistance())})

			-- Damage
			local damage = self:GetAbility():GetSpecialValueFor("bonus_damage") + keys.attacker:GetTalentValue("special_bonus_mifune_3")
			local actual_damage = ApplyDamage({victim = keys.target, attacker = keys.attacker, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})

			-- Effects
			local slash_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mifune/new_zanmato_slash.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
			ParticleManager:SetParticleControl(slash_pfx, 0, keys.target:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(slash_pfx)

			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, keys.target, actual_damage, nil)
			keys.target:EmitSound("Hero_Mifune.Zanmato.Slash"..RandomInt(1, 6))
		end
	end
end



modifier_zanmato_debuff = class({})

function modifier_zanmato_debuff:IsDebuff() return true end
function modifier_zanmato_debuff:IsHidden() return false end
function modifier_zanmato_debuff:IsPurgable() return true end

function modifier_zanmato_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_zanmato_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow_amount")
end