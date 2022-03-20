--[[
    Author: kritth
    Date: 6.1.2015.
    Register target
]]
function assassinate_register_target( keys )
    keys.caster.assassinate_target = keys.target
end

--[[
    Author: kritth
    Date: 6.1.2015.
    Remove debuff from target
]]
function assassinate_remove_target( keys )
    if keys.caster.assassinate_target then
        keys.caster.assassinate_target:RemoveModifierByName( "modifier_assassinate_target_datadriven" )
        keys.caster.assassinate_target = nil
    end
end


--[[Glaives of Wisdom intelligence to damage
    Author: chrislotix
    Date: 10.1.2015.]]

function DamageToDamage( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local int_caster = caster:GetAttackDamage()
    local int_damage = ability:GetLevelSpecialValueFor("Damage_to_damage", (ability:GetLevel() -1)) + caster:GetTalentValue("nova_modifier_bonus_snipeshot")

    
    

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = int_caster * int_damage / 100

    ApplyDamage(damage_table)
end

function AghPerformAttack( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local track_aura = "modifier_track_aura_datadriven"
    local track = "modifier_track_datadriven"
    if caster:HasScepter() then
        ability:ApplyDataDrivenModifier(caster, target, track_aura, {} )
        ability:ApplyDataDrivenModifier(caster, target, track, {} )
   else
    return nil
end

end