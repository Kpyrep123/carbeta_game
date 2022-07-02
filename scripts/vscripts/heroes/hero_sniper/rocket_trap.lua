widow_trap = widow_trap or class({})



function widow_trap:GetAOERadius()
	local caster = self:GetCaster()
	local ability = self


	local trigger_range = ability:GetSpecialValueFor("radius")
	local mine_distance = ability:GetSpecialValueFor("mine_distance")

	-- #1 Talent: Trigger range increase
	trigger_range = trigger_range

	return trigger_range + mine_distance
end

function widow_trap:GetBehavior(  )
	return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
end

function widow_trap:CastFilterResultLocation()
		-- Ability properties
	
		local caster = self:GetCaster()
		local ability = self
		local location = self:GetCursorPosition()
		local player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())

		-- Ability specials
		local mine_distance = ability:GetSpecialValueFor("mine_distance")
		local trigger_range = ability:GetSpecialValueFor("radius")

		-- #1 Talent: Trigger range increase
		trigger_range = trigger_range

		-- Radius
		local radius = mine_distance + trigger_range

		-- Look for nearby mines
		local friendly_units = FindUnitsInRadius(caster:GetTeamNumber(),
												location,
												nil,
												radius,
												DOTA_UNIT_TARGET_TEAM_BOTH,
												DOTA_UNIT_TARGET_ALL,
												DOTA_UNIT_TARGET_FLAG_NONE,
												FIND_CLOSEST,
												true)

		local mine_found = false

		-- Search and see if mines were found
		for _,unit in pairs(friendly_units) do
			local unitName = unit:GetUnitName()
			if unitName == "explosive_mech" then
				mine_found = true
				break
			end
			
		end
		if mine_found then
				return UF_FAIL_CUSTOM
			else
				return UF_SUCCESS
		end

end

function widow_trap:GetCustomCastErrorLocation(location)
	return "Нельзя поставить рядом с миной"
end


function widow_trap:OnSpellStart()

	local duration = self:GetSpecialValueFor("duration")
	local locate = self:GetCursorPosition()
	self.caster = self:GetCaster()
	CreateUnitByNameAsync("explosive_mech", locate, true, self.caster, self.caster, self.caster:GetTeam(), function(traps)
			traps:AddNewModifier(self:GetCaster(), self, "widow_trap_borrow", {duration = duration})
	end)
end

LinkLuaModifier("widow_trap_borrow", "heroes/hero_sniper/rocket_trap.lua", LUA_MODIFIER_MOTION_NONE)

widow_trap_borrow = class({})
function widow_trap_borrow:IsHidden() return false end
function widow_trap_borrow:IsPurgable() return false end
function widow_trap_borrow:GetTexture() return end
function widow_trap_borrow:GetEffectName() return end

function widow_trap_borrow:OnCreated()
	-- self:GetParent():SetModel("models/heroes/nerubian_assassin/mound.vmdl")
	self:GetParent():SetOriginalModel("models/heroes/nerubian_assassin/mound.vmdl")
end

function widow_trap_borrow:OnDestroy()
	-- self:GetParent():SetModel("models/courier/courier_mech/courier_mech.vmdl")
	self:GetParent():SetOriginalModel("models/courier/courier_mech/courier_mech.vmdl")
end

