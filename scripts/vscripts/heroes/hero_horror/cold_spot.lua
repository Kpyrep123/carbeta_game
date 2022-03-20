LinkLuaModifier("modifier_cold_spot_charges", "heroes/hero_horror/modifiers/modifier_cold_spot_charges.lua", LUA_MODIFIER_MOTION_NONE)

--[[Author: TheGreatGimmick
    Date: March 4, 2017
    ]]

--[[Author: kritth,Pizzalol
    Date: 18.01.2015.
    Keeps track of the current charges and replenishes them accordingly]]
function cold_spot_start_charge( event )
    -- Initial variables to keep track of different max charge requirements
    print('cold spot start charges')
    local caster = event.caster
    local ability = event.ability
    local transchars = caster:FindAbilityByName("horror_lastspell")

    caster.cold_spot_maximum_charges = ability:GetLevelSpecialValueFor( "max", ( ability:GetLevel() - 1 ) )

        local talent_name = "special_bonus_unique_horror2"
        if caster:HasAbility(talent_name) then
            local talent_level = caster:FindAbilityByName(talent_name):GetLevel()
            if talent_level > 0 then
                caster.cold_spot_maximum_charges = caster.cold_spot_maximum_charges + 3
            end
        end
    --*caster.cold_spot_maximum_cold_spots = ability:GetLevelSpecialValueFor("count", (ability:GetLevel() - 1))

    --[[* Initialize the current cold_spot count and the cold_spot table
    if caster.cold_spot_current_cold_spots == nil then caster.cold_spot_current_cold_spots = 0 end
    if caster.cold_spot_table == nil then caster.cold_spot_table = {} end
    ]]

    -- Only start charging at level 1
    if event.ability:GetLevel() ~= 1 then return end

    -- Variables    
    local modifierName = "modifier_cold_spot_charges" --"modifier_cold_spot_stack_counter_datadriven"
    
    -- Initialize stack
    caster:SetModifierStackCount( modifierName, transchars, 0 )
    caster.cold_spot_charges = caster.cold_spot_maximum_charges
    caster.start_charge = false
    caster.cold_spot_cooldown = 0.0
    
    caster:AddNewModifier(caster, transchars, modifierName, {})

    caster:SetModifierStackCount( modifierName, transchars, caster.cold_spot_maximum_charges )

    print(ability:GetName()..' has started the cold_spot charges.')

    -- create timer to restore stack
    Timers:CreateTimer( function()
            -- Restore charge
            local charge_replenish_time = ability:GetLevelSpecialValueFor( "chargerestoretime", ( ability:GetLevel() - 1 ) )

            transchars:EndCooldown()
            transchars:UseResources(false,false,true)
            local cooltest = transchars:GetCooldownTime()

            charge_replenish_time = charge_replenish_time*cooltest

            if caster.start_charge and caster.cold_spot_charges < caster.cold_spot_maximum_charges then
                print('A cold_spot charge is restored.')
                -- Calculate stacks
                local next_charge = caster.cold_spot_charges + 1
                caster:RemoveModifierByName( modifierName )
                if next_charge ~= caster.cold_spot_maximum_charges then
                    caster:AddNewModifier(caster, transchars, modifierName, { Duration = charge_replenish_time } )
                    cold_spot_start_cooldown( caster, charge_replenish_time )
                else
                    caster:AddNewModifier(caster, transchars, modifierName, {} )
                    caster.start_charge = false
                end
                caster:SetModifierStackCount( modifierName, transchars, next_charge )
                
                -- Update stack
                caster.cold_spot_charges = next_charge
            end
            
            -- Check if max is reached then check every 0.5 seconds if the charge is used
            if caster.cold_spot_charges ~= caster.cold_spot_maximum_charges then
                caster.start_charge = true
                -- On level up refresh the modifier
                caster:AddNewModifier(caster, transchars, modifierName, { Duration = charge_replenish_time } )
                return charge_replenish_time
            else
                return 0.5
            end
        end
    )
    print("End of "..ability:GetName().."'s cold_spot start charge.")
end




