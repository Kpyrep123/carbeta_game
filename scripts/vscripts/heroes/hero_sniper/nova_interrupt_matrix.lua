LinkLuaModifier("nova_Interrupt_Matrix_lost_control", "heroes/hero_sniper/nova_interrupt_matrix.lua", LUA_MODIFIER_MOTION_NONE)
nova_Interrupt_Matrix = class({})

function nova_Interrupt_Matrix:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	local ability = self
	local ability_level = ability:GetLevel() - 1

	local info = 
	  {
	  Target = target,
	  Source = caster,
	  Ability = self,  
	  EffectName = "particles/econ/items/sniper/sniper_charlie/sniper_assassinate_charlie.vpcf",
	  vSpawnOrigin = caster:GetAbsOrigin(),
	  fDistance = 10000,
	  fStartRadius = 64,
	  fEndRadius = 64,
	  bHasFrontalCone = false,
	  bReplaceExisting = false,
	  iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	  iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	  iUnitTargetType = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
	  fExpireTime = GameRules:GetGameTime() + 10.0,
	  bDeleteOnHit = true,
	  iMoveSpeed = 3000,
	  bProvidesVision = false,
	  iVisionRadius = 0,
	  iVisionTeamNumber = caster:GetTeamNumber(),
	  iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	  }
  	EmitSoundOn("Hero_Sniper.AssassinateDamage", self:GetCaster())
  	Timers:CreateTimer(0.05, function()
  	  local projectile = ProjectileManager:CreateTrackingProjectile(info)
  	end)

end

function nova_Interrupt_Matrix:OnProjectileHit( target, vLocation )
	local duration = self:GetSpecialValueFor("duration")
	if target:TriggerSpellAbsorb(ability) then
		RemoveLinkens(target)
		return
	end

	target:AddNewModifier(self:GetCaster(), self, "nova_Interrupt_Matrix_lost_control", {duration = duration})

end

nova_Interrupt_Matrix_lost_control = class({})

function nova_Interrupt_Matrix_lost_control:OnCreated()
	self.target = self:GetParent()
		self.enemyTeam = self.target:GetTeamNumber()
		self.friendlyPlayer = self:GetCaster():GetPlayerID()
		self.enemyPlayer = self.target:GetPlayerID()
		self.target:SetTeam(15)
		self.target:SetControllableByPlayer(0, false)
		EmitSoundOn("Matrix", self:GetParent())
end

function nova_Interrupt_Matrix_lost_control:OnDestroy(  )
	self.target:SetTeam(self.enemyTeam)
	self.target:SetControllableByPlayer(self.enemyPlayer, true)

	self.target:Stop()
	self:GetParent():StopSound("Matrix")
end

function nova_Interrupt_Matrix_lost_control:GetEffectName(  )
	return "particles/econ/items/sniper/sniper_charlie/sniper_crosshair_charlie.vpcf"
end

function nova_Interrupt_Matrix_lost_control:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
function nova_Interrupt_Matrix_lost_control:GetStatusEffectName(  )
	return "particles/status_fx/status_effect_terrorblade_reflection.vpcf"
end

function nova_Interrupt_Matrix_lost_control:StatusEffectPriority()
	return 15
end