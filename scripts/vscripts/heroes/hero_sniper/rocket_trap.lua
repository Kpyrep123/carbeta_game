widow_trap = widow_trap or class({})



function widow_trap:GetAOERadius()
	local caster = self:GetCaster()
	local ability = self


	local trigger_range = ability:GetSpecialValueFor("radius")
	local mine_distance = ability:GetSpecialValueFor("mine_distance")

	-- #1 Talent: Trigger range increase
	trigger_range = trigger_range

	return trigger_range
end

function widow_trap:GetBehavior(  )
	return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
end


function widow_trap:OnSpellStart()

	local duration = self:GetSpecialValueFor("duration")
	local locate = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")
	self.caster = self:GetCaster()
	local player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
	local friendly_units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
												locate,
												nil,
												radius,
												DOTA_UNIT_TARGET_TEAM_BOTH,
												DOTA_UNIT_TARGET_ALL,
												DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
												FIND_CLOSEST,
												true)

		local mine_found = false

		-- Search and see if mines were found
		for _,unit in pairs(friendly_units) do
			local unitName = unit:GetUnitName()
			if unitName == "explosive_mech" then
				mine_found = true
			end
			
		end
		if mine_found then
			self:EndCooldown()
			CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message="Нельзя установить рядом с миной"})
			self:RefundManaCost()

		else

			CreateUnitByNameAsync("explosive_mech", locate, true, self.caster, self.caster, self.caster:GetTeam(), function(traps)
			traps:AddNewModifier(self:GetCaster(), self, "widow_trap_borrow", {duration = duration})
			
	end)
		end
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
	self:OnIntervalThink()
	self:StartIntervalThink(FrameTime())
	self:GetParent():EmitSound("Hero_NyxAssassin.Burrow.In")
end

function widow_trap_borrow:OnDestroy()
	-- self:GetParent():SetModel("models/courier/courier_mech/courier_mech.vmdl")
	self:GetParent():SetOriginalModel("models/courier/courier_mech/courier_mech.vmdl")
	self:StartIntervalThink(FrameTime())
	self:GetParent():EmitSound("Hero_NyxAssassin.Burrow.Out")
end


function widow_trap_borrow:DeclareFunctions(  )
	local funcs = {
			MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
	}
	return funcs
end

function widow_trap_borrow:GetModifierInvisibilityLevel(  )
	return 0
end

function widow_trap_borrow:CheckState(  )
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true
	}
end

function widow_trap_borrow:OnIntervalThink(  )
	local locate = self:GetParent():GetAbsOrigin()
	local radius = self:GetAbility():GetSpecialValueFor("radius") * 1.5
		local friendly_units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
												locate,
												nil,
												radius,
												DOTA_UNIT_TARGET_TEAM_ENEMY,
												DOTA_UNIT_TARGET_ALL,
												DOTA_UNIT_TARGET_FLAG_NO_INVIS,
												FIND_CLOSEST,
												true)

		

		-- Search and see if mines were found
		for _,unit in pairs(friendly_units) do
			if 	unit then
				self:GetParent():MoveToPosition(unit:GetAbsOrigin())
				self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "widow_trap_unborrow", {duration = 0.3})
				self:Destroy()
			end
		end
end

LinkLuaModifier("widow_trap_unborrow", "heroes/hero_sniper/rocket_trap.lua", LUA_MODIFIER_MOTION_NONE)

widow_trap_unborrow = class({})
function widow_trap_unborrow:IsHidden() return false end
function widow_trap_unborrow:IsPurgable() return false end

function widow_trap_unborrow:OnCreated()
end

function widow_trap_unborrow:OnRefresh()

end

