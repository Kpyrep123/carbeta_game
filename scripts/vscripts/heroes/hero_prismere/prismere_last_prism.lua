function CheckVectors(keys)

	local caster = keys.caster
	local ability = keys.ability
	local caster_loc = caster:GetAbsOrigin()
	ability.caster = caster

	local dummy_search = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER,false)
	for _,unit in pairs(dummy_search) do
		if unit:HasModifier("modifier_kill") then
		unit:ForceKill(false)
		end
	end
	
	Timers:RemoveTimers(killAll)

	SpawnAngle = 0
	SpawnAngle_count = 1
	SpawnAngle_1 = 45
	SpawnAngle_2 = 90
	SpawnAngle_3 = 135
	SpawnAngle_4 = 180
	SpawnAngle_5 = 225
	SpawnAngle_6 = 270
	SpawnAngle_7 = 315
	SpawnAngle_8 = 360

	laser_particle = "particles/prismere_last_prism_b.vpcf"

--	Timers:CreateTimer({
--		endTime = 10,
--		callback = function()
--		print("KILL")
--  		Timers:Reprismere_last_prism
-- 	})

	bl1 = true
	bl2 = false
	bl3 = false
	bl4 = false

	unit_search  = FindUnitsInRadius(caster:GetTeamNumber(), caster_loc, nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER,false)

	--local target_point = caster_loc + caster:GetForwardVector() * 1600
	--test_dummy = CreateUnitByName("dummy_unit" , target_point, false, caster, caster, caster:GetTeamNumber())
	--ability:ApplyDataDrivenModifier(caster, test_dummy, "modifier_kill", {Duration = 10})
	--test_dummy:SetModelScale(10.0)

end

function GetSpawnLocation(keys)
	local ability = keys.ability 
	local target = keys.target 
	local count = keys.count
	local height = 300
	local pointA = caster:GetAbsOrigin() 
	local caster_loc = pointA
	local vectorA = caster:GetForwardVector()
	local length = 1600
	local pointB = (pointA + vectorA * length) + Vector(0,0, height)
	local pointC = pointB + Vector(0,0,height)
	local vectorB = (pointC - pointB):Normalized()
	local rotate_position = pointB + vectorB * height

	SpawnAngle = 0
	caster.prisms = {}

	for i=0, count-1 do
		local side_vector = caster_loc + caster:GetForwardVector() * length
		local Vec_1 = (Vector(caster_loc.x, caster_loc.y - length, caster_loc.z)) - caster_loc 
		local Vec_2 = side_vector - caster_loc
		local y_rotate = AngleCalculation(Vec_1, Vec_2)
		--local rotate_angle = rotate_angle_old + QAngle(0, y_rotate + 90, 0)
		if side_vector.x > caster_loc.x then
			rotate_angle_old = QAngle(0, y_rotate + 90, SpawnAngle)
		else
			rotate_angle_old = QAngle(0, (360 - y_rotate) + 90, SpawnAngle)
		end

		local pointD = RotatePosition(pointB, rotate_angle_old, rotate_position)

		table.insert(caster.prisms, pointD)
		SpawnAngle = SpawnAngle
	end
end

function SpawnLocation(keys)

	
	local caster = keys.caster
	local ability = keys.ability 
	local target = keys.target 
	local height = 300
	local pointA = caster:GetAbsOrigin() 
	local caster_loc = pointA
	local vectorA = caster:GetForwardVector()
	local length = 1600
	local pointB = (pointA + vectorA * length) + Vector(0,0, height)
	local pointC = pointB + Vector(0,0,height)
	local vectorB = (pointC - pointB):Normalized()
	local rotate_position = pointB + vectorB * height




	target:SetAbsOrigin(pointD)
	target:SetModel("models/development/invisiblebox.vmdl")

	ability:ApplyDataDrivenModifier(caster, target, "modifier_last_prism_dummy_movement", {Duration = 10})
	
end




