mifune_genso = class({})

--local illusion_keys = {
--	outgoing_damage = self:GetAbility():GetSpecialValueFor("illusion_damage"),
--	incoming_damage = self:GetAbility():GetSpecialValueFor("illusion_incoming"),
--	bounty_base = 0,
--	bounty_growth = 2,
--	outgoing_damage_structure = (100 + illusion_damage) * 0.4 - 100,
--	outgoing_damage_roshan = (100 + illusion_damage) * 0.2 - 100
--}

LinkLuaModifier("modifier_genso_chest","heroes/mifune/mifune_genso",LUA_MODIFIER_MOTION_NONE)

function mifune_genso:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function mifune_genso:OnSpellStart()
	local target_loc = self:GetCursorPosition()
	local duration = self:GetSpecialValueFor("duration")
	local health = 3 * self:GetSpecialValueFor("hero_health")
	local caster_team = self:GetCaster():GetTeam()
	local enemy_team = (caster_team == DOTA_TEAM_GOODGUYS and DOTA_TEAM_BADGUYS) or DOTA_TEAM_GOODGUYS

	self:GetCaster():EmitSound("Hero_Mifune.Genso")

	if self:GetCaster().chest_doom and (not self:GetCaster().chest_doom:IsNull()) and self:GetCaster().chest_doom:IsAlive() then self:GetCaster().chest_doom:ForceKill(true) end
	if self:GetCaster().chest_armor and (not self:GetCaster().chest_armor:IsNull()) and self:GetCaster().chest_armor:IsAlive() then self:GetCaster().chest_armor:ForceKill(true) end
	if self:GetCaster().chest_slow and (not self:GetCaster().chest_slow:IsNull()) and self:GetCaster().chest_slow:IsAlive() then self:GetCaster().chest_slow:ForceKill(true) end
	if self:GetCaster().chest_damage and (not self:GetCaster().chest_damage:IsNull()) and self:GetCaster().chest_damage:IsAlive() then self:GetCaster().chest_damage:ForceKill(true) end

	local chest_positions = {}
	chest_positions[1] = target_loc + RandomVector(200)
	chest_positions[2] = RotatePosition(target_loc, QAngle(0, 90, 0), chest_positions[1])
	chest_positions[3] = RotatePosition(target_loc, QAngle(0, 180, 0), chest_positions[1])
	chest_positions[4] = RotatePosition(target_loc, QAngle(0, 270, 0), chest_positions[1])

	local chest_armor = CreateUnitByName("npc_mifune_soul_armor", chest_positions[1], true, nil, self:GetCaster(), self:GetCaster():GetTeam())
	chest_armor:FindAbilityByName("mifune_soul_armor"):SetLevel(self:GetLevel())
	chest_armor:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
	chest_armor:AddNewModifier(self:GetCaster(), self, "modifier_genso_chest", {})
	chest_armor:SetBaseMaxHealth(health)
	chest_armor:SetMaxHealth(health)
	chest_armor:SetHealth(health)
	chest_armor:EmitSound("Hero_Mifune.GensoLoop1")

	local chest_slow = CreateUnitByName("npc_mifune_soul_slow", chest_positions[2], true, nil, self:GetCaster(), self:GetCaster():GetTeam())
	chest_slow:FindAbilityByName("mifune_soul_slow"):SetLevel(self:GetLevel())
	chest_slow:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
	chest_slow:AddNewModifier(self:GetCaster(), self, "modifier_genso_chest", {})
	chest_slow:SetBaseMaxHealth(health)
	chest_slow:SetMaxHealth(health)
	chest_slow:SetHealth(health)
	chest_slow:EmitSound("Hero_Mifune.GensoLoop1")

	local chest_damage = CreateUnitByName("npc_mifune_soul_damage", chest_positions[3], true, nil, self:GetCaster(), self:GetCaster():GetTeam())
	chest_damage:FindAbilityByName("mifune_soul_damage"):SetLevel(self:GetLevel())
	chest_damage:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
	chest_damage:AddNewModifier(self:GetCaster(), self, "modifier_genso_chest", {})
	chest_damage:SetBaseMaxHealth(health)
	chest_damage:SetMaxHealth(health)
	chest_damage:SetHealth(health)
	chest_damage:EmitSound("Hero_Mifune.GensoLoop1")

	local chest_doom = CreateUnitByName("npc_mifune_soul_doom", chest_positions[4], true, nil, self:GetCaster(), self:GetCaster():GetTeam())
	chest_doom:FindAbilityByName("mifune_soul_doom"):SetLevel(self:GetLevel())
	chest_doom:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
	chest_doom:AddNewModifier(self:GetCaster(), self, "modifier_genso_chest", {})
	chest_doom:SetBaseMaxHealth(health)
	chest_doom:SetMaxHealth(health)
	chest_doom:SetHealth(health)
	chest_doom:EmitSound("Hero_Mifune.GensoLoop1")

	chest_armor.other_chests = {}
	table.insert(chest_armor.other_chests, chest_slow)
	table.insert(chest_armor.other_chests, chest_damage)
	table.insert(chest_armor.other_chests, chest_doom)

	chest_slow.other_chests = {}
	table.insert(chest_slow.other_chests, chest_armor)
	table.insert(chest_slow.other_chests, chest_damage)
	table.insert(chest_slow.other_chests, chest_doom)

	chest_damage.other_chests = {}
	table.insert(chest_damage.other_chests, chest_slow)
	table.insert(chest_damage.other_chests, chest_armor)
	table.insert(chest_damage.other_chests, chest_doom)

	chest_doom.other_chests = {}
	table.insert(chest_doom.other_chests, chest_armor)
	table.insert(chest_doom.other_chests, chest_slow)
	table.insert(chest_doom.other_chests, chest_damage)

	if self:GetCaster():HasTalent("special_bonus_mifune_5") then
		chest_armor.curse_pfx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_mifune/shattered_soul_red.vpcf", PATTACH_CUSTOMORIGIN, nil, caster_team)
		ParticleManager:SetParticleControl(chest_armor.curse_pfx, 0, chest_positions[1])
		ParticleManager:SetParticleControl(chest_armor.curse_pfx, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))

		chest_slow.curse_pfx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_mifune/shattered_soul_blue.vpcf", PATTACH_CUSTOMORIGIN, nil, caster_team)
		ParticleManager:SetParticleControl(chest_slow.curse_pfx, 0, chest_positions[2])
		ParticleManager:SetParticleControl(chest_slow.curse_pfx, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))

		chest_damage.curse_pfx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_mifune/shattered_soul.vpcf", PATTACH_CUSTOMORIGIN, nil, caster_team)
		ParticleManager:SetParticleControl(chest_damage.curse_pfx, 0, chest_positions[3])
		ParticleManager:SetParticleControl(chest_damage.curse_pfx, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))

		chest_doom.curse_pfx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_mifune/shattered_soul_black.vpcf", PATTACH_CUSTOMORIGIN, nil, caster_team)
		ParticleManager:SetParticleControl(chest_doom.curse_pfx, 0, chest_positions[4])
		ParticleManager:SetParticleControl(chest_doom.curse_pfx, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))

		chest_armor.curse_fake_pfx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_mifune/shattered_soul_black.vpcf", PATTACH_CUSTOMORIGIN, nil, enemy_team)
		ParticleManager:SetParticleControl(chest_armor.curse_fake_pfx, 0, chest_positions[1])
		ParticleManager:SetParticleControl(chest_armor.curse_fake_pfx, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))

		chest_slow.curse_fake_pfx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_mifune/shattered_soul_black.vpcf", PATTACH_CUSTOMORIGIN, nil, enemy_team)
		ParticleManager:SetParticleControl(chest_slow.curse_fake_pfx, 0, chest_positions[2])
		ParticleManager:SetParticleControl(chest_slow.curse_fake_pfx, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))

		chest_damage.curse_fake_pfx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_mifune/shattered_soul_black.vpcf", PATTACH_CUSTOMORIGIN, nil, enemy_team)
		ParticleManager:SetParticleControl(chest_damage.curse_fake_pfx, 0, chest_positions[3])
		ParticleManager:SetParticleControl(chest_damage.curse_fake_pfx, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))

		chest_doom.curse_fake_pfx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_mifune/shattered_soul_black.vpcf", PATTACH_CUSTOMORIGIN, nil, enemy_team)
		ParticleManager:SetParticleControl(chest_doom.curse_fake_pfx, 0, chest_positions[4])
		ParticleManager:SetParticleControl(chest_doom.curse_fake_pfx, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))
	else
		chest_armor.curse_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mifune/shattered_soul_red.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(chest_armor.curse_pfx, 0, chest_positions[1])
		ParticleManager:SetParticleControl(chest_armor.curse_pfx, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))

		chest_slow.curse_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mifune/shattered_soul_blue.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(chest_slow.curse_pfx, 0, chest_positions[2])
		ParticleManager:SetParticleControl(chest_slow.curse_pfx, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))

		chest_damage.curse_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mifune/shattered_soul.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(chest_damage.curse_pfx, 0, chest_positions[3])
		ParticleManager:SetParticleControl(chest_damage.curse_pfx, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))

		chest_doom.curse_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mifune/shattered_soul_black.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(chest_doom.curse_pfx, 0, chest_positions[4])
		ParticleManager:SetParticleControl(chest_doom.curse_pfx, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))
	end

	chest_armor:SetAngles(-90, 0, 0)
	chest_slow:SetAngles(-90, 0, 0)
	chest_damage:SetAngles(-90, 0, 0)
	chest_doom:SetAngles(-90, 0, 0)

	self:GetCaster().chest_armor = chest_armor
	self:GetCaster().chest_slow = chest_slow
	self:GetCaster().chest_damage = chest_damage
	self:GetCaster().chest_doom = chest_doom
