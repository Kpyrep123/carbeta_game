LinkLuaModifier( "modifier_soul_collection", 					"heroes/deus_novus/modifiers/modifier_soul_collection.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_soul_collection_incriment", 			"heroes/deus_novus/modifiers/modifier_soul_collection.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_soul_collection_incriment_damage", 	"heroes/deus_novus/modifiers/modifier_soul_collection.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_soul_collection_incriment_satellite", 	"heroes/deus_novus/modifiers/modifier_soul_collection.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_soul_collection = class({})

function modifier_soul_collection:IsHidden()
	return true
end

function modifier_soul_collection:IsAura()
	return true
end

function modifier_soul_collection:OnCreated()
	self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_soul_collection_incriment_damage", {})
	self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_soul_collection_incriment_satellite", {})
	-- body
end

function modifier_soul_collection:GetModifierAura()
	return "modifier_soul_collection_incriment"
end

function modifier_soul_collection:GetAuraRadius()
	return self.aura_radius
end

function modifier_soul_collection:GetAuraSearchTeam()
	if not self:GetParent():PassivesDisabled() then
		return DOTA_UNIT_TARGET_TEAM_BOTH
	end
end

function modifier_soul_collection:GetAuraSearchType()
	if self:GetCaster():HasShard() then
		return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	end
	
	return DOTA_UNIT_TARGET_HERO
end

function modifier_soul_collection:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_soul_collection:OnCreated( kv )
	-- references
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "aura_radius" ) -- special value
	max_stacks = (self:GetCaster():GetHealth() * self:GetAbility():GetSpecialValueFor("upgrade_cost")) / 100

end

function modifier_soul_collection:OnRefresh( kv )
	-- references
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "aura_radius" ) -- special value
	max_stacks = (self:GetCaster():GetHealth() * self:GetAbility():GetSpecialValueFor("upgrade_cost")) / 100
end

modifier_soul_collection_incriment = class({})

function modifier_soul_collection_incriment:IsHidden()
	return false
end

function modifier_soul_collection_incriment:OnTakeDamage( params )
	if params.unit ~= self:GetParent() then return end
	if not self:GetCaster():HasModifier("modifier_soul_collection_incriment_damage") then 
		
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_soul_collection_incriment_damage", {})
		local stacks = self:GetCaster():FindModifierByName("modifier_soul_collection_incriment_damage")
		Timers:CreateTimer(0.0001, function()
			
			stacks:SetStackCount(params.damage)
		end)
	else
		local stacks = self:GetCaster():FindModifierByName("modifier_soul_collection_incriment_damage")
		stacks:SetStackCount(params.damage + stacks:GetStackCount())
		if stacks:GetStackCount() + params.damage > max_stacks then 
			stacks:SetStackCount(1)
			if not self:GetCaster():HasModifier("modifier_soul_collection_incriment_satellite") then 
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_soul_collection_incriment_satellite", {})
			else
				satellite = self:GetCaster():FindModifierByName("modifier_soul_collection_incriment_satellite")
				if satellite:GetStackCount() < 3 then
					satellite:IncrementStackCount()
					else 
					return nil
				end
			end
		end
	end
end

function modifier_soul_collection_incriment:DeclareFunctions()
	return {
			MODIFIER_EVENT_ON_TAKEDAMAGE
			}
end



modifier_soul_collection_incriment_damage = class({})

function modifier_soul_collection_incriment_damage:IsHidden()
	return false
end

function modifier_soul_collection_incriment_damage:IsPermanent()
	-- body
	return true
end
function modifier_soul_collection_incriment_damage:GetTexture()
	return "heartstopper_aura"
end

modifier_soul_collection_incriment_satellite = class({})

function modifier_soul_collection_incriment_satellite:IsHidden()
	return false
end

function modifier_soul_collection_incriment_satellite:GetTexture()
	return "doom_bringer_doom_s"
end

function modifier_soul_collection_incriment_satellite:IsPermanent()
 	return true
end