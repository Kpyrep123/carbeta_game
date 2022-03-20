--[[Author: YOLOSPAGHETTI
	Date: February 13, 2016
	Gives the caster's team flying vision at the point of cast]]
function GiveVision(keys)
	caster = keys.caster
	ability = keys.ability
    local target = ability:GetCursorPosition()
	local flying_vision = ability:GetLevelSpecialValueFor( "flying_vision", ability:GetLevel() - 1 )
	local vision_duration = ability:GetLevelSpecialValueFor( "vision_duration", ability:GetLevel() - 1 )
	
	AddFOWViewer(caster:GetTeam(), ability:GetCursorPosition(), flying_vision, vision_duration, false)
end

function IntToDamage( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local target_hp = target:GetHealth()
    local hp_damage = ability:GetLevelSpecialValueFor("hp_dmg", (ability:GetLevel() -1)) + caster:GetTalentValue("special_bonus_cursed_1")
    

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = target_hp * hp_damage / 100

    ApplyDamage(damage_table)

end

function CreateThinker( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local modifier = "modifier_silence_bloodrite"
    local modifier1 = "modifier_emmy"
    if caster:HasTalent("special_bonus_cursed_3") then
    ability:ApplyDataDrivenModifier(caster, target, modifier, {} )
end
 if caster:HasModifier("modifier_item_aghanims_shard") then
    ability:ApplyDataDrivenModifier(caster, target, modifier1, {} )
end

end

function CreateThinkertrue( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local modifier = "modifier_silence_bloodrite"
    if caster:HasTalent("special_bonus_cursed_3") then
    ability:ApplyDataDrivenModifier(caster, target, modifier, {} )
end

end