function DummyMovement(keys)
	local ability = keys.ability
	local caster = ability.caster
	--local length = 200
	height = 300
	local angle = 1
	local newAngle = 0


	Timers:CreateTimer(function()
		local dummy_search = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST,false)
		for _,unit in pairs(dummy_search) do
			if unit:HasModifier("modifier_kill") then
				dummy = unit

				--Set different Angles for each dummy
				if SpawnAngle_count == 1 then
					SpawnAngle = SpawnAngle_1
				elseif SpawnAngle_count == 2 then
					SpawnAngle = SpawnAngle_2
				elseif SpawnAngle_count == 3 then
					SpawnAngle = SpawnAngle_3
				elseif SpawnAngle_count == 4 then
					SpawnAngle = SpawnAngle_4
				elseif SpawnAngle_count == 5 then
					SpawnAngle = SpawnAngle_5
				elseif SpawnAngle_count == 6 then
					SpawnAngle = SpawnAngle_6
				elseif SpawnAngle_count == 7 then
					SpawnAngle = SpawnAngle_7
				elseif SpawnAngle_count == 8 then
					SpawnAngle = SpawnAngle_8
				end

				target = dummy
				caster_loc = caster:GetAbsOrigin()
				pointA = caster:GetAbsOrigin() 
				vectorA = caster:GetForwardVector()
				length = 1600
				pointB = (pointA + vectorA * length) + Vector(0,0,height)
				pointC = pointB + Vector(0,0,height)
				vectorB = (pointC - pointB):Normalized()
				rotate_position = pointB + vectorB * height
				
				--rotate_angle = RotateOrientation(rotate_angle_old, QAngle(x_rotate , 0, 0))

				side_vector = caster_loc + caster:GetForwardVector() * 1600
				Vec_1 = (Vector(caster_loc.x, caster_loc.y - 1600, caster_loc.z)) - caster_loc 
				Vec_2 = side_vector - caster_loc
				y_rotate = AngleCalculation(Vec_1, Vec_2)

				if side_vector.x > caster_loc.x then
					rotate_angle_old = QAngle(0, y_rotate + 90, SpawnAngle)
				else
					rotate_angle_old = QAngle(0, (360 - y_rotate) + 90, SpawnAngle)
				end

				pointD = RotatePosition(pointB, rotate_angle_old, rotate_position)

				target:SetAbsOrigin(pointD)

				if height > 5 then
					height = height - 2
				end

				if SpawnAngle_count == 1 then
					SpawnAngle_1 = SpawnAngle_1 + angle
					SpawnAngle_count = SpawnAngle_count +1
					laser_particle = "particles/prismere_last_prism_b.vpcf"
					Laser(laser_particle, caster, ability, dummy)
				elseif SpawnAngle_count == 2 then
					SpawnAngle_2 = SpawnAngle_2 + angle
					SpawnAngle_count = SpawnAngle_count +1
					laser_particle = "particles/prismere_last_prism_b2.vpcf"
					Laser(laser_particle, caster, ability, dummy)
				elseif SpawnAngle_count == 3 then
					SpawnAngle_3 = SpawnAngle_3 + angle
					SpawnAngle_count = SpawnAngle_count +1
					laser_particle = "particles/prismere_last_prism_b3.vpcf"
					Laser(laser_particle, caster, ability, dummy)
				elseif SpawnAngle_count == 4 then
					SpawnAngle_4 = SpawnAngle_4 + angle
					SpawnAngle_count = SpawnAngle_count +1
					laser_particle = "particles/prismere_last_prism_b4.vpcf"
					Laser(laser_particle, caster, ability, dummy)
				elseif SpawnAngle_count == 5 then
					SpawnAngle_5 = SpawnAngle_5 + angle
					SpawnAngle_count = SpawnAngle_count +1
					laser_particle = "particles/prismere_last_prism_b5.vpcf"
					Laser(laser_particle, caster, ability, dummy)
				elseif SpawnAngle_count == 6 then
					SpawnAngle_6 = SpawnAngle_6 + angle
					SpawnAngle_count = SpawnAngle_count +1
					laser_particle = "particles/prismere_last_prism_b6.vpcf"
					Laser(laser_particle, caster, ability, dummy)
				elseif SpawnAngle_count == 7 then
					SpawnAngle_7 = SpawnAngle_7 + angle
					SpawnAngle_count = SpawnAngle_count +1
					laser_particle = "particles/prismere_last_prism_b7.vpcf"
					Laser(laser_particle, caster, ability, dummy)
				elseif SpawnAngle_count == 8 then
					SpawnAngle_8 = SpawnAngle_8 + angle
					SpawnAngle_count = 1
					laser_particle = "particles/prismere_last_prism_b8.vpcf"
					Laser(laser_particle, caster, ability, dummy)
				end
			end
		end
      return 1 / 5
    end)

    Timers:CreateTimer(function()

    	--Deal damage on laser hit:
		LaserHitDamage(ability, dummy)

	      return 1 / 10
    end)
end

function AngleCalculation(vectorA, vectorB)
	local A = vectorA
	local B = vectorB


	local calc_1 = A.x * B.x + A.y * B.y
	local lenA = math.sqrt(Sq(A.x) + Sq(A.y))
	local lenB = math.sqrt(Sq(B.x) + Sq(B.y))

	local cos_angle = calc_1 / (lenA * lenB)

	local angle_old = math.acos(cos_angle)

	local angle_new = 57.29577951 * angle_old

	return angle_new

end


function Sq(number)
	local square = number * number

	return square