end



modifier_genso_chest = class({})

function modifier_genso_chest:IsDebuff() return false end
function modifier_genso_chest:IsHidden() return true end
function modifier_genso_chest:IsPurgable() return false end

function modifier_genso_chest:CheckState()
	local state = {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true
	}
	return state
end

function modifier_genso_chest:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_genso_chest:OnAttackLanded(keys)
	if IsServer() and keys.target == self:GetParent() then

		local damage = 1 
		if keys.attacker:IsHero() then
			damage = 3
		end

		if keys.target:GetHealth() <= damage then
			keys.target:Kill(nil, keys.attacker)
		else
			keys.target:SetHealth(math.max(1, keys.target:GetHealth() - damage))
		end
	end
end

function modifier_genso_chest:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_genso_chest:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_genso_chest:GetAbsoluteNoDamagePure()
	return 1
end





mifune_soul_armor = class({})

LinkLuaModifier("modifier_genso_armor_aura","heroes/mifune/mifune_genso", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_genso_armor_debuff","heroes/mifune/mifune_genso", LUA_MODIFIER_MOTION_NONE)

function mifune_soul_armor:GetIntrinsicModifierName()
	return "modifier_genso_armor_aura"
end

function mifune_soul_armor:OnOwnerDied()
	if IsServer() then
		local caster = self:GetCaster()

		ParticleManager:DestroyParticle(caster.curse_pfx, false)
		ParticleManager:ReleaseParticleIndex(caster.curse_pfx)

		if caster.curse_fake_pfx then
			ParticleManager:DestroyParticle(caster.curse_fake_pfx, false)
			ParticleManager:ReleaseParticleIndex(caster.curse_fake_pfx)
		end

		local aura_modifiers = {
			"modifier_genso_armor_aura",
			"modifier_genso_slow_aura",
			"modifier_genso_damage_aura",
			"modifier_genso_stats_aura"
		}

		local alive_chests = 0
		for _, chest in pairs(caster.other_chests) do
			for _, modifier_name in pairs(aura_modifiers) do
				if (not chest:IsNull()) and chest:IsAlive() and chest:HasModifier(modifier_name) and chest:FindModifierByName("modifier_kill"):GetRemainingTime() > 0.1 then
					local current_stacks = chest:FindModifierByName(modifier_name):GetStackCount()
					chest:StopSound("Hero_Mifune.GensoLoop"..(1 + current_stacks))
					chest:FindModifierByName(modifier_name):SetStackCount(1 + current_stacks)
					chest:EmitSound("Hero_Mifune.GensoLoop"..(1 + current_stacks))
					alive_chests = alive_chests + 1
				end
			end
		end

		caster:StopSound("Hero_Mifune.GensoLoop1")
		caster:StopSound("Hero_Mifune.GensoLoop2")
		caster:StopSound("Hero_Mifune.GensoLoop3")
		caster:StopSound("Hero_Mifune.GensoLoop4")

		if alive_chests <= 0 then caster:EmitSound("Hero_Mifune.GensoEnd") end

		caster:AddNoDraw()
	end
end



modifier_genso_armor_aura = class({})

function modifier_genso_armor_aura:IsHidden() return true end
function modifier_genso_armor_aura:IsDebuff() return false end
function modifier_genso_armor_aura:IsPurgable() return false end
function modifier_genso_armor_aura:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_genso_armor_aura:IsAura() return true end
function modifier_genso_armor_aura:GetAuraRadius() return self.current_radius or self:GetAbility():GetSpecialValueFor("radius") end
function modifier_genso_armor_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_genso_armor_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_genso_armor_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_genso_armor_aura:GetModifierAura() return "modifier_genso_armor_debuff" end

function modifier_genso_armor_aura:OnCreated(keys)
	if IsServer() then
		self.base_radius = self:GetAbility():GetSpecialValueFor("radius")
		self.current_radius = self.base_radius
		self.radius_increase = self:GetAbility():GetSpecialValueFor("radius_increase") * 0.25
		self.max_radius = self:GetAbility():GetSpecialValueFor("max_radius")
		self.radius_increases = 0

		self:StartIntervalThink(0.25)
	end
end

function modifier_genso_armor_aura:OnIntervalThink()
	if IsServer() then
		if self.current_radius < self.max_radius then
			self.radius_increases = self.radius_increases + 1
		end

		self.current_radius = math.max(100, self.base_radius + self.radius_increases * self.radius_increase)

		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self.current_radius, true)
		ParticleManager:SetParticleControl(self:GetCaster().curse_pfx, 1, Vector(self.current_radius, 0, 0))
		if self:GetCaster().curse_fake_pfx then ParticleManager:SetParticleControl(self:GetCaster().curse_fake_pfx, 1, Vector(self.current_radius, 0, 0)) end
	end
