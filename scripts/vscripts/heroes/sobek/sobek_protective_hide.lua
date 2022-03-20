LinkLuaModifier("modifier_sobek_protective_hide", "heroes/sobek/sobek_protective_hide.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sobek_protective_hide_heal", "heroes/sobek/sobek_protective_hide.lua", LUA_MODIFIER_MOTION_NONE)

sobek_protective_hide = class({})

function sobek_protective_hide:GetIntrinsicModifierName()
    return "modifier_sobek_protective_hide"
end



modifier_sobek_protective_hide = class({})

function modifier_sobek_protective_hide:IsDebuff() return false end
function modifier_sobek_protective_hide:IsPurgable() return false end
function modifier_sobek_protective_hide:IsPurgeException() return false end
function modifier_sobek_protective_hide:IsHidden() return true end

function modifier_sobek_protective_hide:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_sobek_protective_hide:OnTakeDamage(keys)
	if IsServer() then
		if keys.unit == self:GetParent() or keys.attacker == self:GetParent() then
			local ability = self:GetAbility()
			local duration = ability:GetSpecialValueFor("heal_duration")
			local damage_healed = ability:GetSpecialValueFor("damage_healed")

			self:GetParent():AddNewModifier(self:GetParent(), ability, "modifier_sobek_protective_hide_heal", {duration = duration}):SetStackCount(keys.damage * damage_healed / duration)
		end
	end
end



modifier_sobek_protective_hide_heal = class({})

function modifier_sobek_protective_hide_heal:IsDebuff() return false end
function modifier_sobek_protective_hide_heal:IsPurgable() return false end
function modifier_sobek_protective_hide_heal:IsPurgeException() return false end
function modifier_sobek_protective_hide_heal:IsHidden() return true end
function modifier_sobek_protective_hide_heal:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_sobek_protective_hide_heal:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
end

function modifier_sobek_protective_hide_heal:GetModifierConstantHealthRegen()
	return self:GetStackCount() * 0.01
end