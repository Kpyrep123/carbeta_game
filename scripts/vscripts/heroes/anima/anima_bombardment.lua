anima_bombardment = class({})
LinkLuaModifier( "anima_bombardment_debuff", "heroes/anima/anima_bombardment.lua" ,LUA_MODIFIER_MOTION_NONE )

function anima_bombardment:IsVectorTargeting()
	return true
end

function anima_bombardment:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_POINT
end

function anima_bombardment:OnSpellStart()

	local vStartLocation = self:GetInitialPosition()
	local vDirection = self:GetDirectionVector()
	--this is important with my vector library edits, otherwise the spell might not always go where the indicator is
	if vDirection == Vector(0,0,0) then
		vDirection = Vector(1,0,0)
	end
	
	local caster = self:GetCaster()
	local distance = self:GetSpecialValueFor("vector_distance")
	local endLocation = vStartLocation + (vDirection * distance)
	local exp_radius = self:GetSpecialValueFor("explosion_radius")
	local interval = self:GetSpecialValueFor("explosion_interval")
	local exp_damage = self:GetSpecialValueFor("damage")
	local bonus_damage = self:GetSpecialValueFor("extra_damage")
	local exp_1 = vStartLocation + (vDirection * exp_radius)
	local exp_2 = vStartLocation + (vDirection * exp_radius * 3)
	local exp_3 = vStartLocation + (vDirection * exp_radius * 5)
	local exp_4 = vStartLocation + (vDirection * exp_radius * 7)
	
	for i=1,4 do
		--start the falling particles
		Timers:CreateTimer( (i - 1) * interval, function()
			if i == 1 then
				point = exp_1
				elseif i == 2 then
				point = exp_2
				elseif i == 3 then
				point = exp_3
				elseif i == 4 then
				point = exp_4
			end
			local particle = ParticleManager:CreateParticle("particles/animastellarbarrage_particles/anima_stellar_barrage.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(particle, 0, point)
			ParticleManager:SetParticleControl(particle, 4, Vector(exp_radius, exp_radius, exp_radius))
			
			--deal damage when the particles actually fall
			Timers:CreateTimer( 0.15, function()
				GridNav:DestroyTreesAroundPoint(point, exp_radius, false)
				StartSoundEventFromPosition("Hero_AbyssalUnderlord.Firestorm", point)
				local enemies = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, exp_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
				for _,enemy in pairs(enemies) do
					
					local target_damage = exp_damage
					
					if enemy:HasModifier("anima_bombardment_debuff") then
						target_damage = exp_damage + bonus_damage
					end
				
					local damageTable = {
						victim = enemy,
						attacker = caster,
						damage = target_damage,
						damage_type = DAMAGE_TYPE_MAGICAL,
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self, --Optional.
					}

					ApplyDamage(damageTable)
					enemy:AddNewModifier(caster, self, "anima_bombardment_debuff", {duration = (interval * 4)})
				end
			return nil
			end
			)

		return nil
		end
		)
	end
end

anima_bombardment_debuff = class({})

function anima_bombardment_debuff:IsPurgable() return false end

function anima_bombardment_debuff:IsHidden() return true end