function widow_trap_unborrow:OnDestroy(  )
	local locate = self:GetParent():GetAbsOrigin()
	local radius = self:GetAbility():GetSpecialValueFor("radius") * 1.5
		local friendly_units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
												locate,
												nil,
												radius,
												DOTA_UNIT_TARGET_TEAM_ENEMY,
												DOTA_UNIT_TARGET_ALL,
												DOTA_UNIT_TARGET_FLAG_NO_INVIS,
												FIND_CLOSEST,
												true)

		

		-- Search and see if mines were found
		for _,unit in pairs(friendly_units) do
			if 	unit then
				self:GetParent():MoveToPosition(unit:GetAbsOrigin())
				self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "widow_trap_ai", {duration = -1})
				self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "widow_trap_explosion", {duration = 2.6})
			end
		end
end

function widow_trap_unborrow:GetOverrideAnimation(  )
	return ACT_DOTA_SPAWN
end

function widow_trap_unborrow:CheckState()
return {[MODIFIER_STATE_STUNNED] = true}
end

 LinkLuaModifier("widow_trap_ai", "heroes/hero_sniper/rocket_trap.lua", LUA_MODIFIER_MOTION_NONE)
 
 widow_trap_ai = class({})
 function widow_trap_ai:IsHidden() return false end
 function widow_trap_ai:IsPurgable() return false end
 
 function widow_trap_ai:OnCreated()
 	self:StartIntervalThink(FrameTime())
 	self:OnIntervalThink()
 end
 
 function widow_trap_ai:OnRefresh()
 	self:StartIntervalThink(FrameTime())
 	self:OnIntervalThink()
 end
 
 function widow_trap_ai:OnIntervalThink(  )
 	local locate = self:GetParent():GetAbsOrigin()
 	local radius = self:GetAbility():GetSpecialValueFor("radius") * 1.5
 	local friendly_units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
 												locate,
 												nil,
 												radius,
 												DOTA_UNIT_TARGET_TEAM_ENEMY,
 												DOTA_UNIT_TARGET_ALL,
 												DOTA_UNIT_TARGET_FLAG_NO_INVIS,
 												FIND_CLOSEST,
 												true)
 
 		
 
 		-- Search and see if mines were found
 		for _,unit in pairs(friendly_units) do
 			if 	unit then
 				self:GetParent():MoveToPosition(unit:GetAbsOrigin())
 			end
 		end
 	if #friendly_units == 0 then
 		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "widow_trap_borrow", {duration = self:GetAbility():GetSpecialValueFor("duration")})
 		if self:GetParent():HasModifier("widow_trap_explosion") then
 			self:GetParent():RemoveModifierByName("widow_trap_explosion")
 		end
 		self:Destroy()
 	end
 end

LinkLuaModifier("widow_trap_explosion", "heroes/hero_sniper/rocket_trap.lua", LUA_MODIFIER_MOTION_NONE)

 widow_trap_explosion = class({})
 function widow_trap_explosion:IsHidden() return false end
 function widow_trap_explosion:IsPurgable() return false end
 
 function widow_trap_explosion:OnCreated()
 	self:StartIntervalThink(2.0)
 end
 
 function widow_trap_explosion:OnRefresh()
 
 end

function widow_trap_explosion:OnIntervalThink(  )
	local locate = self:GetParent():GetAbsOrigin()
	local radius = self:GetAbility():GetSpecialValueFor("radius") * 1.5
	 	local friendly_units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
 			locate,
 			nil,
 			radius,
 			DOTA_UNIT_TARGET_TEAM_ENEMY,
 			DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
 			DOTA_UNIT_TARGET_FLAG_NONE,
 			FIND_ANY_ORDER,
 			false)
	 	for _,targets in ipairs(friendly_units) do
	 		ApplyDamage({
	 		    victim = targets,
	 		    attacker = self:GetParent(),
	 		    damage = self:GetAbility():GetSpecialValueFor("explosion_damage"),
	 		    damage_type = DAMAGE_TYPE_MAGICAL,
	 		    damage_flags = DOTA_DAMAGE_FLAG_NONE,
	 		    ability = self:GetAbility()
	   		})
	   		ScreenShake(self:GetParent():GetAbsOrigin(), 10, 0.3, 0.5, 1000, 0, true)
	 	end

	self:GetParent():ForceKill(true)

	ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
end