LinkLuaModifier("modifier_ability_slardar_sprint", "/heroes/hero_drow_ranger/drow_ranger_ult/drow_ranger_ult_onspellstart.lua", 0)
LinkLuaModifier( "modifier_frost_arrow_target_stack", "/heroes/hero_drow_ranger/drow_ranger_ult/modifier_frost_arrow_target_stack", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_frost_arrow_target", "/heroes/hero_drow_ranger/drow_ranger_ult/modifier_frost_arrow_target", LUA_MODIFIER_MOTION_NONE )

if ability_drow_ult == nil then
   ability_drow_ult = class({})
end

function ability_drow_ult:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_drow_attckrange", {duration = duration})

	caster:EmitSound("Hero_Slardar.Sprint")
end

function modifier_drow_attckrange: OnCreated()
	local caster = self:GetCaster()
	IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    DeclareFunctions        = function(self)
    return {
    	MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    	MODIFIER_STATE_CANNOT_MISS
    }
    GetAttackSound          = function(self) return "sounds/weapons/hero/drow_ranger/frost_arrow4.vsnd" end,
end,	

	function launch ( keys )
	    local ability = keys.ability
	    local caster = keys.caster
	    local target = keys.target
	    local projectile_speed = keys.projectile_speed
	    local particle_name = keys.particle_name
	    print ("Now we launch the projectile")
	    Timers:CreateTimer({
	    endTime = 0.5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
	    callback = function()
	      print ("Hello. I'm running 0.5 seconds after when I was started.")
	      -- Create the projectile
	    local info = {
	        Target = target,
	        Source = caster,
	        Ability = ability,
	        EffectName = particle_name,
	        bDodgeable = false,
	        bProvidesVision = true,
	        iMoveSpeed = projectile_speed,
	        iVisionRadius = 300,
	        iVisionTeamNumber = caster:GetTeamNumber(),
	        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	    }
	    ProjectileManager:CreateTrackingProjectile( info )
	    print ("Projectile launched!")
	    end
	  })
	end

	function count_stacks( keys )
	    local caster = keys.caster
	    local ability = keys.ability
	    local target = keys.target
	    local maxStack = keys.maxStack
	    local modifierCount = target:GetModifierCount()
	    local currentStack = 0
	    local modifierBuffName = "modifier_frost_arrow_target"
	    local modifierStackName = "modifier_frost_arrow_target_stack"
	    local modifierName
	 
	    -- Always remove the stack modifier
	    target:RemoveModifierByName(modifierStackName) 
	 
	    -- Counts the current stacks
	    for i = 0, modifierCount do
	        modifierName = target:GetModifierNameByIndex(i)
	 
	        if modifierName == modifierBuffName then
	            currentStack = currentStack + 1
	        end
	    end
	 
	    -- Remove all the old buff modifiers
	    for i = 0, currentStack do
	        print("Removing modifiers")
	        target:RemoveModifierByName(modifierBuffName)
	    end
	 
	    -- Always apply the stack modifier 
	    target:AddNewModifier(caster, ability, modifierStackName, {duration = 4})
	 
	    -- Reapply the maximum number of stacks
	    if currentStack >= maxStack then
	        target:SetModifierStackCount(modifierStackName, ability, maxStack)
	 
	        -- Apply the new refreshed stack
	        for i = 1, maxStack do
	            target:AddNewModifier(caster, ability, modifierBuffName, {duration = 4})
	        end
	    else
	        -- Increase the number of stacks
	        currentStack = currentStack + 1
	 
	        target:SetModifierStackCount(modifierStackName, ability, currentStack)
	 
	        -- Apply the new increased stack
	        for i = 1, currentStack do
	            target:AddNewModifier(caster, ability, modifierBuffName, {duration = 4})
	        end
	    end
	    print ("Stacks applied!")
	end
