LinkLuaModifier("modifier_tering_think", "heroes/spike/tearing_blow.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tering_regen", "heroes/spike/tearing_blow.lua", LUA_MODIFIER_MOTION_NONE)
ability_spike_tearing_blow = class({})

function ability_spike_tearing_blow:OnSpellStart(  )
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	local ability = self
	local ability_level = self:GetLevel() - 1
	local duration = self:GetSpecialValueFor("duration")
	target:EmitSound("Hero_Bloodseeker.BloodRite.Cast")
	target:AddNewModifier(caster, self, "modifier_tering_think", {duration = (duration + self:GetCaster():GetTalentValue("special_bonus_unquie_blow_dur")) * (1 - target:GetStatusResistance())})
	if target:HasModifier("modifier_tering_think") then 
		local modifier = target:FindModifierByName("modifier_tering_think") 
		modifier:SetStackCount(modifier:GetStackCount() + 1)
		modifier:SetDuration((modifier:GetRemainingTime() + duration) * (1 - target:GetStatusResistance()), true)
	end
end

modifier_tering_think = class({})

function modifier_tering_think:OnCreated()


end

modifier_tering_think = class({})
function modifier_tering_think:IsHidden() return false end
function modifier_tering_think:IsPurgable() return true end
function modifier_tering_think:GetTexture() return "custom/azura_gaze_of_exile" end
function modifier_tering_think:GetEffectName() return "particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_ti7_overhead_vision_model.vpcf" end
function modifier_tering_think:GetEffectAttachType(  ) return PATTACH_OVERHEAD_FOLLOW end
function modifier_tering_think:GetStatusEffectName(  ) return "particles/status_fx/status_effect_rupture_lv.vpcf" end

function modifier_tering_think:OnCreated()
if not IsServer() then return end
	self:StartIntervalThink(0.5)
	self:OnIntervalThink()
end

function modifier_tering_think:OnRefresh()
 if not IsServer() then return end
 	self:StartIntervalThink(0.5)
	self:OnIntervalThink()
end

function modifier_tering_think:OnIntervalThink()
		local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():GetTalentValue("special_bonus_unquie_blow_dmg") * self:GetStackCount()
		ApplyDamage({
		    victim = self:GetParent(),
		    attacker = self:GetCaster(),
		    damage = damage,
		    damage_type = DAMAGE_TYPE_MAGICAL,
		    damage_flags = DOTA_DAMAGE_FLAG_NONE,
		    ability = self:GetAbility()
	  	})
	  	AddFOWViewer( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), 300, 1, true)
		local particle = ParticleManager:CreateParticle("particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok_ribbon.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		self:GetParent():EmitSound("Hero_Bloodseeker.Pick")
		local staks = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_tering_regen", {duration = 1})
		staks:SetStackCount(staks:GetStackCount() + 1)	
end

function modifier_tering_think:DeclareFunctions()
return
	{
		MODIFIER_STATE_PROVIDES_VISION
	}
end

modifier_tering_regen = class({})
function modifier_tering_regen:IsHidden() return false end
function modifier_tering_regen:IsPurgable() return false end
function modifier_tering_regen:GetTexture() return end
function modifier_tering_regen:GetEffectName() return end

function modifier_tering_regen:OnCreated()
	self.regen_amp = self:GetAbility():GetSpecialValueFor("regen_amp")
end

function modifier_tering_regen:OnRefresh()
	self.regen_amp = self:GetAbility():GetSpecialValueFor("regen_amp")
end

function modifier_tering_regen:DeclareFunctions()
return
	{
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
	}
end

function modifier_tering_regen:GetModifierHPRegenAmplify_Percentage(  )
	return self.regen_amp * self:GetStackCount()
end