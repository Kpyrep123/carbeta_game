LinkLuaModifier( "modifier_spike_shell_scepter", "heroes/spike/modifiers/modifier_spike_shell", LUA_MODIFIER_MOTION_NONE )
modifier_spike_shell = class({})
--------------------------------------------------------------------------------

function modifier_spike_shell:IsHidden()
	return self:GetStackCount()==100
end

--------------------------------------------------------------------------------

function modifier_spike_shell:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_spike_shell:DestroyOnExpire()
	return false
end

function modifier_spike_shell:OnCreated( kv )
	local ability = self:GetAbility()
		self.hp = self:GetCaster():GetMaxHealth()
		self.hp_now = self:GetCaster():GetHealth()	
		
	if not ability then return end

	self.returnDamage = (ability:GetSpecialValueFor("return_damage")) / 100
	self:StartIntervalThink(0.001)
	self:OnIntervalThink()


	local ValakasHead = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/axe/axe_blackthorn_head/axe_blackthorn_head.vmdl"})
    ValakasHead:FollowEntity(self:GetCaster(), true)
    local Valakasbelt = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/axe/axe_blackthorn_belt/axe_blackthorn_belt.vmdl"})
    Valakasbelt:FollowEntity(self:GetCaster(), true)
    local arm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/axe/axe_blackthorn_misc/axe_blackthorn_misc.vmdl"})
    arm:FollowEntity(self:GetCaster(), true)

end

modifier_spike_shell.OnRefresh = modifier_spike_shell.OnCreated

function modifier_spike_shell:GetAttributes() 
    return MODIFIER_ATTRIBUTE_PERMANENT
end

if IsServer() then
	function modifier_spike_shell:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
		}

		return funcs
	end

	function modifier_spike_shell:OnTakeDamage( params )
		local parent = self:GetParent()
		
	    if params.unit ~= parent then return end

	    if not parent or parent:IsNull() then return end

	    if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= 0 then return end 

	    local ability = self:GetAbility()

	    if not ability or ability:IsNull() then return end

	    if parent:PassivesDisabled() then return end 

	    local takeDamage = params.damage
	    
	    local resultDamage = takeDamage * ( (self.returnDamage * (self:GetStackCount() / 100)) + parent:GetTalentValue( "spike_special_bonus_shell_25") / 100 )

	    if resultDamage == 0 then return end

        if params.attacker:IsInvulnerable() then return end

        if parent:HasTalent("spike_special_bonus_shell_block") then
            if parent:GetHealth() > takeDamage - resultDamage then
                parent:Heal(resultDamage, ability)
            end
        end
        local base_damage = self:GetAbility():GetSpecialValueFor("creep_damage")
        ApplyDamage({
            victim 		 = params.attacker,
            attacker 	 = parent,
            damage 		 = resultDamage,
            damage_type  = DAMAGE_TYPE_PURE,
            ability 	 = self:GetAbility(),
            damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
        })
        if params.attacker:IsCreep() then 
        		ApplyDamage({
		            victim 		 = params.attacker,
		            attacker 	 = parent,
		            damage 		 = base_damage,
		            damage_type  = DAMAGE_TYPE_PURE,
		            ability 	 = self:GetAbility(),
		            damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
        	  	})
       end
		if self:GetCaster():HasScepter() then 
			if params.attacker:IsRealHero() then
        	params.attacker:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_spike_shell_scepter", {})
        	Timers:CreateTimer(0.0001, function()
        		local stacks = params.attacker:FindModifierByName("modifier_spike_shell_scepter")
        		if stacks:GetStackCount() + params.damage > self:GetCaster():GetMaxHealth() / 2 then 
        			stacks:SetStackCount(0)
        			illusion = CreateIllusion(params.attacker,self:GetCaster(),params.attacker:GetAbsOrigin(), 5,100,100)
        			illusion:SetForceAttackTarget(params.attacker)
        			illusion:AddNewModifier(self:GetCaster(), nil, modifier_invulnerable, {})
        		else
        			stacks:SetStackCount(params.damage + stacks:GetStackCount())

        		end
        	end)
        end

    end

        print(params.damage)
        print(resultDamage)
	end

	function testflag(set, flag)
	  return set % (2*flag) >= flag
	end
	function modifier_spike_shell:OnIntervalThink()
		if self:GetParent():GetHealthPercent() > 66 then 
			self:SetStackCount(100)
		else
		self:SetStackCount(299 - (self:GetParent():GetHealthPercent() * 3 ))
		end
	end

end


modifier_spike_shell_scepter = class({})

function modifier_spike_shell_scepter:IsHidden()
	return false
	-- body
end

function modifier_spike_shell_scepter:IsPurgable()
	return false
	-- body
end

function modifier_spike_shell_scepter:IsPermanent()
	return true
end

function modifier_spike_shell_scepter:GetTexture()
	return "custom/suna_dead_mans_chest"
	-- body
end