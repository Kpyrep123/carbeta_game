--	Dragon Knight modifications
--	Concept" SUNSfan
--	Implementation: Firetoad
--	2018.07.13

--------------------------------------
--	PERMA AGHS MODIFIER
--------------------------------------

modifier_dragon_knight_aghs = class({})

function modifier_dragon_knight_aghs:IsHidden() return true end
function modifier_dragon_knight_aghs:IsDebuff() return false end
function modifier_dragon_knight_aghs:IsPurgable() return false end
function modifier_dragon_knight_aghs:IsPermanent() return true end

function modifier_dragon_knight_aghs:OnCreated(keys)
	if IsServer() then
		self.dragon_level = 0
		self:StartIntervalThink(0.2)
	end
end

function modifier_dragon_knight_aghs:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local dragon_form_ability = caster:FindAbilityByName("dragon_knight_elder_dragon_form")

		-- If the caster has no aghs, do nothing
		if caster:HasScepter() then

			-- Deactivate the ability if needed
			if dragon_form_ability:IsActivated() then
				dragon_form_ability:SetActivated(false)
			end

			-- On dragon form level up, update it
			if dragon_form_ability and dragon_form_ability:GetLevel() > self.dragon_level then
				self.dragon_level = self.dragon_level + 1
				caster:RemoveModifierByName("modifier_dragon_knight_dragon_form")
				caster:RemoveModifierByName("modifier_dragon_knight_corrosive_breath")
				caster:RemoveModifierByName("modifier_dragon_knight_splash_attack")
				caster:RemoveModifierByName("modifier_dragon_knight_frost_breath")
			end

			-- Constantly apply the modifier if needed
			if dragon_form_ability:GetLevel() > 0 and not caster:HasModifier("modifier_dragon_knight_dragon_form") then
				caster:AddNewModifier(caster, dragon_form_ability, "modifier_dragon_knight_dragon_form", {})
			end
		end
	end
end