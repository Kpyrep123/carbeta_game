LinkLuaModifier("modifier_mana_eater_passive", "scripts/vscripts/heroes/warp_beast/warp_beast_mana_eater.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mana_eater_bonus_mana_count", "scripts/vscripts/heroes/warp_beast/warp_beast_mana_eater.lua", LUA_MODIFIER_MOTION_NONE)


warp_beast_mana_eater = class({})

function warp_beast_mana_eater:GetIntrinsicModifierName()
	return "modifier_mana_eater_passive"
end

modifier_mana_eater_passive = class({})

function modifier_mana_eater_passive:IsHidden()
	return true
end

function modifier_mana_eater_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function modifier_mana_eater_passive:OnAttackLanded(keys)
	if keys.attacker and keys.attacker == self:GetParent() then
		local caster = self:GetParent()
		local unit = keys.target

		local drainAmount = self:GetAbility():GetSpecialValueFor("drain_amount") + caster:GetTalentValue("special_bonus_unique_warp_beast_mana_eater")
		local targetMana = unit:GetMana()
		
		local missingMana = caster:GetMaxMana() - caster:GetMana()
		if missingMana < drainAmount then
			local modifier = caster:FindModifierByName("modifier_mana_eater_bonus_mana_count")
			if modifier then 
				modifier:SetStackCount(math.min(modifier:GetStackCount() + drainAmount - missingMana, self:GetAbility():GetSpecialValueFor("bonus_mana_cap")))
			else 
				modifier = caster:AddNewModifier(caster, self:GetAbility(), "modifier_mana_eater_bonus_mana_count", {})
				if modifier then modifier:SetStackCount(math.min(drainAmount - missingMana, self:GetAbility():GetSpecialValueFor("bonus_mana_cap"))) end
			end
			caster:CalculateStatBonus( true )
		end

		caster:GiveMana(drainAmount)

		unit:EmitSound("Hero_Warp_Beast.ManaEater")

		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_warp_beast/warp_beast_mana_eater.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
		ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_eye_l", Vector(), true)
	end
end

function modifier_mana_eater_passive:OnDeath(keys)
	if not IsServer() then return end

	if keys.attacker and keys.attacker == self:GetParent() and not keys.attacker:PassivesDisabled() then
		local caster = self:GetParent()
		local unit = keys.unit

		local drainAmount = self:GetAbility():GetSpecialValueFor("kill_drain_percentage") * unit:GetMaxMana() / 100
		local targetMana = unit:GetMana()

		local missingMana = caster:GetMaxMana() - caster:GetMana()
		if missingMana < drainAmount then
			local modifier = caster:FindModifierByName("modifier_mana_eater_bonus_mana_count")
			if modifier then 
				modifier:SetStackCount(math.min(modifier:GetStackCount() + drainAmount - missingMana, self:GetAbility():GetSpecialValueFor("bonus_mana_cap")))
			else 
				modifier = caster:AddNewModifier(caster, self:GetAbility(), "modifier_mana_eater_bonus_mana_count", {})
				if modifier then modifier:SetStackCount(math.min(drainAmount - missingMana, self:GetAbility():GetSpecialValueFor("bonus_mana_cap"))) end
			end
			caster:CalculateStatBonus( true )
		end

		unit:ReduceMana(drainAmount)
		caster:GiveMana(drainAmount)
	end
end

modifier_mana_eater_bonus_mana_count = class({})

function modifier_mana_eater_bonus_mana_count:IsHidden() return false end
function modifier_mana_eater_bonus_mana_count:IsDebuff() return false end
function modifier_mana_eater_bonus_mana_count:IsPurgable() return false end

function modifier_mana_eater_bonus_mana_count:DeclareFunctions() 
	local funcs = {
		MODIFIER_PROPERTY_EXTRA_MANA_BONUS,
		MODIFIER_EVENT_ON_SPENT_MANA
	}
	return funcs
end

function modifier_mana_eater_bonus_mana_count:GetModifierExtraManaBonus()
	return self:GetStackCount()
end

function modifier_mana_eater_bonus_mana_count:OnSpentMana(keys)
	if IsServer() then 
		-- for k,v in pairs(keys) do 
		-- 	print(k,v)
		-- end
		if keys.unit == self:GetParent() then 
			local caster = self:GetParent()
			local manaCost = keys.cost
			local restoreAmount = manaCost

			if restoreAmount > self:GetStackCount() then 
				self:Destroy()
			else
				self:SetStackCount(self:GetStackCount() - restoreAmount)
			end
		end
	end
end