end

function modifier_genso_armor_aura:OnStackCountChanged(iStackCount)
	if IsServer() then
		ParticleManager:SetParticleControl(self:GetCaster().curse_pfx, 3, Vector(self:GetStackCount(), 0, 0))
		if self:GetCaster().curse_fake_pfx then ParticleManager:SetParticleControl(self:GetCaster().curse_fake_pfx, 3, Vector(self:GetStackCount(), 0, 0)) end
	end
end

modifier_genso_armor_debuff = class({})

function modifier_genso_armor_debuff:IsHidden() return false end
function modifier_genso_armor_debuff:IsDebuff() return true end
function modifier_genso_armor_debuff:IsPurgable() return false end
function modifier_genso_armor_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_genso_armor_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end

function modifier_genso_armor_debuff:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("armor_reduction") * 2 ^ (self:GetCaster():GetModifierStackCount("modifier_genso_armor_aura", self:GetCaster()))
end


mifune_soul_slow = class({})

LinkLuaModifier("modifier_genso_slow_aura","heroes/mifune/mifune_genso", LUA_MODIFIER_MOTION_NONE)

function mifune_soul_slow:GetIntrinsicModifierName()
	return "modifier_genso_stats_aura"
end

function mifune_soul_slow:OnOwnerDied()
	if IsServer() then
		local caster = self:GetCaster()

		ParticleManager:DestroyParticle(caster.curse_pfx, false)
		ParticleManager:ReleaseParticleIndex(caster.curse_pfx)

		if caster.curse_fake_pfx then
			ParticleManager:DestroyParticle(caster.curse_fake_pfx, false)
			ParticleManager:ReleaseParticleIndex(caster.curse_fake_pfx)
		end

		local aura_modifiers = {
			"modifier_genso_armor_aura",
			"modifier_genso_slow_aura",
			"modifier_genso_damage_aura",
			"modifier_genso_stats_aura"
		}

		local alive_chests = 0
		for _, chest in pairs(caster.other_chests) do
			for _, modifier_name in pairs(aura_modifiers) do
				if (not chest:IsNull()) and chest:IsAlive() and chest:HasModifier(modifier_name) and chest:FindModifierByName("modifier_kill"):GetRemainingTime() > 0.1 then
					local current_stacks = chest:FindModifierByName(modifier_name):GetStackCount()
					chest:StopSound("Hero_Mifune.GensoLoop"..(1 + current_stacks))
					chest:FindModifierByName(modifier_name):SetStackCount(1 + current_stacks)
					chest:EmitSound("Hero_Mifune.GensoLoop"..(1 + current_stacks))
					alive_chests = alive_chests + 1
				end
			end
		end

		caster:StopSound("Hero_Mifune.GensoLoop1")
		caster:StopSound("Hero_Mifune.GensoLoop2")
		caster:StopSound("Hero_Mifune.GensoLoop3")
		caster:StopSound("Hero_Mifune.GensoLoop4")

		if alive_chests <= 0 then caster:EmitSound("Hero_Mifune.GensoEnd") end

		caster:AddNoDraw()
	end
