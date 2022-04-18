ability_nova_protective_drone = class({})

function ability_nova_protective_drone:OnSpellStart()
	local target = self:GetCursorPosition()
	local caster = self:GetCaster()
	local ability = self
	local ability_level = ability:GetLevel() - 1
	local duration = self:GetSpecialValueFor("duration")
    local dummy = FastDummy(self:GetCursorPosition(), self:GetCaster():GetTeam(), 3, 3)
	drone = CreateUnitByName("unit_drone", caster:GetAbsOrigin(), false, nil, nil, self:GetCaster():GetTeamNumber())
	drone:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
    local ab = drone:AddAbility("ability_nova_protection_aura")
    ab:SetLevel(self:GetLevel())
	drone:SetForwardVector(caster:GetForwardVector())
    drone:AddNewModifier(caster, self, "modifier_flying_sound", {duration = duration})
        if RollPercentage(100) then
            if not self.uncommon_responses then
                self.uncommon_responses = {
                    "drone3",
                    "drone2",
                    "drone1",
                    "drone4",
                    "drone5"
                }
            end        
            self:GetCaster():EmitSound(self.uncommon_responses[RandomInt(1, #self.uncommon_responses)])
        end
    RollPercentage(100)
	Timers:CreateTimer(0.3, function()
		drone:MoveToPosition(dummy:GetAbsOrigin())
		drone:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
	end)
end

ability_nova_protection_aura = class({})

function ability_nova_protection_aura:GetIntrinsicModifierName(  )
    return "modifier_nova_protective_drone_aura"
end


LinkLuaModifier("modifier_nova_protective_drone_aura", "heroes/hero_sniper/protective_drone.lua", LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_flying_sound", "heroes/hero_sniper/protective_drone.lua", LUA_MODIFIER_MOTION_NONE)

modifier_flying_sound = class({})
function modifier_flying_sound:IsHidden() return true end
function modifier_flying_sound:IsPurgable() return false end

function modifier_flying_sound:OnCreated()
    self:StartIntervalThink(1.9)
    self:OnIntervalThink()
end
function modifier_flying_sound:OnIntervalThink(  )
    EmitSoundOn("dronewings", self:GetParent())
end
function modifier_flying_sound:OnRefresh()
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_nova_protective_drone", "heroes/hero_sniper/protective_drone.lua", LUA_MODIFIER_MOTION_NONE)
modifier_nova_protective_drone_aura = class({})
function modifier_nova_protective_drone_aura:IsHidden() return false end
function modifier_nova_protective_drone_aura:IsPurgable() return false end
function modifier_nova_protective_drone_aura:IsAura() return true end
function modifier_nova_protective_drone_aura:GetEffectName() return "particles/econ/courier/courier_trail_orbit/courier_trail_orbit.vpcf" end
function modifier_nova_protective_drone_aura:GetEffectAttachType(  )
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_nova_protective_drone_aura:GetModifierAura()
    return "modifier_nova_protective_drone"
end
function modifier_nova_protective_drone_aura:GetVisualZDelta(kv)
    return self:GetStackCount()
end
function modifier_nova_protective_drone_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------
function modifier_nova_protective_drone_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end
function modifier_nova_protective_drone_aura:OnCreated()
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
        EmitSoundOn("dronework", self:GetParent())
        self:StartIntervalThink(0.05)
        self:OnIntervalThink()
end
function modifier_nova_protective_drone_aura:OnIntervalThink(  )
    if self:GetStackCount() >= 300 then return end
    self:SetStackCount(self:GetStackCount()+5)
end
function modifier_nova_protective_drone_aura:OnRefresh()
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_nova_protective_drone_aura:GetAuraRadius(  )
    return self.radius
end
function modifier_nova_protective_drone_aura:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_VISUAL_Z_DELTA,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_DEATH,
    }
    return funcs
end

function modifier_nova_protective_drone_aura:GetModifierIncomingDamage_Percentage(kv)
    return -100
end

----------------------------------------------------------------------------------
function modifier_nova_protective_drone_aura:OnAttackLanded(kv)
    local parent = self:GetParent()
    if kv.target == parent then
        if self:GetParent():GetHealth() == 1 then
            parent:Kill(nil, kv.attacker)
        else
            parent:SetHealth(parent:GetHealth() - 1)
        end
    end
end
function modifier_nova_protective_drone_aura:OnAbilityFullyCast( params )
    if params.unit:HasModifier("modifier_nova_protective_drone") then 
    if self:GetParent():GetHealth() == 1 then
       self:GetParent():Kill(nil, params.ability:GetCaster())
        else
       self:GetParent():SetHealth(self:GetParent():GetHealth() - 1)
    end 
        self:GetCaster():PerformAttack(params.ability:GetCaster(), true, true, true, true, false, false, true)
    end
end
----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

modifier_nova_protective_drone = class({})
function modifier_nova_protective_drone:IsHidden() return false end
function modifier_nova_protective_drone:IsPurgable() return false end
function modifier_nova_protective_drone:GetEffectName(  )
    return "particles/units/heroes/hero_tinker/tinker_defense_matrix.vpcf"
end

function modifier_nova_protective_drone:GetEffectAttachType(  )
    return PATTACH_CUSTOMORIGIN
end
function modifier_nova_protective_drone:OnCreated()

end

function modifier_nova_protective_drone:OnRefresh()

end


function modifier_nova_protective_drone:DeclareFunctions()
    local tal = {
        MODIFIER_PROPERTY_ABSORB_SPELL,
        MODIFIER_PROPERTY_REFLECT_SPELL,
    }

        return tal

end

function modifier_nova_protective_drone:GetAbsorbSpell( params )
    if IsServer() then
        if self:GetAbility():IsFullyCastable() then
            self:GetAbility():UseResources( true, false, true )

            self:PlayEffects( true )
                if self:GetCaster():GetHealth() == 1 then
               self:GetCaster():Kill(nil, self:GetCaster())
                else
               self:GetCaster():SetHealth(self:GetCaster():GetHealth() - 1)
            end 
            return 1
        end
    end
end

function modifier_nova_protective_drone:GetReflectSpell( params )
    if IsServer() then
        -- If unable to reflect due to the source ability
        if params.ability==nil or self.reflect_exceptions[params.ability:GetAbilityName()] then
            return 0
        end
    local buildings = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),   -- int, your team number
        Vector(0,0,0),  -- point, center point
        nil,    -- handle, cacheUnit. (not known)
        FIND_UNITS_EVERYWHERE,  -- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, -- int, team filter
        DOTA_UNIT_TARGET_HERO,  -- int, type filter
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE, -- int, flag filter
        0,  -- int, order filter
        false   -- bool, can grow cache
    )

    local fountain = nil
    for _,building in pairs(buildings) do
        if building:GetName()=="npc_dota_hero_sniper" then
            fountain = building
            break
        end
    end
        if fountain:HasShard() and self:GetAbility():IsFullyCastable() then
            -- use resources
            self.reflect = true

            -- remove previous ability
            if self.reflected_spell~=nil then
                self:GetParent():RemoveAbility( self.reflected_spell:GetAbilityName() )
            end

            -- copy the ability
            local sourceAbility = params.ability
            local selfAbility = self:GetParent():AddAbility( sourceAbility:GetAbilityName() )
            selfAbility:SetLevel( sourceAbility:GetLevel() )
            selfAbility:SetStolen( true )
            selfAbility:SetHidden( true )

            -- store the ability
            self.reflected_spell = selfAbility

            -- cast the ability
            self:GetParent():SetCursorCastTarget( sourceAbility:GetCaster() )
            selfAbility:CastAbility()
            if selfAbility:GetName() == "huskar_berserkers_blood_lod" then
            Timers:CreateTimer(0.03, function()
                self:GetParent():RemoveModifierByName("modifier_huskar_berserkers_blood_lod")
            end)
        end
            -- play effects
            self:PlayEffects( true )
            return 1
        end
    end
end

modifier_nova_protective_drone.reflect_exceptions = {
    ["rubick_spell_steal_lua"] = true
}

function modifier_nova_protective_drone:OnSpentMana(  )
    if params.unit ~= self:GetParent() then return end
    self:GetParent():SetMana(self:GetParent():GetMana() + params.cost)
end

function modifier_nova_protective_drone:PlayEffects( bBlock )
    -- Get Resources
    local particle_cast = ""
    local sound_cast = ""

    if bBlock then
        particle_cast = "particles/units/heroes/hero_tinker/tinker_laser_secondary.vpcf"
        sound_cast = "droneshot"
    else
        particle_cast = "particles/econ/items/tinker/tinker_ti10_immortal_laser/tinker_ti10_immortal_laser.vpcf"
        sound_cast = "droneshot1"
    end
local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    local attach = "attach_origin"
    ParticleManager:SetParticleControlEnt(
        effect_cast,
        9,
        self:GetCaster(),
        PATTACH_POINT_FOLLOW,
        attach,
        Vector(0,0,0), -- unknown
        true -- unknown, true
    )
        ParticleManager:SetParticleControlEnt(
        effect_cast,
        1,
        self:GetParent(),
        PATTACH_POINT_FOLLOW,
        "attach_hitloc",
        Vector(0,0,0), -- unknown
        true -- unknown, true
    )
    ParticleManager:ReleaseParticleIndex( effect_cast )

    -- Play sounds
    EmitSoundOn( sound_cast, self:GetParent() )


end

