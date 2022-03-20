Defeated_satellite = class({})	
LinkLuaModifier( "modifier_soul_collection", 						"heroes/deus_novus/modifiers/modifier_soul_collection.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_soul_collection", 						"heroes/deus_novus/modifiers/modifier_soul_collection.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_soul_collection_incriment", 				"heroes/deus_novus/modifiers/modifier_soul_collection.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_soul_collection_incriment_damage", 		"heroes/deus_novus/modifiers/modifier_soul_collection.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_soul_collection_incriment_satellite", 	"heroes/deus_novus/modifiers/modifier_soul_collection.lua" ,LUA_MODIFIER_MOTION_NONE )

function Defeated_satellite:GetIntrinsicModifierName()
	return "modifier_soul_collection"
end

function Defeated_satellite:OnSpellStart()
	local satellite = self:GetCaster():FindModifierByName("modifier_soul_collection_incriment_satellite")
	local stacks = self:GetCaster():FindModifierByName("modifier_soul_collection_incriment_damage")
	local radius = self:GetSpecialValueFor("aura_radius")
	local damage = self:GetSpecialValueFor("base_damage")
	local health1 = self:GetSpecialValueFor("hp")
	local health2 = self:GetSpecialValueFor("hp")
	local health3 = self:GetSpecialValueFor("hp")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_soul_collection_incriment_damage", {})
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_soul_collection_incriment_satellite", {})
	Timers:CreateTimer(0.0001, function()
	
	
	if satellite:GetStackCount() == 0 then 
			local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		
			for _,enemy in ipairs(enemies) do

				ApplyDamage({
				    victim = enemy,
				    attacker = self:GetCaster(),
				    damage = damage,
				    damage_type = self:GetAbilityDamageType(),
				    damage_flags = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
				    ability = self
				})
			end
	end
	if satellite:GetStackCount() == 1 then 
		local demon1 = CreateUnitByName("npc_dota_Beelzebul", self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 100, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
		demon1:SetHealth(health1)
		demon1:SetMaxHealth(health1)
		demon1:SetBaseMaxHealth(health1)
	end
	if satellite:GetStackCount() == 2 then 
		local demon1 = CreateUnitByName("npc_dota_Beelzebul", self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 100, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
		local demon2 = CreateUnitByName("npc_dota_Jehannum", RotatePosition(self:GetCaster():GetAbsOrigin(), QAngle(0, 120, 0), self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 100), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
		demon1:SetHealth(health1)
		demon1:SetMaxHealth(health1)
		demon1:SetBaseMaxHealth(health1)
		demon2:SetHealth(health2)
		demon2:SetMaxHealth(health2)
		demon2:SetBaseMaxHealth(health2)

	end
	if satellite:GetStackCount() == 3 then 
		local demon1 = CreateUnitByName("npc_dota_Beelzebul", self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 100, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
		local demon2 = CreateUnitByName("npc_dota_Jehannum", RotatePosition(self:GetCaster():GetAbsOrigin(), QAngle(0, 120, 0), self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 100), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
		local demon3 = CreateUnitByName("npc_dota_asmodeus", RotatePosition(self:GetCaster():GetAbsOrigin(), QAngle(0, -120, 0), self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 100), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
		demon1:SetHealth(health1)
		demon1:SetMaxHealth(health1)
		demon1:SetBaseMaxHealth(health1)
		demon2:SetHealth(health2)
		demon2:SetMaxHealth(health2)
		demon2:SetBaseMaxHealth(health2)
		demon3:SetHealth(health3)
		demon3:SetMaxHealth(health3)
		demon3:SetBaseMaxHealth(health3)
	end
	Timers:CreateTimer(0.0001, function()
		if self:GetCaster():HasModifier("modifier_soul_collection_incriment_satellite") then 
		satellite:SetStackCount(0)
	end
	if self:GetCaster():HasModifier("modifier_soul_collection_incriment_damage") then 
		stacks:SetStackCount(0)
	end

	end)
	end)
end