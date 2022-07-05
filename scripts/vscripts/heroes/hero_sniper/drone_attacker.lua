drone_attacker = drone_attacker or class({})
rndsound = {"droneatack1", "droneatack2", "droneatack3"}
function drone_attacker:OnSpellStart(  )
	self.caster = self:GetCaster()

	-- load data
	self.duration = self:GetSpecialValueFor("duration")
	self.idle = self:GetSpecialValueFor("idle_radius")/2
	self.direction = RotatePosition( Vector(0,0,0), QAngle( 0, -120, 0 ), self.caster:GetForwardVector() )
	self.location = self.caster:GetOrigin() + self.idle*self.direction
	self.responses = 
				{
					"droneland1",
					"droneland2"
				}
		self:GetCaster():EmitSound(self.responses[RandomInt(1, #self.responses)])

	-- summon
	self:SummonDrone()

end

function drone_attacker:SummonDrone(  )
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

LinkLuaModifier("drone_attacker_moving", "heroes/hero_sniper/drone_attacker.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("drone_attacker_attack", "heroes/hero_sniper/drone_attacker.lua", LUA_MODIFIER_MOTION_NONE)


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
	return self:GetAbility():GetSpecialValueFor("drones_damage")
end

function drone_attacker_moving:GetModifierAttackRangeBonus(  )
	return self:GetCaster():Script_GetAttackRange() + 300
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