reaver_lord_soul_collector_lua = class({})

LinkLuaModifier("modifier_reaver_lord_soul_collector_passive", "heroes/reaver_lord/soul_collector_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_reaver_lord_soul_collector_passive_dummy", "heroes/reaver_lord/soul_collector_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_reaver_lord_soul_collector_passive_death", "heroes/reaver_lord/soul_collector_lua.lua", LUA_MODIFIER_MOTION_NONE)
function reaver_lord_soul_collector_lua:GetIntrinsicModifierName(  )
    return "modifier_reaver_lord_soul_collector_passive"
end


function reaver_lord_soul_collector_lua:OnInventoryContentsChanged()
    self:GetCaster():FindAbilityByName("reaver_lord_soul_burn"):SetLevel(1)
    self:GetCaster():FindAbilityByName("reaver_lord_soul_burn"):SetHidden(not self:GetCaster():HasShard())
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
modifier_reaver_lord_soul_collector_passive = class({})

function modifier_reaver_lord_soul_collector_passive:IsHidden(  )
    return true
end


function modifier_reaver_lord_soul_collector_passive:OnCreated(  )
end

function modifier_reaver_lord_soul_collector_passive:IsAura()                       return true end
function modifier_reaver_lord_soul_collector_passive:IsAuraActiveOnDeath()          return false end

function modifier_reaver_lord_soul_collector_passive:GetAuraRadius()                return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_reaver_lord_soul_collector_passive:GetAuraSearchFlags()           return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD end
function modifier_reaver_lord_soul_collector_passive:GetAuraSearchTeam()            return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_reaver_lord_soul_collector_passive:GetAuraSearchType()            return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_reaver_lord_soul_collector_passive:GetModifierAura()              return "modifier_reaver_lord_soul_collector_passive_death" end

function modifier_reaver_lord_soul_collector_passive:OnRefresh(  )

end

function modifier_reaver_lord_soul_collector_passive:OnDeath( params )
    if not IsServer() then return end
    if self:GetCaster():GetTeamNumber() == params.unit:GetTeamNumber() then return end
    if self:GetCaster() ~= params.attacker then return end

    local max_stacks = self:GetAbility():GetSpecialValueFor("max_souls") + self:GetCaster():GetTalentValue("special_bonus_unquie_max_souls_soul_collector")

    local stacks = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_reaver_lord_soul_collector_passive_dummy", {duration = self:GetAbility():GetSpecialValueFor("soul_duration")})
    if stacks:GetStackCount() < max_stacks then
        stacks:SetStackCount(stacks:GetStackCount() + 1)
        Timers:CreateTimer(self:GetAbility():GetSpecialValueFor("soul_duration"), function()
            stacks:SetStackCount(stacks:GetStackCount() - 1)
        end)
    end

end

function modifier_reaver_lord_soul_collector_passive:DeclareFunctions(  )
    return {
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_reaver_lord_soul_collector_passive:OnAttack( params )
    if not IsServer() then return end
    if not self:GetParent():IsRealHero() then return end
    if self:GetParent() ~= params.attacker then return end
    if self:GetCaster():PassivesDisabled() then return end
    if params.target:IsBuilding() or params.target:IsCreep() then return end
    local max_stacks = self:GetAbility():GetSpecialValueFor("max_souls") + self:GetCaster():GetTalentValue("special_bonus_unquie_max_souls_soul_collector")
    if self:GetStackCount() < 5 then  
        self:IncrementStackCount()
    else
        local stacks = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_reaver_lord_soul_collector_passive_dummy", {duration = self:GetAbility():GetSpecialValueFor("soul_duration")})
        if stacks:GetStackCount() < max_stacks then
            stacks:SetStackCount(stacks:GetStackCount() + 1)
            Timers:CreateTimer(self:GetAbility():GetSpecialValueFor("soul_duration"), function()
                stacks:SetStackCount(stacks:GetStackCount() - 1)
            end)
        end
        self:SetStackCount(1)
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

modifier_reaver_lord_soul_collector_passive_death = class({})

function modifier_reaver_lord_soul_collector_passive_death:IsHidden(  ) return true end

function modifier_reaver_lord_soul_collector_passive_death:IsPurgable(  ) return false end

function modifier_reaver_lord_soul_collector_passive_death:IsDebuff(  ) return true end



function modifier_reaver_lord_soul_collector_passive_death:DeclareFunctions(  )
    return {
        MODIFIER_EVENT_ON_DEATH,
    }
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
------------------------------------------------------------------------------FILLFILLFILLFILLFILLFILLFILL-----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
modifier_reaver_lord_soul_collector_passive_dummy = class({})

function modifier_reaver_lord_soul_collector_passive_dummy:IsHidden()
    return false  

end

function modifier_reaver_lord_soul_collector_passive_dummy:IsPurgable()
    return false
end

function modifier_reaver_lord_soul_collector_passive_dummy:OnCreated(  )
    self.bonus_damage = self:GetAbility():GetSpecialValueFor("damage_per_soul")
    self.hp_regen = self:GetAbility():GetSpecialValueFor("hp_regen")
end

function modifier_reaver_lord_soul_collector_passive_dummy:OnRefresh()
    self.bonus_damage = self:GetAbility():GetSpecialValueFor("damage_per_soul")
    self.hp_regen = self:GetAbility():GetSpecialValueFor("hp_regen")
end

function modifier_reaver_lord_soul_collector_passive_dummy:DeclareFunctions(  )
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
end

function modifier_reaver_lord_soul_collector_passive_dummy:GetModifierPreAttack_BonusDamage()
    if self:GetCaster():PassivesDisabled() then return else
    return self.bonus_damage * self:GetStackCount()
end
end

function modifier_reaver_lord_soul_collector_passive_dummy:GetModifierConstantHealthRegen( )
    if self:GetCaster():PassivesDisabled() then return else
    return self.hp_regen * self:GetStackCount()
end
end