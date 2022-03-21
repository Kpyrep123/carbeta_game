--	Thunderboar's Atomic Drop
--	Concept by Brax
--	Implementation by Firetoad, 2018.07.16

brax_stomp = class({})

LinkLuaModifier("modifier_brax_stomp_slow", "heroes/brax/brax_stomp", LUA_MODIFIER_MOTION_NONE)

function brax_stomp:OnSpellStart()
	if IsServer() then

		-- Parameters
		local caster = self:GetCaster()
		local caster_loc = caster:GetAbsOrigin()
		local damage = self:GetSpecialValueFor("damage") + caster:GetTalentValue("special_bonus_brax_4")
		local effect_radius = self:GetSpecialValueFor("effect_radius")
		local slow_duration = self:GetSpecialValueFor("slow_duration")
		local ring_radius = self:GetSpecialValueFor("ring_radius")
		local radius_step = self:GetSpecialValueFor("radius_step")
		local blast_count = self:GetSpecialValueFor("blast_count")
		local blast_step = self:GetSpecialValueFor("blast_step")
		local max_rings = self:GetSpecialValueFor("max_rings")
		local ring_delay = self:GetSpecialValueFor("ring_delay")
		local blast_locations = {}

		-- Cast sound
		caster:EmitSound("Brax.StompCast")

		-- Blasting loop
		local ring_count = 0
		Timers:CreateTimer(0, function()
			local this_ring_radius = ring_radius + radius_step * ring_count
			local this_ring_blast_count = blast_count + blast_step * ring_count
			local forward_vector = RandomVector(this_ring_radius)
			caster_loc = caster:GetAbsOrigin()
			--caster:EmitSound("Hero_StormSpirit.Overload")

			for i = 1, this_ring_blast_count do
				blast_locations[i] = RotatePosition(caster_loc, QAngle(0, (i - 1) * 360 / this_ring_blast_count, 0), caster_loc + forward_vector)
			end

			for _, blast_loc in pairs(blast_locations) do
				local explosion_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_thunderboar/atomic_drop.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl(explosion_pfx, 0, blast_loc)
				ParticleManager:SetParticleControl(explosion_pfx, 2, Vector(effect_radius, 0, 0))
				ParticleManager:ReleaseParticleIndex(explosion_pfx)

				if caster:HasTalent("special_bonus_brax_6") then
					local enemies = FindUnitsInRadius(caster:GetTeamNumber(), blast_loc, nil, effect_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
					for _, enemy in pairs(enemies) do
						enemy:EmitSound("Brax.StompHit")
						enemy:AddNewModifier(caster, self, "modifier_brax_stomp_slow", {duration = slow_duration})
						ApplyDamage({victim = enemy, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE})
					end
				else
					local enemies = FindUnitsInRadius(caster:GetTeamNumber(), blast_loc, nil, effect_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
					for _, enemy in pairs(enemies) do
						enemy:EmitSound("Brax.StompHit")
						enemy:AddNewModifier(caster, self, "modifier_brax_stomp_slow", {duration = slow_duration})
						ApplyDamage({victim = enemy, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
					end
				end
			end

			ring_count = ring_count + 1
			if ring_count < max_rings then
				return ring_delay
			end
		end)
	end
end

-- Slow modifier
modifier_brax_stomp_slow = class({})

function modifier_brax_stomp_slow:IsDebuff() return true end
function modifier_brax_stomp_slow:IsHidden() return false end
function modifier_brax_stomp_slow:IsPurgable() return true end

function modifier_brax_stomp_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_brax_stomp_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow")
end
