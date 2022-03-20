--[[Author: TheGreatGimmick
    Date: Jan 18, 2017
    ]]
    
function SmokeDisjoint(event)
    local target = event.target
    target:EmitSound("DOTA_Item.SmokeOfDeceit.Activate")
    ProjectileManager:ProjectileDodge(target)
end

function SmokeCheck(event)

	local ability = event.ability
	local caster = event.caster
	local radius = 1000 --ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() - 1))

	local hero_enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                             caster:GetAbsOrigin(),
                             nil,
                             radius,
                             DOTA_UNIT_TARGET_TEAM_ENEMY,
                             DOTA_UNIT_TARGET_HERO,
                             DOTA_UNIT_TARGET_FLAG_NONE,
                             FIND_ANY_ORDER,
                             false)

	local building_enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                             caster:GetAbsOrigin(),
                             nil,
                             radius,
                             DOTA_UNIT_TARGET_TEAM_ENEMY,
                             DOTA_UNIT_TARGET_BUILDING,
                             DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                             FIND_ANY_ORDER,
                             false)
--[[
    if hero_enemies ~= nil or building_enemies ~= nil then
        caster:RemoveModifierByName("modifier_item_smoke_potion")
    end
    ]]

		for _,unit in pairs(hero_enemies) do
            if unit:IsIllusion() == false then
                caster:RemoveModifierByName("modifier_item_smoke_potion")
            end
        end

		for _,unit in pairs(building_enemies) do
            if unit:IsTower() == true then
                caster:RemoveModifierByName("modifier_item_smoke_potion")
            end
        end
end