end

modifier_genso_stats_aura = class({})

function modifier_genso_stats_aura:IsHidden() return true end
function modifier_genso_stats_aura:IsDebuff() return false end
function modifier_genso_stats_aura:IsPurgable() return false end
function modifier_genso_stats_aura:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_genso_stats_aura:IsAura() return true end
function modifier_genso_stats_aura:GetAuraRadius() return self.current_radius or self:GetAbility():GetSpecialValueFor("radius") end
function modifier_genso_stats_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_genso_stats_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_genso_stats_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_genso_stats_aura:GetModifierAura() return "modifier_genso_stats_debuff" end

function modifier_genso_stats_aura:OnCreated(keys)
	if IsServer() then
		self.base_radius = self:GetAbility():GetSpecialValueFor("radius")
		self.current_radius = self.base_radius
		self.radius_increase = self:GetAbility():GetSpecialValueFor("radius_increase") * 0.25
		self.max_radius = self:GetAbility():GetSpecialValueFor("max_radius")
		self.radius_increases = 0

		self:StartIntervalThink(0.25)
	end
end

function modifier_genso_stats_aura:OnIntervalThink()
	if IsServer() then
		if self.current_radius < self.max_radius then
			self.radius_increases = self.radius_increases + 1
		end

		self.current_radius = math.max(100, self.base_radius + self.radius_increases * self.radius_increase)

		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self.current_radius, true)
		ParticleManager:SetParticleControl(self:GetCaster().curse_pfx, 1, Vector(self.current_radius, 0, 0))
		if self:GetCaster().curse_fake_pfx then ParticleManager:SetParticleControl(self:GetCaster().curse_fake_pfx, 1, Vector(self.current_radius, 0, 0)) end
	end
