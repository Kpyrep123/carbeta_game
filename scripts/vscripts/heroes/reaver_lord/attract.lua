reaver_lord_attract_lua = class({})


function reaver_lord_attract_lua:OnSpellStart()
	local caster 		= self:GetCaster() 
	local ability 		= self
	local modifier_name = self:GetCaster():FindModifierByName("modifier_reaver_lord_soul_collector_passive_dummy")

	local max_souls 	= 0



	local dmg_by_hero	= self:GetSpecialValueFor("damage_by_hero") 
	local dmg_by_creep	= self:GetSpecialValueFor("damage_by_creep")  
	local dmg_pct 		= self:GetSpecialValueFor("damage_pct") / 100
	local radius 		= self:GetSpecialValueFor("radius") + caster:GetTalentValue("special_bonus_unquie_attrackt_rad")
	local stun_duration = self:GetSpecialValueFor("stun_duration") + caster:GetTalentValue("special_bonus_unquie_attrackt_dur")
	local talent 		= caster:FindAbilityByName("reaver_lord_special_bonus_no_souls")


	local aoe = ParticleManager:CreateParticle("particles/econ/items/outworld_devourer/od_ti8/od_ti8_santies_eclipse_area.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControlEnt(aoe, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl( aoe, 1, Vector(radius, radius, radius) )
	--caster:RemoveModifierByName(modifier_name)


	local units = FindUnitsInRadius(	caster:GetTeamNumber(), 
										caster:GetAbsOrigin() ,
										nil, 
										radius, 
										DOTA_UNIT_TARGET_TEAM_ENEMY, 
										DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 
										DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
										0, 
										false) 
	
	if not units or units == {} then return end


	local total_damage = 0
	
	for i = 0, #units do
		if units[i] then
			if units[i]:IsRealHero() then
				total_damage = total_damage + dmg_by_hero
			else
				total_damage = total_damage + dmg_by_creep
			end
		end
	end

	
	local point = caster:GetAbsOrigin() + caster:GetForwardVector():Normalized() * 200

	local last_target

	for i = 0, #units do
		if units[i] then
			units[i]:AddNewModifier(self:GetCaster(), nil, "modifier_stunned", {duration = stun_duration})
			
				ApplyDamage({	victim = units[i], 
								attacker = caster, 
								damage = (total_damage  + units[i]:GetMaxHealth() * dmg_pct), 
								damage_type = DAMAGE_TYPE_MAGICAL })
			FindClearSpaceForUnit(units[i], point, false)
			EmitSoundOn("Hero_Terrorblade.Sunder.Cast", units[i])
			if caster:HasScepter() then 
				units[i]:AddNewModifier(self:GetCaster(), self:GetCaster():FindAbilityByName("reaver_lord_soul_devour_lua"), "modifier_reaver_lord_soul_devour_debuff", {duration =(self:GetCaster():FindAbilityByName("reaver_lord_soul_devour_lua"):GetSpecialValueFor("duration") + self:GetCaster():GetTalentValue("special_bonus_unquie_devour_duration")) * (1 - units[i]:GetStatusResistance())})
			end

			last_target = units[i]
		end
	end
	
	if(not last_target) then 
		return 
	end
	local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf"	
	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, last_target )

	ParticleManager:SetParticleControlEnt(particle, 0, last_target, PATTACH_POINT_FOLLOW, "attach_hitloc", last_target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", last_target:GetAbsOrigin(), true)

	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )

	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", last_target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, last_target, PATTACH_POINT_FOLLOW, "attach_hitloc", last_target:GetAbsOrigin(), true)


end
