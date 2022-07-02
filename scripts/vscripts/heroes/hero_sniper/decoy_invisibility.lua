decoy_invisibility = decoy_invisibility or class({})

function decoy_invisibility:OnSpellStart(  )

	local ill = CreateIllusions(self:GetCaster(), self:GetCaster(), {
		outgoing_damage = self:GetSpecialValueFor("illusion_outgoing_damage"),
		incoming_damage	= self:GetSpecialValueFor("illusion_incoming_damage"),
		bounty_base		= self:GetCaster():GetIllusionBounty(), -- Custom function but it should just be caster level * 2
		bounty_growth	= nil,
		outgoing_damage_structure	= nil,
		outgoing_damage_roshan		= nil,
		duration		= self:GetSpecialValueFor("illusion_duration")
	}
	, 1, 0, false, false)
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifeir_decoy_invisibility", {duration = self:GetSpecialValueFor("illusion_duration")})
	-- self:GetCaster():AddNewModifier(self:GetCaster(), nil, "modifier_invisible", {duration = self:GetSpecialValueFor("illusion_duration")})	
	
		self.responses = 
				{
					"novainvis1",
					"novainvis2",
					"novainvis3"
				}
		self:GetCaster():EmitSound(self.responses[RandomInt(1, #self.responses)])
	if ill then
		for _, illusion in pairs(ill) do
			-- Vanilla modifier to give the illusions that Terrorblade illusion texture
				illusion:AddNewModifier(self:GetCaster(), self, "modifeir_decoy_illusion", {duration = 5})
		end
	end
end

LinkLuaModifier("modifeir_decoy_invisibility", "heroes/hero_sniper/decoy_invisibility.lua", LUA_MODIFIER_MOTION_NONE)

modifeir_decoy_invisibility = class({})
function modifeir_decoy_invisibility:IsHidden() return false end
function modifeir_decoy_invisibility:IsPurgable() return false end
function modifeir_decoy_invisibility:GetTexture() return end
function modifeir_decoy_invisibility:GetEffectName() return end

function modifeir_decoy_invisibility:OnCreated()

end

function modifeir_decoy_invisibility:OnRefresh()

end

function modifeir_decoy_invisibility:DeclareFunctions()
	return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
			MODIFIER_EVENT_ON_ATTACK,
			MODIFIER_EVENT_ON_ABILITY_EXECUTED,
			MODIFIER_EVENT_ON_ATTACKED}
end

function modifeir_decoy_invisibility:CheckState(  )
	return {[MODIFIER_STATE_INVISIBLE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}

end


function modifeir_decoy_invisibility:GetModifierInvisibilityLevel()
	return 5
end

function modifeir_decoy_invisibility:OnAttack( params )
	if params.attacker ~= self:GetParent() then return end
		self:Destroy()
end

function modifeir_decoy_invisibility:OnAbilityExecuted( params )
	
		if params.unit~=self:GetParent() then return end
		self:Destroy()
end
LinkLuaModifier("modifeir_decoy_illusion", "heroes/hero_sniper/decoy_invisibility.lua", LUA_MODIFIER_MOTION_NONE)

modifeir_decoy_illusion = class({})

function modifeir_decoy_illusion:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACKED}
end

function modifeir_decoy_illusion:OnAttacked ( p )
	if p.target == self:GetParent()
		and p.target:IsIllusion() then 	
		

		self.caster = self:GetCaster()
		if p.target:IsAlive() then
		-- load data
		if self:GetCaster():FindAbilityByName("drone_attacker"):GetLevel() > 0 then
			self.duration = self:GetCaster():FindAbilityByName("drone_attacker"):GetSpecialValueFor("duration")
			self.idle = self:GetCaster():FindAbilityByName("drone_attacker"):GetSpecialValueFor("idle_radius")/2
			self.direction = RotatePosition( Vector(0,0,0), QAngle( 0, -120, 0 ), self.caster:GetForwardVector() )
			self.location = p.target:GetOrigin() + self.idle*self.direction
			self.responses = 
						{
							"droneland1",
							"droneland2"
						}
				self:GetCaster():EmitSound(self.responses[RandomInt(1, #self.responses)])

			-- summon
			self:SummonDrone()
		end
		end
		self:GetParent():ForceKill(true)
	end
end

LinkLuaModifier("drone_attacker_moving", "heroes/hero_sniper/decoy_invisibility.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("drone_attacker_attack", "heroes/hero_sniper/decoy_invisibility.lua", LUA_MODIFIER_MOTION_NONE)


function modifeir_decoy_illusion:SummonDrone(  )
	for i=1,3 do
		self.rand_pos = RotatePosition( Vector(0,0,0), QAngle( 0, RandomInt(1, 360), 0 ), self.caster:GetForwardVector() )
		local locate = self.caster:GetOrigin() + self.idle*self.rand_pos
		CreateUnitByNameAsync("unit_drone_agressive", locate, true, self.caster, self.caster, self.caster:GetTeam(), function(drones)
			drones:AddNewModifier(self.caster, self, "drone_attacker_moving", {duration = self.duration})
			drones:AddNewModifier(self.caster, nil, "modifier_kill", {duration = self.duration})
			drones:SetOwner(self.caster)
			local height = drones:AddNewModifier(self.caster, self, "drone_attacker_attack", {duration = self.duration})
			height:SetStackCount(1000)
	end)
	end
end

drone_attacker_moving = class({})
function drone_attacker_moving:IsHidden() return true end
function drone_attacker_moving:IsPurgable() return false end

function drone_attacker_moving:OnCreated()
	self:OnIntervalThink()
	self:StartIntervalThink(1)
	Timers:CreateTimer(0.03, function()
	self:GetParent():MoveToPositionAggressive( self:GetCaster():GetAbsOrigin() + RandomVector( RandomInt( 100, 300 ) ) )
	end)
end

function drone_attacker_moving:OnRefresh()
	self:OnCreated()
end

function drone_attacker_moving:CheckState()
	local state = {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		-- [MODIFIER_STATE_NO_UNIT_COLLISION] = self.aggro==nil,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_INVISIBLE] = false,

		[MODIFIER_STATE_STUNNED] = false,
	}

	return state
end

function drone_attacker_moving:DeclareFunctions(  )
		local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}

	return funcs
end

function drone_attacker_moving:GetModifierPreAttack_BonusDamage(  )
	return self:GetCaster():FindAbilityByName("drone_attacker"):GetSpecialValueFor("drones_damage") or 20
end

function drone_attacker_moving:GetModifierAttackRangeBonus(  )
	return self:GetCaster():Script_GetAttackRange() + 300 or 700
end

function drone_attacker_moving:OnIntervalThink(  )
	self:GetParent():MoveToPosition( self:GetCaster():GetAbsOrigin() + RandomVector( RandomInt( 100, 300 ) ) )
end
drone_attacker_attack = class({})
function drone_attacker_attack:IsHidden() return false end
function drone_attacker_attack:IsPurgable() return false end

function drone_attacker_attack:OnCreated()
	self:OnIntervalThink()
	self:StartIntervalThink(0.002)
end

function drone_attacker_attack:OnRefresh()
	self:OnCreated()
end

function drone_attacker_attack:DeclareFunctions(  )
	local funcs = {
					MODIFIER_PROPERTY_VISUAL_Z_DELTA,
					MODIFIER_EVENT_ON_ATTACK,
					MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end


function drone_attacker_attack:OnIntervalThink()
	if self:GetStackCount() >= 150 then 
		self:SetStackCount(self:GetStackCount() - 1)
	end

end

function drone_attacker_attack:GetVisualZDelta()
	return self:GetStackCount()
	-- body
end

function drone_attacker_attack:OnAttack( p )
	if p.attacker == self:GetParent() then
	self.responses = 
				{
					"droneatack1",
					"droneatack2",
					"droneatack3"
				}
		self:GetParent():EmitSound(self.responses[RandomInt(1, #self.responses)])
	end
end

function drone_attacker_attack:OnAttackLanded( p )
	if p.attacker == self:GetParent() then
	self.responses = 
				{
					"droneexp1",
					"droneexp2",
					"droneexp3"
				}
		p.target:EmitSound(self.responses[RandomInt(1, #self.responses)])
	end
end