end

function modifier_genso_stats_aura:OnStackCountChanged(iStackCount)
	if IsServer() then
		ParticleManager:SetParticleControl(self:GetCaster().curse_pfx, 3, Vector(self:GetStackCount(), 0, 0))
		if self:GetCaster().curse_fake_pfx then ParticleManager:SetParticleControl(self:GetCaster().curse_fake_pfx, 3, Vector(self:GetStackCount(), 0, 0)) end
	end
end

modifier_genso_stats_debuff = class({})

function modifier_genso_stats_debuff:IsHidden() return false end
function modifier_genso_stats_debuff:IsDebuff() return true end
function modifier_genso_stats_debuff:IsPurgable() return false end
function modifier_genso_stats_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_genso_stats_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_genso_stats_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("ms_slow") * 2 ^ (self:GetCaster():GetModifierStackCount("modifier_genso_stats_aura", self:GetCaster()))
end

mifune_soul_doom = class({})

LinkLuaModifier("modifier_genso_stats_aura","heroes/mifune/mifune_genso", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_genso_stats_debuff","heroes/mifune/mifune_genso", LUA_MODIFIER_MOTION_NONE)

function mifune_soul_doom:GetIntrinsicModifierName()
	return "modifier_genso_slow_aura"
end

function mifune_soul_doom:OnOwnerDied()
	if IsServer() then
		local caster = self:GetCaster()

		ParticleManager:DestroyParticle(caster.curse_pfx, false)
		ParticleManager:ReleaseParticleIndex(caster.curse_pfx)

		if caster.curse_fake_pfx then
			ParticleManager:DestroyParticle(caster.curse_fake_pfx, false)
			ParticleManager:ReleaseParticleIndex(caster.curse_fake_pfx)
		end

		local aura_modifiers = {
			"modifier_genso_armor_aura",
			"modifier_genso_slow_aura",
			"modifier_genso_damage_aura",
			"modifier_genso_stats_aura"
		}

		local alive_chests = 0
		for _, chest in pairs(caster.other_chests) do
			for _, modifier_name in pairs(aura_modifiers) do
				if (not chest:IsNull()) and chest:IsAlive() and chest:HasModifier(modifier_name) and chest:FindModifierByName("modifier_kill"):GetRemainingTime() > 0.1 then
					local current_stacks = chest:FindModifierByName(modifier_name):GetStackCount()
					chest:StopSound("Hero_Mifune.GensoLoop"..(1 + current_stacks))
					chest:FindModifierByName(modifier_name):SetStackCount(1 + current_stacks)
					chest:EmitSound("Hero_Mifune.GensoLoop"..(1 + current_stacks))
					alive_chests = alive_chests + 1
				end
			end
		end

		caster:StopSound("Hero_Mifune.GensoLoop1")
		caster:StopSound("Hero_Mifune.GensoLoop2")
		caster:StopSound("Hero_Mifune.GensoLoop3")
		caster:StopSound("Hero_Mifune.GensoLoop4")

		if alive_chests <= 0 then caster:EmitSound("Hero_Mifune.GensoEnd") end

		caster:AddNoDraw()
	end
end

modifier_genso_slow_aura = class({})

function modifier_genso_slow_aura:IsHidden() return true end
function modifier_genso_slow_aura:IsDebuff() return false end
function modifier_genso_slow_aura:IsPurgable() return false end
function modifier_genso_slow_aura:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_genso_slow_aura:OnCreated(keys)
	if IsServer() then
		self.base_radius = self:GetAbility():GetSpecialValueFor("radius")
		self.current_radius = self.base_radius
		self.radius_increase = self:GetAbility():GetSpecialValueFor("radius_increase") * 0.25
		self.max_radius = self:GetAbility():GetSpecialValueFor("max_radius")
		self.radius_increases = 0

		self.proc_counter = 0
		self.stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")

		self:StartIntervalThink(self.stun_duration)
	end
end

function modifier_genso_slow_aura:OnIntervalThink()
	if IsServer() then
		if self.current_radius < self.max_radius then
			self.radius_increases = self.radius_increases + 1
		end

		self.current_radius = math.max(100, self.base_radius + self.radius_increases * self.radius_increase)

		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self.current_radius, true)
		ParticleManager:SetParticleControl(self:GetCaster().curse_pfx, 1, Vector(self.current_radius, 0, 0))
		if self:GetCaster().curse_fake_pfx then ParticleManager:SetParticleControl(self:GetCaster().curse_fake_pfx, 1, Vector(self.current_radius, 0, 0)) end

		self.proc_counter = self.proc_counter + 1

		if self.proc_counter >= math.max(1, 4 - self:GetStackCount()) then
			self.proc_counter = 0

			local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.current_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				if enemy:IsAlive() and (not enemy:IsMagicImmune()) then
					enemy:EmitSound("Hero_Mifune.GensoStun")
					enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = self.stun_duration *(1 - enemy:GetStatusResistance())})
					return
				end
			end
		end
	end
