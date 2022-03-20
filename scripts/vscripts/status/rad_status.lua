modifier_status_radiation = class({})

function modifier_status_radiation:IsHidden()
	return false
end

function modifier_status_radiation:IsDebuff()
	return true
end

function modifier_status_radiation:IsPurgable()
	return true
end

function modifier_status_radiation:RemoveOnDeath()
	return true
end

function modifier_status_radiation:OnCreated()
	self.ability	= self:GetAbility()
	self.caster		= self:GetCaster()
	self.parent		= self:GetParent()
	local ability_level = self.ability:GetLevel() - 1
	self.target = nil
	self:OnIntervalThink()
	self:StartIntervalThink(0.1)
end

function modifier_status_radiation:OnIntervalThink()
	if not IsServer() then return end

	self.parent:MoveToTargetToAttack(self.target)
	local hero_enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, 900, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_CLOSEST, false)
		if #hero_enemies > 0 then
			for enemy = 1, #hero_enemies do
				if self.parent:CanEntityBeSeenByMyTeam(hero_enemies[enemy]) then
					self.target = hero_enemies[enemy]
					self:GetParent():SetForceAttackTarget(hero_enemies[enemy])
					self.parent:MoveToTargetToAttack(hero_enemies[enemy])
					return
				end
			end
		end
		
end

function modifier_status_radiation:OnDestroy()
	self.parent:MoveToTargetToAttack(nil)
	self.parent:SetForceAttackTarget(nil)
end


function modifier_status_radiation:CheckState(  )
	local funcs = {
		[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_SPECIALLY_DENIABLE] = true,
	}
	return funcs
end