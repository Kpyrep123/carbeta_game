--[[Author: TheGreatGimmick
    Date: Jan 3, 2017
    Creates the Eye of the Sun, 
    deletes the previous Eye of the Sun,
    and gives unobstructed vision and True Sight.]]

--used for unit "AI", and to give just enough vision to see the particle effects on spawn. 
function Spawn(entityKeyValues)
	AddFOWViewer(thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), 175, 2, false)
    thisEntity:SetContextThink("EyeSunVision", EyeSunVision, 1)
end

--gives unobstructed vision while it is Day and the Eye is alive. 
function EyeSunVision()
    if thisEntity:IsAlive() then
        if GameRules:IsDaytime() then
            local eye = thisEntity:GetOwner():FindAbilityByName("horus_eye_of_the_sun")
            local radius = eye:GetLevelSpecialValueFor("radius", (eye:GetLevel() - 1))
    		AddFOWViewer(thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), radius, 1, false)
        end
    	return 1
    end
end

--gives True Sight while it is Day. Called by the Eye's ability All-Seer. 
function EyeSunTrueSight(keys)
	local ability = keys.ability
	local caster = keys.caster

    local eye = caster:GetOwner():FindAbilityByName("horus_eye_of_the_sun")
    local radius = eye:GetLevelSpecialValueFor("radius", (eye:GetLevel() - 1))


    if GameRules:IsDaytime() then
    	local units = FindUnitsInRadius(caster:GetTeamNumber(),
                             caster:GetAbsOrigin(),
                             nil,
                             radius,
                             DOTA_UNIT_TARGET_TEAM_ENEMY,
                             DOTA_UNIT_TARGET_ALL,
                             DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                             FIND_ANY_ORDER,
                             false)
		

		for _,unit in pairs(units) do
			unit:RemoveModifierByName('modifier_truesight')
       		unit:AddNewModifier(caster, ability, 'modifier_truesight', {duration = 0.5})
    	end
    end
    --also, make the Eye invisible. 
    caster:AddNewModifier(caster, ability, "modifier_invisible", {duration = 0.5})
end

--mark the current eye for deletion when a new Eye is spawned. 
function SetEye( event )
	local caster = event.caster
	local target = event.target
	local fv = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	target:SetForwardVector(fv)
    target:SetOwner(caster)
-- Add the target to a table on the caster handle, to find them later
	table.insert(caster.Eye, target)
end

--delete previos Eye when current Eye is spawned. 
function KillEye( event )
	local caster = event.caster
	local targets = caster.Eye or {}

            local talent_name = "special_bonus_unique_horus2"
            if caster:HasAbility(talent_name) then
                local talent_level = caster:FindAbilityByName(talent_name):GetLevel()
                if talent_level > 0 then
                    event.ability:EndCooldown()
                end
            end

	for _,unit in pairs(targets) do	
		if unit and IsValidEntity(unit) then
			unit:ForceKill(true)
		end
	end
-- Reset table
	caster.Eye = {}
end