--[[
    Author: kritth
    Used by: Pizzalol
    Date: 6.1.2015.
    Helper: Create timer to track cooldown
]]
function cold_spot_start_cooldown( caster, charge_replenish_time )
    caster.cold_spot_cooldown = charge_replenish_time
    Timers:CreateTimer( function()
            local current_cooldown = caster.cold_spot_cooldown - 0.1
            if current_cooldown > 0.1 then
                caster.cold_spot_cooldown = current_cooldown
                return 0.1
            else
                print('No more cooldown')
                return nil
            end
        end
    )
end

--[[
    Author: kritth,Pizzalol
    Date: 18.01.2015.
    Main: Check/Reduce charge, spawn dummy and do cold_spot logic
]]
function spin_cold_spot( event )
    print('spin cold spot')
    local caster = event.caster
    local ability = event.ability
    local point = event.target_points[1]

    local transchars = caster:FindAbilityByName("horror_lastspell")

    local modifierName = "modifier_cold_spot_charges" --*

    -- Reduce stack if more than 0 else refund mana
    --if caster.cold_spot_charges > 0 then
        -- Variables
        --*local target = event.target_points[1]
        local player = caster:GetPlayerID()

        local dur = ability:GetLevelSpecialValueFor( "duration", ( ability:GetLevel() - 1 ) )
        caster.cold_spot_dummy = CreateUnitByName("cold_spot_dummy", point, false, caster, caster, caster:GetTeam())
        ability:ApplyDataDrivenModifier(caster, caster.cold_spot_dummy, "modifier_cold_spot_thinker", nil)
        caster.cold_spot_dummy:AddNewModifier(caster, nil, "modifier_kill", { duration = dur })


        -- AbilitySpecial variables
        local maximum_charges = ability:GetLevelSpecialValueFor( "max", ( ability:GetLevel() - 1 ) )

            local talent_name = "special_bonus_unique_horror2"
            if caster:HasAbility(talent_name) then
                local talent_level = caster:FindAbilityByName(talent_name):GetLevel()
                if talent_level > 0 then
                    maximum_charges = maximum_charges + 3
                end
            end

        local charge_replenish_time = ability:GetLevelSpecialValueFor( "chargerestoretime", ( ability:GetLevel() - 1 ) )
        if transchars then
            transchars:EndCooldown()
            transchars:UseResources(false,false,true)
            local cooltest = transchars:GetCooldownTime()
            	charge_replenish_time = charge_replenish_time*cooltest
            	print('rubick should not do this')
        end
        -- Deplete charge
        local next_charge = caster.cold_spot_charges - 1
        if caster.cold_spot_charges == maximum_charges then
            print('cold_spot charges are maxed. Charge replenish time of '..charge_replenish_time)
            caster:RemoveModifierByName( modifierName )
            caster:AddNewModifier(caster, transchars, modifierName, { Duration = charge_replenish_time } )
            cold_spot_start_cooldown( caster, charge_replenish_time )
        end
        if next_charge >= 0 then
            caster:SetModifierStackCount( modifierName, transchars, next_charge )
            caster.cold_spot_charges = next_charge 
        end
        print(ability:GetName()..' has spent a charge. Current charges: '..caster.cold_spot_charges)

        
        -- Check if stack is 0, display ability cooldown
        if caster.cold_spot_charges <= 0 then
            -- Start Cooldown from caster.cold_spot_cooldown
            ability:StartCooldown( caster.cold_spot_cooldown )
            print(ability:GetName()..' has been put on a cooldown of '..caster.cold_spot_cooldown)
        else
            ability:EndCooldown()
        end
    --[[else
        event.ability:RefundManaCost()
        print(ability:GetName()..' has refunded mana')
    end]]
end

function DmgCD(event)
    local attacker_name = event.attacker:GetName()

    if event.Damage > 0 and (attacker_name == "npc_dota_roshan" or event.attacker:IsControllableByAnyPlayer()) then  --If the damage was dealt by neutrals or lane creeps, essentially.
        if event.ability:GetCooldownTimeRemaining() < 3 then
            event.ability:StartCooldown(3)
        end
    end
end