end

function modifier_genso_slow_aura:OnStackCountChanged(iStackCount)
	if IsServer() then
		ParticleManager:SetParticleControl(self:GetCaster().curse_pfx, 3, Vector(self:GetStackCount(), 0, 0))
		if self:GetCaster().curse_fake_pfx then ParticleManager:SetParticleControl(self:GetCaster().curse_fake_pfx, 3, Vector(self:GetStackCount(), 0, 0)) end
	end
end

mifune_soul_damage = class({})

LinkLuaModifier("modifier_genso_damage_aura","heroes/mifune/mifune_genso", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_genso_damage_debuff","heroes/mifune/mifune_genso", LUA_MODIFIER_MOTION_NONE)

function mifune_soul_damage:GetIntrinsicModifierName()
	return "modifier_genso_damage_aura"
end

function mifune_soul_damage:OnOwnerDied()
	if IsServer() then
		local caster = self:GetCaster()

		ParticleManager:DestroyParticle(caster.curse_pfx, false)
		ParticleManager:ReleaseParticleIndex(caster.curse_pfx)

		if caster.curse_fake_pfx then
			ParticleManager:DestroyParticle(caster.curse_fake_pfx, false)
			ParticleManager:ReleaseParticleIndex(caster.curse_fake_pfx)
		end

		local aura_modifiers = {
			"modifier_genso_armor_aura",
			"modifier_genso_slow_aura",
			"modifier_genso_damage_aura",
			"modifier_genso_stats_aura"
		}

		local alive_chests = 0
		for _, chest in pairs(caster.other_chests) do
			for _, modifier_name in pairs(aura_modifiers) do
				if (not chest:IsNull()) and chest:IsAlive() and chest:HasModifier(modifier_name) and chest:FindModifierByName("modifier_kill"):GetRemainingTime() > 0.1 then
					local current_stacks = chest:FindModifierByName(modifier_name):GetStackCount()
					chest:StopSound("Hero_Mifune.GensoLoop"..(1 + current_stacks))
					chest:FindModifierByName(modifier_name):SetStackCount(1 + current_stacks)
					chest:EmitSound("Hero_Mifune.GensoLoop"..(1 + current_stacks))
					alive_chests = alive_chests + 1
				end
			end
		end

		caster:StopSound("Hero_Mifune.GensoLoop1")
		caster:StopSound("Hero_Mifune.GensoLoop2")
		caster:StopSound("Hero_Mifune.GensoLoop3")
		caster:StopSound("Hero_Mifune.GensoLoop4")

		if alive_chests <= 0 then caster:EmitSound("Hero_Mifune.GensoEnd") end

		caster:AddNoDraw()
	end
end



modifier_genso_damage_aura = class({})

function modifier_genso_damage_aura:IsHidden() return true end
function modifier_genso_damage_aura:IsDebuff() return false end
function modifier_genso_damage_aura:IsPurgable() return false end
function modifier_genso_damage_aura:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_genso_damage_aura:IsAura() return true end
function modifier_genso_damage_aura:GetAuraRadius() return self.current_radius or self:GetAbility():GetSpecialValueFor("radius") end
function modifier_genso_damage_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_genso_damage_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_genso_damage_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_genso_damage_aura:GetModifierAura() return "modifier_genso_damage_debuff" end

function modifier_genso_damage_aura:OnCreated(keys)
	if IsServer() then
		self.base_radius = self:GetAbility():GetSpecialValueFor("radius")
		self.current_radius = self.base_radius
		self.radius_increase = self:GetAbility():GetSpecialValueFor("radius_increase") * 0.25
		self.max_radius = self:GetAbility():GetSpecialValueFor("max_radius")
		self.radius_increases = 0

		self:StartIntervalThink(0.25)
	end
end

function modifier_genso_damage_aura:OnIntervalThink()
	if IsServer() then
		if self.current_radius < self.max_radius then
			self.radius_increases = self.radius_increases + 1
		end

		self.current_radius = math.max(100, self.base_radius + self.radius_increases * self.radius_increase)

		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self.current_radius, true)
		ParticleManager:SetParticleControl(self:GetCaster().curse_pfx, 1, Vector(self.current_radius, 0, 0))
		if self:GetCaster().curse_fake_pfx then	ParticleManager:SetParticleControl(self:GetCaster().curse_fake_pfx, 1, Vector(self.current_radius, 0, 0)) end
	end
