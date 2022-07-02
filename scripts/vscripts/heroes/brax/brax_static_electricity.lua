--	Thunderboar's Static Electricity
--	Implementation by Firetoad, 2019.11.03

LinkLuaModifier("modifier_static_electricity", "heroes/brax/brax_static_electricity.lua", LUA_MODIFIER_MOTION_NONE)

brax_static_electricity = class({})

function brax_static_electricity:IsInnateAbility() return true end

function brax_static_electricity:GetIntrinsicModifierName()
	return "modifier_static_electricity"
end

modifier_static_electricity = class({})

function modifier_static_electricity:IsHidden() return true end
function modifier_static_electricity:IsDebuff() return false end
function modifier_static_electricity:IsPurgable() return false end
function modifier_static_electricity:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_static_electricity:OnCreated(keys)
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_static_electricity:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if self:GetParent():HasScepter() then
			if ability:IsHidden() then
				ability:SetHidden(false)
			end
			if not ability:IsActivated() then
				ability:SetActivated(true)
			end
		else
			if not ability:IsHidden() then
				ability:SetHidden(true)
			end
			if ability:IsActivated() then
				ability:SetActivated(false)
			end
		end
	end
		if caster:HasScepter() then
		local dps_scepter = ability:GetSpecialValueFor("dps_scepter") + caster:GetTalentValue("special_bonus_troy_arena_dps")
		Timers:CreateTimer(0, function()
			local units = FindUnitsInRadius(caster:GetTeamNumber(), target_point, nil, field_radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _, unit in pairs(units) do
				if unit:GetTeam() ~= caster:GetTeam() then
					ApplyDamage({victim = unit, attacker = caster, damage = dps_scepter, damage_type = DAMAGE_TYPE_MAGICAL})
				elseif unit == caster then
					ApplyDamage({victim = unit, attacker = caster, damage = dps_scepter, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL})
				end
			end
			duration = duration - 1
			if duration > 0 then
				return 1.0
			end
		end)
	end
end

function modifier_static_electricity:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_static_electricity:OnAttackLanded(keys)
	if IsServer() then
		if keys.target == self:GetParent() then
			local ability = self:GetAbility()
			local caster = self:GetParent()
			local pull_length = ability:GetSpecialValueFor("pull_length")
			local pull_duration = ability:GetSpecialValueFor("pull_duration")
			local damage = ability:GetSpecialValueFor("damage")

			if ability:IsActivated() and ability:IsCooldownReady() and keys.attacker:IsHero() and (not caster:PassivesDisabled()) then
				local caster_loc = caster:GetAbsOrigin()
				caster:EmitSound("Brax.StaticElectricity")

				local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster_loc, nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				for _, enemy in pairs(enemies) do

					-- Damage
					ApplyDamage({victim = enemy, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})

					-- Particle
					local enemy_loc = enemy:GetAbsOrigin()
					local pull_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_thunderboar/thunderous_rush_grap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(pull_pfx, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy_loc, true)
					Timers:CreateTimer(pull_duration, function()
						ParticleManager:DestroyParticle(pull_pfx, false)
						ParticleManager:ReleaseParticleIndex(pull_pfx)
					end)

					-- Pull
					local knockback_center = enemy_loc + (enemy_loc - caster_loc):Normalized() * 150
					local knockback_table = {
						center_x = knockback_center.x,
						center_y = knockback_center.y,
						center_z = knockback_center.z,
						knockback_duration = pull_duration,
						knockback_distance = pull_length,
						knockback_height = 0,
						should_stun = 0,
						duration = pull_duration
					}
					enemy:RemoveModifierByName("modifier_knockback")
					enemy:AddNewModifier(caster, ability, "modifier_knockback", knockback_table)
				end

				ability:UseResources(true, false, true)
			end
		end
	end
end