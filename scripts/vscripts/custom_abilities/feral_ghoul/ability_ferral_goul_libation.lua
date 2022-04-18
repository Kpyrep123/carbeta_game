

ability_ferral_goul_libation = class({})

function ability_ferral_goul_libation:OnSpellStart(  )
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	local ability = self
	local duration = self:GetSpecialValueFor("duration")
	if target:TriggerSpellAbsorb(ability) then
		RemoveLinkens(target)
		return
	end
	target:AddNewModifier(caster, self, "modifier_lination", {duration = duration  * (1 - target:GetStatusResistance())})
	target:AddNewModifier(caster, self, "modifier_lination_damage", {duration = duration  * (1 - target:GetStatusResistance())})
end

LinkLuaModifier("modifier_lination", "custom_abilities/feral_ghoul/ability_ferral_goul_libation.lua", LUA_MODIFIER_MOTION_NONE)

modifier_lination = class({})
function modifier_lination:IsHidden() return false end
function modifier_lination:IsPurgable() return true end

function modifier_lination:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
	self:OnIntervalThink()
	self.particle_drain = "particles/hylonome_libation.vpcf"

	self.particle_drain_fx = ParticleManager:CreateParticle(self.particle_drain, PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.particle_drain_fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)        
	ParticleManager:SetParticleControlEnt(self.particle_drain_fx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)        
	self:AddParticle(self.particle_drain_fx, false, false, -1, false, false)
end

function modifier_lination:OnIntervalThink()
	if not IsServer() then return end
	if self:GetParent():IsMagicImmune() then self:Destroy() end
	local dist_max = self:GetAbility():GetSpecialValueFor("distance") + self:GetCaster():GetTalentValue("special_bonus_unique_ghoul_3")
	local vector = self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()
	local direction = vector:Normalized()
	local dist = vector:Length2D()
	if dist <= 150 then return end 
	if dist > dist_max then 
		self:GetParent():RemoveModifierByName("modifier_lination_damage")
		self:Destroy()
	end
	FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin() + direction * self:GetAbility():GetSpecialValueFor("pull_speed") * FrameTime(), true)
end
LinkLuaModifier("modifier_lination_damage", "custom_abilities/feral_ghoul/ability_ferral_goul_libation.lua", LUA_MODIFIER_MOTION_NONE)
modifier_lination_damage = class({})
function modifier_lination_damage:IsHidden() return true end
function modifier_lination_damage:IsPurgable() return true end

function modifier_lination_damage:OnCreated()
	self:StartIntervalThink(1)
	self:OnIntervalThink()
end

function modifier_lination_damage:OnIntervalThink(  )
		local damage = self:GetAbility():GetSpecialValueFor("damage")
		ApplyDamage({
		    victim = self:GetParent(),
		    attacker = self:GetCaster(),
		    damage = damage,
		    damage_type = self:GetAbility():GetAbilityDamageType(),
		    damage_flags = DOTA_DAMAGE_FLAG_NONE,
		    ability = self:GetAbility()
	  	})
	  	self:GetCaster():Heal(damage, self:GetCaster())
end

	-- local vector = self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()
	-- local direction = vector:Normalized()
	-- local dist = vector:Length2D()
	-- if dist <= 150 then return end 
	--FindClearSpaceForUnit(self:GetParent(), self:GetCaster():GetAbsOrigin() + direction * self:GetAbility():GetSpecialValueFor("pull_speed"), true)

-- Притягивание по кругу
	-- local vector = self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
	-- vector.z = 0
	-- local target_pull = vector:Length2D() - 30(К цели) * FrameTime()
	-- local direction = vector:Normalized()
	-- local dec = math.atan2(direction.y, direction.x)
	-- local target_abs = Vector(math.cos(dec + 0.25 * FrameTime()), math.sin(dec + 0.25(По  кругу) * FrameTime()), 0)
	-- FindClearSpaceForUnit(self:GetParent(), self:GetCaster():GetAbsOrigin() + target_abs * target_pull, true)