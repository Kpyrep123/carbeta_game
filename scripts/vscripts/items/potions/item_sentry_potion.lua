--[[Author: TheGreatGimmick
    Date: Jan 3, 2017
    Creates the Eye of the Sun, 
    deletes the previous Eye of the Sun,
    and gives unobstructed vision and True Sight.]]

--used for unit "AI", and to give just enough vision to see the particle effects on spawn. 
function Spawn(entityKeyValues)
	AddFOWViewer(thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), 150, 12, true)
end

--gives True Sight while it is Day. Called by the Eye's ability All-Seer. 
function SentPotTrueSight(keys)
	local ability = keys.ability
	local caster = keys.caster

    	local units = FindUnitsInRadius(caster:GetTeamNumber(),
                             caster:GetAbsOrigin(),
                             nil,
                             1275,
                             DOTA_UNIT_TARGET_TEAM_ENEMY,
                             DOTA_UNIT_TARGET_ALL,
                             DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                             FIND_ANY_ORDER,
                             false)
		

		for _,unit in pairs(units) do
			unit:RemoveModifierByName('modifier_truesight')
       		unit:AddNewModifier(caster, ability, 'modifier_truesight', {duration = 0.5})
            --print("Applying True Sight to "..unit:GetName())
    	end
    --also, make the Eye invisible. 
    caster:AddNewModifier(caster, ability, "modifier_invisible", {duration = 0.5})
end