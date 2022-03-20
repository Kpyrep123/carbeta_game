--[[Author: TheGreatGimmick
    Date: Jan 24, 2017
    Creates and destroys Hazel's Black Cat]]

LinkLuaModifier("modifier_dummy_switch", "heroes/hero_hazel/modifiers/modifier_dummy_switch.lua", LUA_MODIFIER_MOTION_NONE)


--Spawn a new cat, marking it for deletion when a new one is spawned.  
function SetCat( event )
	local cast = event.caster 
    local ability = event.ability
    local caster = ability:GetOwner()
	local fv = cast:GetForwardVector()
	local origin = cast:GetAbsOrigin()
    local level = ability:GetLevelSpecialValueFor("catlevel", (ability:GetLevel() - 1))

    if not cast.black_cat_spawned_checker then cast.black_cat_spawned_checker = 1 end 

    caster.blackcat = CreateUnitByName("hazel_black_cat_"..level, origin, false, caster, caster, caster:GetTeam())

    local cat = caster.blackcat
	cat:SetForwardVector(fv)
    cat:SetControllableByPlayer(caster:GetPlayerID(), true)
end

--delete previos cat when current cat is spawned. 
function Curiosity( event )
	local caster = event.caster
    local cat = caster.blackcat
	if cat and IsValidEntity(cat) then
		cat:ForceKill(true)
		caster.black_cat_spawned_checker = 0
		Timers:CreateTimer(0.02, function ()
			caster.black_cat_spawned_checker = 1
		end)

	end
end

function Kitten( keys ) -- spell start
    print('')
    print('New cat.')
    local caster = keys.caster
    local ability = keys.ability
    local unit = caster.blackcat

    caster.testing_storage = caster.testing_storage or {}
    if #caster.testing_storage > 0 then
        for _,itemTable in pairs(caster.testing_storage) do
            for owner,name in pairs(itemTable) do
                local item = CreateItem(name, owner, owner)
                unit:AddItem(item)
                print(item:GetName().." added to "..unit:GetName())
            end
        end
    end
    caster.testing_storage = {}

    ability:ApplyDataDrivenModifier(caster, unit, keys.modifier, {})
    unit:AddNewModifier(unit, nil, "modifier_dummy_switch", {})
end

function Nineth( keys ) -- on take damage
    print('')
    print('Cat damaged')
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.unit

    if not target:IsAlive() then
        print('Cat died.')
        print('')
        for i=0,8 do
            local item = target:GetItemInSlot(i)
            if item then
                local name = item:GetName()
                if name ~= "item_rapier" and name ~= "item_gem" then
                    print(name..' stored.')
                    caster.testing_storage[i+1] = {[item:GetPurchaser()] = item:GetName()}
                end
            end
        end
    end
end

function NineLives( keys )
    local ability = keys.caster:GetOwner():FindAbilityByName("hazel_bad_omen")

    local cooldown = ability:GetCooldownTimeRemaining()

    Timers:CreateTimer(0, function ()
    	if keys.caster:GetOwner().black_cat_spawned_checker == 1 then
        	ability:EndCooldown()
        	ability:StartCooldown(cooldown/9)
        end
    end)
end
