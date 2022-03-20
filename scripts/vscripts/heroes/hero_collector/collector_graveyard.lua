--[[Author: TheGreatGimmick
    Date: Mar 18, 2017
 ]]

--used for unit "AI", and to give just enough vision to see the particle effects on spawn. 
function Spawn(entityKeyValues)
	AddFOWViewer(thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), 175, 2, false)
end

-- Construct graveyard, and mark the current graveyard for deletion when a new graveyard is spawned. 
function Bury( event )
	local caster = event.caster
	local ability = event.ability
	local target = event.target
	local point = target:GetAbsOrigin()
	local origin = caster:GetAbsOrigin()

	target:SetOwner(caster)

-- Add the target to a table on the caster handle, to find them later
	if not caster.graveyard then caster.graveyard = {} end
	table.insert(caster.graveyard, target)

	local radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() - 1))
	local gravestones_count
	local fence_angle

	if radius == 300 then
		gravestones_count = 15
		fence_count = 8
	else
		gravestones_count = 25
		fence_count = 16
	end

	--print("Beginning graveyard creation around "..point..".")
	for count = 1, fence_count, 1 do 
		local fence_model = "models/props_structures/fence001.vmdl"
		local pos_ang = count*((2*math.pi)/fence_count)
		print("Fence number "..fence_count.." is at an angle of "..pos_ang)
		local position = Vector(point.x+radius*math.sin(pos_ang), point.y+radius*math.cos(pos_ang), point.z)

		local fence = CreateUnitByName("graveyard_fence", position, false, caster, caster, caster:GetTeam())
		fence:FindAbilityByName("graveyard_gravestone_passive"):SetLevel(1)
		fence:SetForwardVector((position-point)*-1)
		table.insert(caster.graveyard, fence)
	end

	for count = 1, gravestones_count, 1 do
		--print("")
		--print("Gravestone "..count)
		--print("")

		local pos_ang = 2*math.pi*math.random()
		local pos_mag = 0
		while pos_mag < 100 or pos_mag > (radius-100) do
			pos_mag = radius*math.random()
		end

		local position = Vector(point.x+pos_mag*math.sin(pos_ang), point.y+pos_mag*math.cos(pos_ang), point.z)

		--print("Angle: "..pos_ang)
		--print("Magnitude: "..pos_mag)
		--print("Resultant Position: "..position)
		--print("")

		local stone = CreateUnitByName("graveyard_gravestone", position, false, caster, caster, caster:GetTeam())
		local grave_type = math.random(1,9)

		if grave_type < 3 then grave_type = 3 end
		if grave_type > 5 then grave_type = 4 end


		local grave_model = "models/props_structures/gravestone00"..grave_type..".vmdl"
		--local fence_model = "models/props_structures/fence00"..grave_type..".vmdl"


		--print("Gravestone "..grave_type.." selected, resulting in a model of:")
		--print(grave_model)
		--print("")

		stone:SetModel(grave_model)
		stone:FindAbilityByName("graveyard_gravestone_passive"):SetLevel(1)
		table.insert(caster.graveyard, stone)
	end
end

--delete previos graveyard when current graveyard is spawned. 
function Renovate( event )
	local caster = event.caster
	local targets = caster.graveyard or {}
	for _,unit in pairs(targets) do	
		if unit and IsValidEntity(unit) then
			--unit:ForceKill(true)
			unit:RemoveSelf()
		end
	end
-- Reset table
	caster.graveyard = {}
end

function Gentrification( event )
	local point = event.target_points[1]
	local caster = event.caster

	print("Checking for buildings")

	local buildings = FindUnitsInRadius(caster:GetTeamNumber(),
                             point,
                             nil,
                             800,
                             DOTA_UNIT_TARGET_TEAM_BOTH,
                             DOTA_UNIT_TARGET_BUILDING,
                              DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                             FIND_ANY_ORDER,
                             false)
	for _,unit in pairs(buildings) do
		if unit:IsTower() then
			print("Tower found, stopping caster.")
			caster:Stop()
		end
 	end
end

function GraveyardSearch( event )

	local caster = event.caster
	local collector = caster:GetOwner()
	local ability = collector:FindAbilityByName("collector_graveyard") 

	local rad = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() - 1))
	

		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                             caster:GetAbsOrigin(),
                             nil,
                             rad,
                             DOTA_UNIT_TARGET_TEAM_ENEMY,
                             DOTA_UNIT_TARGET_ALL,
                             DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                             FIND_ANY_ORDER,
                             false)

		local allies = FindUnitsInRadius(caster:GetTeamNumber(),
                             caster:GetAbsOrigin(),
                             nil,
                             rad,
                             DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                             DOTA_UNIT_TARGET_ALL,
                             DOTA_UNIT_TARGET_FLAG_NONE,
                             FIND_ANY_ORDER,
                             false)

		ability = event.ability

		for _,unit in pairs(enemies) do
			if collector:IsAlive() and unit:GetName() ~= "graveyard_gravestone" and unit:GetName() ~= "graveyard_fence" then
				ability:ApplyDataDrivenModifier(caster, unit, "modifier_graveyard_enemy", {duration = 0.3})
			end
		end

		for _,unit in pairs(allies) do
			if collector:IsAlive() and unit:GetName() ~= "graveyard_gravestone" and unit:GetName() ~= "graveyard_fence" then
				ability:ApplyDataDrivenModifier(caster, unit, "modifier_graveyard_ally", {duration = 0.3})
			end
		end

end

function EnemyCoffin( event )
	print("")
	print("Enemy has died in the Graveyard.")
	local target = event.unit
	
	if target:IsRealHero() then
		--Timers:CreateTimer(0.5, function ()
			local respawn1 = target:GetRespawnTime()
			print("Base respawn time: "..respawn1)

			local ability = event.caster:GetOwner():FindAbilityByName("collector_graveyard")
			local respawn_mult = ability:GetLevelSpecialValueFor("resp", (ability:GetLevel() - 1))

			print("Multiplier: "..respawn_mult)

			local respawn2 = respawn1*(1+respawn_mult)

			target:SetTimeUntilRespawn(respawn2)
			print("Set respawn time: "..respawn2)
		--end)
	end
end

function AllyCoffin( event )
	print("")
	print("Ally has died in the Graveyard.")
	local target = event.unit
	
	if target:IsRealHero() then

			local respawn1 = target:GetRespawnTime()
			print("Base respawn time: "..respawn1)

			local ability = event.caster:GetOwner():FindAbilityByName("collector_graveyard")
			local respawn_mult = ability:GetLevelSpecialValueFor("resp", (ability:GetLevel() - 1))

			print("Multiplier: "..respawn_mult)

			local respawn2 = respawn1*(1-respawn_mult)

			target:SetTimeUntilRespawn(respawn2)
			print("Set respawn time: "..respawn2)

	end
end