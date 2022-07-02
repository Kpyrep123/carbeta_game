ability_demolist = class({})

function ability_demolist:GetIntrinsicModifierName(  )
	return "modifier_demolist"
end

function ability_demolist:OnSpellStart(  )
	self:GetCaster():ForceKill(false)
	print("Кастанул")
		ApplyDamage({
		    victim = self:GetCaster(),
		    attacker = self:GetCaster(),
		    damage = 5000,
		    damage_type = DAMAGE_TYPE_MAGICAL,
		    damage_flags = DOTA_DAMAGE_FLAG_NONE,
		    ability = self
	  	})
end

function ability_demolist:Spawn(  )
	self:SetLevel(1)
end

LinkLuaModifier("modifier_demolist", "demolist.lua", LUA_MODIFIER_MOTION_NONE)
modifier_demolist = class({})
function modifier_demolist:IsHidden() return true end
function modifier_demolist:IsPurgable() return false end

function modifier_demolist:OnCreated()
	self:StartIntervalThink(1.5)
	self:OnIntervalThink()
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_demolist:OnRefresh()
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_demolist:DeclareFunctions()
 local funcs = {

 }
return funcs
end

function modifier_demolist:OnIntervalThink(  )
		local caster = self:GetCaster()
		local aoe = self.radius


		local cast_pfx = ParticleManager:CreateParticle("particles/demolist/demolist_purge_timedialate.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(cast_pfx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(cast_pfx, 1, Vector(300 * 2, 0, 0))
		ParticleManager:ReleaseParticleIndex(cast_pfx)
		self:GetCaster():Purge(true, true, false, true, false)
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),caster:GetAbsOrigin(),nil,300,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
		for _, enemy in pairs(enemies) do
				-- Deal damage to nearby non-magic immune enemies
				enemy:Purge(true, true, false, true, false)
		end
end