end

function modifier_genso_damage_aura:OnStackCountChanged(iStackCount)
	if IsServer() then
		ParticleManager:SetParticleControl(self:GetCaster().curse_pfx, 3, Vector(self:GetStackCount(), 0, 0))
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_mifune/shattered_soul_pulse.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle)

		if self:GetCaster().curse_fake_pfx then	ParticleManager:SetParticleControl(self:GetCaster().curse_fake_pfx, 3, Vector(self:GetStackCount(), 0, 0)) end
	end
end

modifier_genso_damage_debuff = class({})

function modifier_genso_damage_debuff:IsHidden() return false end
function modifier_genso_damage_debuff:IsDebuff() return true end
function modifier_genso_damage_debuff:IsPurgable() return false end
function modifier_genso_damage_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_genso_damage_debuff:OnCreated(keys)
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_genso_damage_debuff:OnIntervalThink()
	if IsServer() then
		local original_hero = self:GetCaster():GetOwnerEntity()
		local damage = 0.5 * self:GetAbility():GetSpecialValueFor("dps") * 2 ^ (self:GetCaster():GetModifierStackCount("modifier_genso_damage_aura", self:GetCaster()))

		if original_hero then
			ApplyDamage({victim = self:GetParent(), attacker = original_hero, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self:GetParent(), damage, nil)
		end
	end
end