end

function Laser(laser_particle, caster, ability, dummy)

	local projectileTable = {
		Source = caster,
		Target = dummy,
		Ability = ability,	
		EffectName = laser_particle,
       	iMoveSpeed = 1200,
		vSourceLoc= caster:GetAbsOrigin(),                
		bDrawsOnMinimap = false,                         
       	bDodgeable = false,                              
       	bIsAttack = false,                                
       	bVisibleToEnemies = true,                         
       	bReplaceExisting = false,                        
		bProvidesVision = true,                           
		iVisionRadius = 400,                              
		iVisionTeamNumber = caster:GetTeamNumber()        
	}
	ProjectileManager:CreateTrackingProjectile(projectileTable)
end

function RotateVector2D(v,theta)
    local xp = v.x*math.cos(theta)-v.y*math.sin(theta)
    local yp = v.x*math.sin(theta)+v.y*math.cos(theta)
    return Vector(xp,yp,v.z):Normalized()
end

function TestForLineIntersection(a, b, c, tr)
 
    local caster_loc = a
    local Test_Point = b
    local Test_Point_2 = c

    local test_bln = false
 
    --/////Create Line
    local Vect_1 = Test_Point_2 - Test_Point
 
    --/////Check t1 & t2
    local t1 = ((caster_loc.x - Test_Point.x) / Vect_1.x) * 10
    local t2 = ((caster_loc.y - Test_Point.y) / Vect_1.y) * 10
 
    local t1r = math.floor(t1)
    local t2r = math.floor(t2)
 
    --/////Check for Intersection
    local tolerance = - tr
    local i = tolerance
    while i <= -(tolerance) do     
        if (t1r == t2r or t1r== (t2r + i)) then
            test_bln = true
        end
        i = i + 1
    end
	return test_bln
end

function LaserHitDamage(ability, dummy)
	local caster = ability.caster
	local caster_loc = caster:GetAbsOrigin() 
	local dummy_loc = dummy:GetAbsOrigin()
	local ability_level = ability:GetLevel() - 1
	local damage = (ability:GetLevelSpecialValueFor("damage", ability_level)) / 10
	local dmg_Table = {
						attacker = caster,
						damage = damage,
						damage_type = DAMAGE_TYPE_MAGICAL,
						}
	local check = false
	for _,unit in pairs(unit_search) do
		local unit_loc = unit:GetAbsOrigin()
		check = TestForLineIntersection(unit_loc, dummy_loc, caster_loc, 15)
		if check == true and caster:HasModifier("modifier_last_prism_self") then
			dmg_Table.victim = unit
			ApplyDamage(dmg_Table)
			print(unit)
			print(unit:GetHealthDeficit())
		end
	end
end

--[[
function CheckPlayer(keys)   --/////http://pastebin.com/mgQ0ScKp
	Timers:CreateTimer({
    endTime = 1,
    callback = function()
      Timers:RemoveTimers(killAll)
    end
  	})
	Timers:CreateTimer(function()

	
	if bool == true then
	local caster = keys.caster
	local ability = keys.ability
	local caster_loc = caster:GetAbsOrigin()
	--[[
	local bool = true
	local dummy_search = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER,false)
	for _,unit in pairs(dummy_search) do
		if unit:HasModifier("modifier_kill") and bool == true then
			dummy = unit
			bool = false
		--unit:ForceKill(false)
		end
		if unit:HasModifier("modifier_kill") and bool == false then
			dummy_2 = unit
		end
	end
	
	local Test_Point = dummy:GetAbsOrigin()
	local Test_Point_2 = dummy_2:GetAbsOrigin() 



	--//Test_Point1 and 2 are Points, which can be units, etc or any other point in the world
	--//caster_loc is the player, which will be tested, if he walks over the line
	--//Use this with a timer in a short time Interval or set the tolerance higher
	--/////Vector 1:
	local Vect_1 = Test_Point_2 - Test_Point

	--/////Check Vector
	local t1 = ((caster_loc.x - Test_Point.x) / Vect_1.x) * 10
	local t2 = ((caster_loc.y - Test_Point.y) / Vect_1.y) * 10

	local t1r = math.floor(t1)
	local t2r = math.floor(t2)

	local tolerance = -(  10  )  --edit here for more or less tolerance
	local i = tolerance
	while i <= -(tolerance) do		
		if (t1r == t2r or t1r== (t2r + i)) and hit == false then
		print("WE GOT IT!!!")
		print(i)
		hit = true
		dummy:ForceKill(false)
		dummy_2:ForceKill(false)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_last_prism_speed", {Duration = 3})
		bool = false
		end
		i = i + 1
	end
	end


		return 1 / 30
    end)


end

]]
