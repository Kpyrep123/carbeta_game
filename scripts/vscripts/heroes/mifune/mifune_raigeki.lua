mifune_raigeki = class({})

LinkLuaModifier("modifier_raigeki_debuff","heroes/mifune/mifune_raigeki",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_raigeki_cast_range_talent","heroes/mifune/mifune_raigeki",LUA_MODIFIER_MOTION_NONE)

function mifune_raigeki:GetAOERadius()
	return self:GetSpecialValueFor("end_radius")
end

function mifune_raigeki:GetCastRange()
	return self:GetSpecialValueFor("range") + self:GetCaster():GetModifierStackCount("modifier_raigeki_cast_range_talent", self:GetCaster())
end

function mifune_raigeki:GetIntrinsicModifierName()
	return "modifier_raigeki_cast_range_talent"
end

function mifune_raigeki:OnSpellStart()
	local caster = self:GetCaster()
	local path_radius = self:GetSpecialValueFor("path_radius")
	local end_radius = self:GetSpecialValueFor("end_radius")
	local speed = self:GetSpecialValueFor("speed")
	local duration = self:GetSpecialValueFor("blind_duration")

	caster:EmitSound("Hero_Mifune.Raigeki")

	self.original_loc = caster:GetAbsOrigin()
	local target_loc = self:GetCursorPosition()
	local direction = (target_loc - self.original_loc):Normalized()
	local range = (target_loc - self.original_loc):Length2D()

	local end_delay = range / speed

	-- Launch projectile
	local projectile = {
		Ability = self,
		EffectName = "particles/units/heroes/hero_mifune/mifune_shockwave.vpcf",
		vSpawnOrigin = caster:GetAttachmentOrigin(DOTA_PROJECTILE_ATTACHMENT_ATTACK_1),
		fDistance = range,
		fStartRadius = path_radius,
		fEndRadius = path_radius,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = direction * speed,
		bProvidesVision = false,
		iVisionRadius = 0,
		iVisionTeamNumber = caster:GetTeamNumber()
	}

	ProjectileManager:CreateLinearProjectile(projectile)

	-- End explosion
	Timers:CreateTimer(end_delay, function()
		local trail_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mifune/zanmato_trail.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(trail_pfx, 0, self.original_loc)
		ParticleManager:SetParticleControl(trail_pfx, 1, target_loc)
		ParticleManager:ReleaseParticleIndex(trail_pfx)

		local blast_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mifune/raigeki_end.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(blast_pfx, 0, target_loc)
		ParticleManager:SetParticleControl(blast_pfx, 1, Vector(2 * end_radius / 3, 0, 0))
		ParticleManager:ReleaseParticleIndex(blast_pfx)

		FindClearSpaceForUnit(caster, target_loc, true)
		ProjectileManager:ProjectileDodge(caster)

		caster:EmitSound("Hero_Mifune.RaigekiEnd")

		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target_loc, nil, end_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			enemy:AddNewModifier(caster, self, "modifier_raigeki_debuff", {duration = duration *(1 - enemy:GetStatusResistance())})

			local actual_damage = ApplyDamage({victim = enemy, attacker = caster, damage = self:GetSpecialValueFor("bonus_damage"), damage_type = DAMAGE_TYPE_MAGICAL})
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, enemy, actual_damage, nil)
		end
	end)
end

function mifune_raigeki:OnProjectileHit(target, location)
	if target then
		local damage = self:GetSpecialValueFor("damage") + self:GetCaster():GetTalentValue("special_bonus_mifune_1")
		local actual_damage = ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, actual_damage, nil)
	end
end



modifier_raigeki_cast_range_talent = class({})

function modifier_raigeki_cast_range_talent:IsDebuff() return false end
function modifier_raigeki_cast_range_talent:IsHidden() return true end
function modifier_raigeki_cast_range_talent:IsPurgable() return false end

function modifier_raigeki_cast_range_talent:OnCreated(keys)
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_raigeki_cast_range_talent:OnIntervalThink()
	if IsServer() then
		if self:GetCaster():HasTalent("special_bonus_mifune_2") then
			self:SetStackCount(self:GetCaster():GetTalentValue("special_bonus_mifune_2"))
			self:StartIntervalThink(-1)
		end
	end
end



modifier_raigeki_debuff = class({})

function modifier_raigeki_debuff:IsDebuff() return true end
function modifier_raigeki_debuff:IsHidden() return false end
function modifier_raigeki_debuff:IsPurgable() return true end

function modifier_raigeki_debuff:DeclareFunctions()
	local func = {
		MODIFIER_PROPERTY_MISS_PERCENTAGE
	}
	return func
end

function modifier_raigeki_debuff:GetModifierMiss_Percentage()
	return 100
end