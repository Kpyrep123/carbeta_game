spike_heal = class({})

ability = spike_heal

LinkLuaModifier( "modifier_spike_heal", "heroes/spike/modifiers/modifier_spike_heal", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_spike_heal_active", "heroes/spike/modifiers/modifier_spike_heal", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function ability:GetIntrinsicModifierName()
    return "modifier_spike_heal"
end

function ability:OnSpellStart()
	local caster = self:GetCaster()

	local duration = self:GetSpecialValueFor("active_duration") + caster:GetTalentValue("special_bonus_unquie_spike_heal_dur")

	caster:AddNewModifier(caster, self, "modifier_spike_heal_active", { duration = duration })
	if caster:HasModifier("modifier_spike_heal_active") then 
		modifier = self:GetCaster():FindModifierByName("modifier_spike_heal_active")
		modifier:SetDuration(modifier:GetRemainingTime() + duration, true)
	end
	self:OnCast()
end

function ability:OnCast()
	local parent = self:GetCaster()

	if IsServer() and parent then
		parent:EmitSound("Hero_Bloodseeker.BloodRite.Cast")
	end

	ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_loadout_arc_pnt.vpcf", PATTACH_OVERHEAD_FOLLOW, parent)
end