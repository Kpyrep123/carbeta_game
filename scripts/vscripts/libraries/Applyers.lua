function attackField( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1)) + caster:GetTalentValue("special_bonus_unique_azura_2")
    local shroud_shard_aura = "modifier_attack_field_shard"
    local shroud_aura = "modifier_attack_field"
    if caster:HasModifier("modifier_item_aghanims_shard") then
        ability:ApplyDataDrivenModifier(caster, caster, shroud_shard_aura, { Duration = duration } )
        ability:ApplyDataDrivenModifier(caster, caster, shroud_aura, { Duration = duration } )
    else
        ability:ApplyDataDrivenModifier(caster, caster, shroud_aura, { Duration = duration } )
    end
end 


function PerfAt( params )
local caster = params.caster
local target = params.target
local ability = params.ability
local duration = ability:GetLevelSpecialValueFor("fake_dur", (ability:GetLevel() -1))
local second_strike_delay = ability:GetSpecialValueFor("second_strike_delay");
local great_cleave_damage = ability:GetSpecialValueFor( "great_cleave_damage" )
local great_cleave_radius_start = ability:GetSpecialValueFor( "great_cleave_radius" )
local great_cleave_radius_end = ability:GetSpecialValueFor( "great_cleave_radius_end" )
local mod = "modifier_battle_visual"
local damage = caster:GetAttackDamage()
local cleaveDamage = ( great_cleave_damage * damage ) / 100.0
local radius = ability:GetSpecialValueFor( "radius" )

if caster:HasScepter() then
caster:PerformAttack(target, true, true, true, true, false, false, true)
    DoCleaveAttack( caster, target, ability, cleaveDamage, great_cleave_radius_start, great_cleave_radius_end, radius, "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength_crit.vpcf" )
ability:ApplyDataDrivenModifier(caster, target, mod, { Duration = duration } )
end
end