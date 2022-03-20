nova_nuclear_strike = class({})
LinkLuaModifier("modifier_imba_gyrocopter_call_down_thinker", "heroes/hero_sniper/nuclear_strike", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_channel_time", "heroes/hero_sniper/nuclear_strike", LUA_MODIFIER_MOTION_NONE)

modifier_imba_gyrocopter_call_down_thinker			= modifier_imba_gyrocopter_call_down_thinker or class({})

--------------------------------------------------------------------------------

function nova_nuclear_strike:GetCooldown( level )
	local upgrade_cooldown = 0 
	local talent = self:GetCaster():FindAbilityByName("special_bonus_unquie_ns_cd")
	if talent and talent:GetLevel() > 0 then
		upgrade_cooldown = 20
	end

	return self.BaseClass.GetCooldown( self, level ) - upgrade_cooldown
end

function nova_nuclear_strike:OnSpellStart(  )
	self.radius					= self:GetSpecialValueFor("radius") + self:GetCaster():GetTalentValue("special_bonus_unquie_ns_rad")
	self.marker_particle		= ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_gyrocopter/gyro_calldown_marker.vpcf", PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeamNumber())
	ParticleManager:SetParticleControl(self.marker_particle, 0, self:GetCursorPosition() )
	ParticleManager:SetParticleControl(self.marker_particle, 1, Vector(self.radius, 1, self.radius * (-1)))
	EmitGlobalSound("Nuclear")
	local channel = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_channel_time", {})
	channel:SetStackCount(100)

end


function nova_nuclear_strike:OnChannelFinish( bInterrupted )
	if bInterrupted then 
		ParticleManager:DestroyParticle(self.marker_particle, true)
		local channel = self:GetCaster():FindModifierByName("modifier_channel_time")
		CreateModifierThinker(self:GetCaster(), self, "modifier_imba_gyrocopter_call_down_thinker", {duration = 2}, self:GetCursorPosition() + RandomVector(RandomInt(500, (3000 * channel:GetStackCount()) / 100)), self:GetCaster():GetTeamNumber(), false)
		self:GetCaster():RemoveModifierByName("modifier_channel_time")
	else
	self:GetCaster():EmitSound("Nuclear.launch")
	-- self:GetCaster():EmitSound("Hero_Gyrocopter.CallDown.Fire.Self") -- This one has a volume_falloff_max so IDK which one to use
	CreateModifierThinker(self:GetCaster(), self, "modifier_imba_gyrocopter_call_down_thinker", {duration = 2}, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)
	self:GetCaster():RemoveModifierByName("modifier_channel_time")
end

end


function modifier_imba_gyrocopter_call_down_thinker:OnCreated()
	self.damage_first			= self:GetAbility():GetSpecialValueFor("damage_first")
	self.radius					= self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():GetTalentValue("special_bonus_unquie_ns_rad")
	self.cast_range_standard	= self:GetAbility():GetSpecialValueFor("cast_range_standard")

	if not IsServer() then return end
	
	self.damage_type			= self:GetAbility():GetAbilityDamageType()
	
	self.first_missile_impact	= false
	local buildings = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		Vector(0,0,0),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
		DOTA_UNIT_TARGET_BUILDING,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	local fountain = nil
	for _,building in pairs(buildings) do
		if building:GetClassname()=="ent_dota_fountain" then
			fountain = building
			break
		end
	end

	-- if no fountain, just don't do anything
	if not fountain then return end
	

	
	local calldown_first_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_calldown_first.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(calldown_first_particle, 0, fountain:GetOrigin())
	ParticleManager:SetParticleControl(calldown_first_particle, 1, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(calldown_first_particle, 5, Vector(self.radius, self.radius, self.radius))
	ParticleManager:ReleaseParticleIndex(calldown_first_particle)
Timers:CreateTimer(0.5, function()
	EmitSoundOn("Nuclear.explosion", self:GetParent())
end)
	
	self:StartIntervalThink(1)
end

function modifier_imba_gyrocopter_call_down_thinker:OnDestroy(  )
		local damage = self:GetAbility():GetSpecialValueFor("damage")
			local expl = ParticleManager:CreateParticle("particles/nova/nuclear_strike/mushromexplosion.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(expl, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(expl, 1, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(expl, 2, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(expl, 3, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(expl, 4, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(expl, 5, Vector(self.radius, self.radius, self.radius))
		ParticleManager:ReleaseParticleIndex(expl)
		local smoke = ParticleManager:CreateParticle("particles/econ/items/elder_titan/elder_titan_ti7/elder_titan_echo_stomp_ti7_dust.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(smoke, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(smoke, 1, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(smoke, 4, Vector(self.radius, self.radius, self.radius))
		ParticleManager:ReleaseParticleIndex(smoke)
		local sec_expl = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn_sphere_shockwave.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(sec_expl, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(sec_expl, 1, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(sec_expl, 2, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(sec_expl, 3, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(sec_expl, 4, Vector(self.radius, self.radius, self.radius))
		ParticleManager:SetParticleControl(sec_expl, 5, Vector(self.radius, self.radius, self.radius))
		ParticleManager:ReleaseParticleIndex(sec_expl)
			local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		
			for _,enemy in ipairs(enemies) do
					local parent_loc	= self:GetParent():GetAbsOrigin()

					knockback_properties = {
					 center_x 			= parent_loc.x,
					 center_y 			= parent_loc.y,
					 center_z 			= parent_loc.z,
					 duration 			= 1 * (1 - enemy:GetStatusResistance()),
					 knockback_duration = 1 * (1 - enemy:GetStatusResistance()),
					 knockback_distance = 300,
					 knockback_height 	= 150,
					}
					knockback_modifier = enemy:AddNewModifier(self:GetParent(), self, "modifier_knockback", knockback_properties)
					ApplyDamage({
					    victim = enemy,
					    attacker = self:GetCaster(),
					    damage = damage,
					    damage_type = DAMAGE_TYPE_MAGICAL,
					    damage_flags = DOTA_UNIT_TARGET_FLAG_NONE,
					    ability = self:GetAbility(),
				  	})
			end
		if self:GetCaster():HasScepter() then
			local unit = FastDummy(self:GetParent():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), 2, 0)
		for i=1,25 do
			local units = FastDummy(self:GetParent():GetAbsOrigin() + RandomVector(RandomInt(300, 1000)), self:GetCaster():GetTeamNumber(), 2, 0)
			local info = 
			  {
			  Target = units,
			  Source = unit,
			  Ability = self:GetAbility(),  
			  EffectName = "particles/nova/shrapnel/third.vpcf",
			  vSpawnOrigin = self:GetParent():GetAbsOrigin(),
			  bHasFrontalCone = false,
			  bReplaceExisting = false,
			  iMoveSpeed = 1000,
			  }
		  	local projectile = ProjectileManager:CreateTrackingProjectile(info)
		end
	end
end
function nova_nuclear_strike:OnProjectileHit( hTarget, vLocation )
	local second = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), hTarget:GetAbsOrigin(), nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
		for _,sec in ipairs(second) do
			ApplyDamage({
		    victim = sec,
		    attacker = self:GetCaster(),
		    damage = 150,
		    damage_type = DAMAGE_TYPE_MAGICAL,
		    damage_flags = DOTA_DAMAGE_FLAG_NONE,
		    ability = self
	  		})
		end
		EmitSoundOn("Matrix.Shot", hTarget)
end


modifier_channel_time = class({})

modifier_channel_time = class({})
function modifier_channel_time:IsHidden() return true end
function modifier_channel_time:IsPurgable() return false end
function modifier_channel_time:GetTexture() return end
function modifier_channel_time:GetEffectName() return end

function modifier_channel_time:OnCreated()
if not IsServer() then return end
self.think = 100 / self:GetAbility():GetChannelStartTime()
self:StartIntervalThink(0.025)
self:OnIntervalThink()
end

function modifier_channel_time:OnRefresh()
if not IsServer() then return end
self.think = 100 / self:GetAbility():GetChannelStartTime()
self:StartIntervalThink(0.025)
self:OnIntervalThink()
end


function modifier_channel_time:OnIntervalThink(  )
	self:SetStackCount(self:GetStackCount() - 1)
end