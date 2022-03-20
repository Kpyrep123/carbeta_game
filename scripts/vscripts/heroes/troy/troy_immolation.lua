--	Troy's Immolation
--	by Firetoad, 2018.05.24

LinkLuaModifier("modifier_immolation_passive", "heroes/troy/troy_immolation.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_immolation_stacks", "heroes/troy/troy_immolation.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_immolation_count", "heroes/troy/troy_immolation.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_immolation_burn", "heroes/troy/troy_immolation.lua", LUA_MODIFIER_MOTION_NONE)

troy_immolation = class({})

-------------------------------

function troy_immolation:GetIntrinsicModifierName() return "modifier_immolation_passive" end

-------------------------------

modifier_immolation_passive = class({})

function modifier_immolation_passive:IsHidden() return true end
function modifier_immolation_passive:IsDebuff() return false end
function modifier_immolation_passive:IsPurgable() return false end

function modifier_immolation_passive:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("tick_interval"))
	end
end

function modifier_immolation_passive:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local ability = self:GetAbility()
		local tick_interval = ability:GetSpecialValueFor("tick_interval")
		local damage = 0

		-- Special Armlet hp removal interaction. Degen value is hardcoded.
		if not caster:IsIllusion() and caster:HasModifier("modifier_item_armlet_unholy_strength") then
			local duration = ability:GetSpecialValueFor("duration") + caster:GetTalentValue("special_bonus_troy_immolation_duration")
			caster:AddNewModifier(caster, ability, "modifier_immolation_stacks", {duration = duration}):SetStackCount(54 * tick_interval)
		end

		if caster:HasModifier("modifier_immolation_count") then
			local modifier = caster:FindModifierByName("modifier_immolation_count")
			damage = modifier:GetStackCount()

			if modifier.burn_pfx then 
				ParticleManager:SetParticleControl(modifier.burn_pfx, 2, Vector(1, 0, 0))
			end

			damage = damage * tick_interval
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius") + caster:GetTalentValue("special_bonus_troy_immolation_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				ApplyDamage({victim = enemy, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})

				-- Enemy burn particle modifier
				enemy:AddNewModifier(caster, ability, "modifier_immolation_burn", {duration = tick_interval + 0.1, damage = damage})
			end

		end
	end
end

function modifier_immolation_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function modifier_immolation_passive:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_regen")
end

function modifier_immolation_passive:OnTakeDamage(keys)
	if IsServer() then
		if keys.unit == self:GetParent() then
			local caster = self:GetParent()
			local ability = self:GetAbility()
			if caster and caster:IsAlive() then
				local duration = ability:GetSpecialValueFor("duration") + caster:GetTalentValue("special_bonus_troy_immolation_duration")
				caster:AddNewModifier(caster, ability, "modifier_immolation_stacks", {duration = duration}):SetStackCount(keys.original_damage)
			end
		end
	end
end

-------------------------------

modifier_immolation_stacks = class({})

function modifier_immolation_stacks:IsHidden() return true end
function modifier_immolation_stacks:IsDebuff() return false end
function modifier_immolation_stacks:IsPurgable() return false end
function modifier_immolation_stacks:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_immolation_stacks:OnCreated(keys)
	if IsServer() then
		local caster = self:GetParent()
		local ability = self:GetAbility()

		-- Calculate duration
		local duration = ability:GetSpecialValueFor("duration") + caster:GetTalentValue("special_bonus_troy_immolation_duration")

		-- Calculate total stacks
		Timers:CreateTimer(0.03, function()
			local damage = 0
			local stack_modifiers = caster:FindAllModifiersByName("modifier_immolation_stacks")
			for _, modifier in pairs(stack_modifiers) do
				damage = damage + modifier:GetStackCount() * ability:GetSpecialValueFor("dps_return") * 0.01 
			end
			caster:AddNewModifier(caster, ability, "modifier_immolation_count", {duration = duration}):SetStackCount(math.min(damage, ability:GetSpecialValueFor("damage_cap") + caster:GetTalentValue("special_bonus_troy_immolation_dps")))
		end)
	end
end

function modifier_immolation_stacks:OnDestroy()
	if IsServer() then
		if self:GetParent():HasModifier("modifier_immolation_stacks") then
			local caster = self:GetParent()
			local ability = self:GetAbility()
			local damage = 0
			local stack_modifiers = caster:FindAllModifiersByName("modifier_immolation_stacks")
			for _, modifier in pairs(stack_modifiers) do
				damage = damage + modifier:GetStackCount() * ability:GetSpecialValueFor("dps_return") * 0.01
			end
			caster:FindModifierByName("modifier_immolation_count"):SetStackCount(math.min(damage, ability:GetSpecialValueFor("damage_cap") + caster:GetTalentValue("special_bonus_troy_immolation_dps")))

		else
			self:GetParent():RemoveModifierByName("modifier_immolation_count")
		end
	end
end

-------------------------------

modifier_immolation_count = class({})

function modifier_immolation_count:IsHidden() return false end
function modifier_immolation_count:IsDebuff() return false end
function modifier_immolation_count:IsPurgable() return false end

function modifier_immolation_count:OnDestroy()
	if IsServer() then

	end
end

-------------------------------

modifier_immolation_burn = class({})

function modifier_immolation_burn:IsHidden() return true end
function modifier_immolation_burn:IsDebuff() return true end
function modifier_immolation_burn:IsPurgable() return true end

function modifier_immolation_burn:OnCreated(keys)
	if IsServer() then
		self.burn_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_troy/troy_fort_burn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.burn_pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.burn_pfx, 2, Vector(1, 1, 1))
		ParticleManager:SetParticleControl(self.burn_pfx, 4, self:GetCaster():GetAbsOrigin())
	end
end

function modifier_immolation_burn:OnRefresh(keys)
	if IsServer() then
		if self.burn_pfx then 
			ParticleManager:SetParticleControl(self.burn_pfx, 4, self:GetCaster():GetAbsOrigin())
			ParticleManager:SetParticleControl(self.burn_pfx, 2, Vector(1, 1, 1))
		end
	end
end

function modifier_immolation_burn:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.burn_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.burn_pfx)
	end
end