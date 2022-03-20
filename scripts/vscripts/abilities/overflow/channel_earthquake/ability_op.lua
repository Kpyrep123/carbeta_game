if channel_earthquake_op == nil then
	channel_earthquake_op = class({})
end

LinkLuaModifier( "generic_lua_stun", "abilities/overflow/generic_stun.lua", LUA_MODIFIER_MOTION_NONE )

function channel_earthquake_op:GetCooldown( level )
	local upgrade_cooldown = 0 
	local talent = self:GetCaster():FindAbilityByName("special_bonus_lanaya_ult_cd")
	if talent and talent:GetLevel() > 0 then
		upgrade_cooldown = 25
	end

	return self.BaseClass.GetCooldown( self, level ) - upgrade_cooldown
end


 function channel_earthquake_op:OnSpellStart()
 		local hCaster = self:GetCaster()
	 self.point = self:GetCursorPosition() 
	 local randPos = RandomVector(RandomInt(0, self:GetSpecialValueFor("radius"))) + self.point
	 self:Explosion(randPos)
	 self.start_time = GameRules:GetGameTime()
	 self.cc_interval = self:GetSpecialValueFor("think_interval") + hCaster:GetTalentValue("special_bonus_lanaya_unquie_3")
	 self.cc_timer = 0
 end

 function channel_earthquake_op:GetAOERadius()
 	local caster = self:GetCaster()
	 return self:GetSpecialValueFor("radius")
 end

 function channel_earthquake_op:GetBehavior() 
	 local behav = DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_AOE
	 return behav
 end

 function channel_earthquake_op:OnChannelThink(flInterval)
	self.cc_timer = self.cc_timer + flInterval
	 if self.cc_timer >= self.cc_interval then
		self.cc_timer = self.cc_timer - self.cc_interval
		 self:CustomChannelThink()
	 end
 end

 function channel_earthquake_op:CustomChannelThink()
 	local caster = self:GetCaster()
	 local randPos = RandomVector(RandomInt(9, self:GetSpecialValueFor("radius") + caster:GetTalentValue("special_bonus_lanaya_unquie_4"))) + self.point
	 self:Explosion(randPos)
 end

 function channel_earthquake_op:OnChannelFinish( bInterrupted )
	 self.point = nil
 end
 
 function channel_earthquake_op:Explosion(vPos)
	 local hCaster = self:GetCaster()
	 local particleName = "particles/templar_assassin_trap_explode_custom.vpcf"
	 local stun_dur = self:GetSpecialValueFor("stun_duration")
	local aoe = self:GetSpecialValueFor("spot_radius")
	 --silly field of view
	 AddFOWViewer(hCaster:GetTeamNumber(), vPos, aoe, stun_dur, false)
	 local expl = ParticleManager:CreateParticle( particleName, PATTACH_WORLDORIGIN, hCaster )
	 ParticleManager:SetParticleControl( expl, 0, vPos )
	 ParticleManager:SetParticleControl( expl, 1, vPos )
	EmitSoundOnLocationWithCaster(self.point, "Hero_TemplarAssassin.Trap.Explode", hCaster )
	if not hCaster:HasScepter() then
		local damage = {
			attacker = self:GetCaster(),
			damage = self:GetSpecialValueFor("damage") + hCaster:GetTalentValue("special_bonus_lanaya_unquie_2") ,
			damage_type = self:GetAbilityDamageType(),
			ability = self
		}
		local enemies = FindUnitsInRadius( hCaster:GetTeamNumber(), vPos, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
		if #enemies > 0 then
				 
			for _,enemy in pairs(enemies) do
				if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
				end 
				enemy:AddNewModifier( self:GetCaster(), self, "generic_lua_stun", { duration = stun_dur*(1- enemy:GetStatusResistance()) , stacking = 0 } )
				damage.victim = enemy
				ApplyDamage( damage )
				if hCaster:HasModifier( "modifier_item_aghanims_shard" ) then
				local locmana = enemy:GetMana()
				local mana = (locmana * 5 / 100)
				 enemy:ReduceMana(mana)
				 hCaster:GiveMana(mana)
				end
			end
		end

	else
		local damage = {
			attacker = self:GetCaster(),
			damage = (hCaster:GetMana() * 0.05) + self:GetSpecialValueFor("damage") + hCaster:GetTalentValue("special_bonus_lanaya_unquie_2"),
			damage_type = self:GetAbilityDamageType(),
			ability = self
		}
		local enemies = FindUnitsInRadius( hCaster:GetTeamNumber(), vPos, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
		if #enemies > 0 then
				 
			for _,enemy in pairs(enemies) do
				if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
				end 
				enemy:AddNewModifier( self:GetCaster(), self, "generic_lua_stun", { duration = stun_dur *(1- enemy:GetStatusResistance()), stacking = 0 } )
				damage.victim = enemy
				ApplyDamage( damage )
				if hCaster:HasModifier( "modifier_item_aghanims_shard" ) then
				local locmana = enemy:GetMana()
				local mana = (locmana * 5 / 100)
				 enemy:ReduceMana(mana)
				 hCaster:GiveMana(mana)
				end
			end
		end
	end
 end