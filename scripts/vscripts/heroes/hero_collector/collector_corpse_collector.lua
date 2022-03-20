--[[ Author: TheGreatGimmick
	Date: March 20, 2017
Altered from:
Author: Pizzalol
	Date: 24.03.2015.
	Creates the land mine and keeps track of it

	Collector's E, Corpse Collecter
	]]

--Spawn Ghoul
function WakeyWakey( keys )
	print("")
	print("Ghoul created.")
	local caster = keys.caster
	local point = caster:GetAbsOrigin()
	local ability = keys.ability

	local fv = caster:GetForwardVector()
	local ability_level = ability:GetLevel() - 1

	-- Initialize the count and table
	caster.ghoul_count = caster.ghoul_count or 0
	caster.ghoul_table = caster.ghoul_table or {}

	-- Modifiers
	local modifier_ghoul = keys.modifier_ghoul
	local modifier_ghoul_invisibility = keys.modifier_ghoul_invis
	local modifier_ghoul_fade = keys.modifier_ghoul_fade

	-- Ability variables
	local activation_time = ability:GetLevelSpecialValueFor("activation_time", ability_level) 
	local max_ghouls = ability:GetLevelSpecialValueFor("max", ability_level)

	    local talent_name = "special_bonus_unique_collector"
    	if caster:HasAbility(talent_name) then
    		local talent_level = caster:FindAbilityByName(talent_name):GetLevel()
    		if talent_level > 0 then
    			max_ghouls = max_ghouls + 2
    		end
    	end

	local fade_time = ability:GetLevelSpecialValueFor("fadetime", ability_level)

	-- Create the land mine and apply the land mine modifier
	local ghoul = CreateUnitByName("corpse_collector_ghoul", point, false, nil, nil, caster:GetTeamNumber())
	ghoul:SetForwardVector(fv)
    ghoul:SetControllableByPlayer(caster:GetPlayerID(), true)
    ghoul:SetOwner(caster)

	-- Update the count and table
	caster.ghoul_count = caster.ghoul_count + 1
	table.insert(caster.ghoul_table, ghoul)

	-- Put this any where, it only needs to run once
SendToServerConsole("dota_combine_models 0")

-- Assuming you pass unit as parameter
local model = ghoul:FirstMoveChild()
while model ~= nil do
    if model:GetClassname() == "dota_item_wearable" then
        if model:GetModelName() ~= "models/heroes/undying/undying.vmdl" then
            model:AddEffects(EF_NODRAW) -- Set model hidden
        else
            model:RemoveEffects(EF_NODRAW) -- In case it was hidden somewhere
        end
    end
    model = model:NextMovePeer()
end

	-- If we exceeded the maximum number of Ghouls then kill the oldest one
	if caster.ghoul_count > max_ghouls then
		caster.ghoul_table[1]:ForceKill(true)
	end

	-- Apply the invisibility after the fade time
	--Timers:CreateTimer(fade_time, function()
		ability:ApplyDataDrivenModifier(caster, ghoul, modifier_ghoul_invisibility, {})
		ability:ApplyDataDrivenModifier(caster, ghoul, modifier_ghoul_fade, {})
	--end)
	ability:ApplyDataDrivenModifier(caster, ghoul, modifier_ghoul, {})
	ghoul:AddNewModifier(ghoul, nil, "modifier_phased", { duration = 1 })
end

--[[
Altered from:
Author: Pizzalol
	Date: 24.03.2015.
	Stop tracking the mine and create vision on the mine area]]
function Naptime( keys )
	print("")
	print("Ghoul Killed")
	local caster = keys.caster
	local unit = keys.unit
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Find the Ghoul and remove it from the table
	for i = 1, #caster.ghoul_table do
		if caster.ghoul_table[i] == unit then
			table.remove(caster.ghoul_table, i)
			caster.ghoul_count = caster.ghoul_count - 1
			break
		end
	end
end

--Handle Ghoul bash and/or death
function Collect(event)
	print("")
	print("Ghoul attacked")
	local ghoul = event.attacker
	local target = event.target
	local ability = event.ability

	local stun = ability:GetLevelSpecialValueFor("stun", (ability:GetLevel() - 1))
	Timers:CreateTimer(0.01, function()
		if target:IsAlive() then
			if not target:IsBuilding() then
				print("Target survived.")
				target:AddNewModifier(ghoul, nil, "modifier_stunned", { duration = stun })
				target:EmitSound("Hero_Slardar.Bash")
			end
			ghoul:ForceKill(true)
		end
	end)
end

