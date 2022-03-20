LinkLuaModifier("modifier_transfigure_charges", "heroes/hero_hazel/modifiers/modifier_transfigure_charges.lua", LUA_MODIFIER_MOTION_NONE)

--[[Author: TheGreatGimmick
    Date: Feb 21, 2017
    ]]

--Initialize Stacks, upgrade abilities
function TransUpgrade( event )
	local caster = event.caster 
	local ability = event.ability
    local transchars = caster:FindAbilityByName("hazel_transfigure_charges")
	local max_stacks = 3 --ability:GetLevelSpecialValueFor("max", (ability:GetLevel() - 1))

    transchars:SetLevel(1)

    if not caster.transfigure_levelflag then
        caster.transfigure_levelflag = 1
    end
--[[
	if not caster.hazel_transfigure_stacks then
		caster.hazel_transfigure_stacks = max_stacks
		print('Transfigure stacks initialized at '..caster.hazel_transfigure_stacks)
	end]]

    if caster.transfigure_levelflag == 1 then
        caster.transfigure_levelflag = 0
        local bat = caster:FindAbilityByName("hazel_transfigure_bat")
        local rat = caster:FindAbilityByName("hazel_transfigure_rat")
        local slug = caster:FindAbilityByName("hazel_transfigure_slug")
        local leveled = ability

        if leveled ~= bat then
            print('Bat upgraded')
            --caster:UpgradeAbility(bat)
            bat:SetLevel((bat:GetLevel())+1)
        end
        if leveled ~= rat then
            print('Rat upgraded')
            --caster:UpgradeAbility(rat)
            rat:SetLevel((rat:GetLevel())+1)
        end
        if leveled ~= slug then
            print('Slug upgraded')
            --caster:UpgradeAbility(slug)
            slug:SetLevel((slug:GetLevel())+1)
        end
        caster.transfigure_levelflag = 1
    end

end	

--[[Manage stacks 
function TransCharges( event )
	local caster = event.caster 
    local ability = event.ability

    local max_stacks = 3 --ability:GetLevelSpecialValueFor("max", (ability:GetLevel() - 1))
    --[[if not caster.hazel_transfigure_stacks then
    	caster.hazel_transfigure_stacks = max_stacks
		print('Transfigure stacks initialized at '..caster.hazel_transfigure_stacks)
	end]

    local stacks = caster.hazel_transfigure_stacks
    local CD = ability:GetCooldown(ability:GetLevel()-1)
    print('Cooldown: '..CD)

    stacks = stacks - 1
    caster.hazel_transfigure_stacks = stacks 
    print('Transfigure stacks: '..stacks)
    if stacks > 0 then
    	ability:EndCooldown()
    	print('Transfigure cooldown reset due to stacks remaining')
    else
        local bat = caster:FindAbilityByName("hazel_transfigure_bat")
        local rat = caster:FindAbilityByName("hazel_transfigure_rat")
        local slug = caster:FindAbilityByName("hazel_transfigure_slug")
        bat:StartCooldown(CD)
        rat:StartCooldown(CD)
        slug:StartCooldown(CD)
    end
    Timers:CreateTimer(CD, function ()
            print('Stack Restoration function is checking...')
            if ability and caster and caster.hazel_transfigure_stacks and max_stacks then
                if caster.hazel_transfigure_stacks < max_stacks then
                    caster.hazel_transfigure_stacks = caster.hazel_transfigure_stacks + 1
                    ability:EndCooldown()
                    print('Stack Restored')
                    print('Transfigure stacks: '..caster.hazel_transfigure_stacks)
                end
            end
        end)

end
]]

--[[Author: kritth,Pizzalol
    Date: 18.01.2015.
    Keeps track of the current charges and replenishes them accordingly]]
function transfigure_start_charge( keys )
    -- Initial variables to keep track of different max charge requirements
    local caster = keys.caster
    local ability = keys.ability
    local transchars = caster:FindAbilityByName("hazel_transfigure_charges")

    caster.transfigure_maximum_charges = 3 --*ability:GetLevelSpecialValueFor( "max_charges", ( ability:GetLevel() - 1 ) )
    --*caster.transfigure_maximum_transfigures = ability:GetLevelSpecialValueFor("count", (ability:GetLevel() - 1))

    --[[* Initialize the current transfigure count and the transfigure table
    if caster.transfigure_current_transfigures == nil then caster.transfigure_current_transfigures = 0 end
    if caster.transfigure_table == nil then caster.transfigure_table = {} end
    ]]

    -- Only start charging at level 1
    if keys.ability:GetLevel() ~= 1 then return end

    -- Variables    
    local modifierName = "modifier_transfigure_charges" --"modifier_transfigure_stack_counter_datadriven"
    
    -- Initialize stack
    caster:SetModifierStackCount( modifierName, transchars, 0 )
    caster.transfigure_charges = caster.transfigure_maximum_charges
    caster.start_charge = false
    caster.transfigure_cooldown = 0.0
    
    caster:AddNewModifier(caster, transchars, modifierName, {})

    caster:SetModifierStackCount( modifierName, transchars, caster.transfigure_maximum_charges )

    print(ability:GetName()..' has started the Transfigure charges.')

    -- create timer to restore stack
    Timers:CreateTimer( function()
            -- Restore charge
            local charge_replenish_time = ability:GetLevelSpecialValueFor( "chargerestoretime", ( ability:GetLevel() - 1 ) )

            transchars:EndCooldown()
            transchars:UseResources(false,false,true)
            local cooltest = transchars:GetCooldownTime()

            charge_replenish_time = charge_replenish_time*cooltest

            if caster.start_charge and caster.transfigure_charges < caster.transfigure_maximum_charges then
                print('A Transfigure charge is restored.')
                -- Calculate stacks
                local next_charge = caster.transfigure_charges + 1
                caster:RemoveModifierByName( modifierName )
                if next_charge ~= caster.transfigure_maximum_charges then
                    caster:AddNewModifier(caster, transchars, modifierName, { Duration = charge_replenish_time } )
                    transfigure_start_cooldown( caster, charge_replenish_time )
                else
                    caster:AddNewModifier(caster, transchars, modifierName, {} )
                    caster.start_charge = false
                end
                caster:SetModifierStackCount( modifierName, transchars, next_charge )
                
                -- Update stack
                caster.transfigure_charges = next_charge
            end
            
            -- Check if max is reached then check every 0.5 seconds if the charge is used
            if caster.transfigure_charges ~= caster.transfigure_maximum_charges then
                caster.start_charge = true
                -- On level up refresh the modifier
                caster:AddNewModifier(caster, transchars, modifierName, { Duration = charge_replenish_time } )
                return charge_replenish_time
            else
                return 0.5
            end
        end
    )
    print("End of "..ability:GetName().."'s Transfigure start charge.")
end




--[[
    Author: kritth
    Used by: Pizzalol
    Date: 6.1.2015.
    Helper: Create timer to track cooldown
]]
function transfigure_start_cooldown( caster, charge_replenish_time )
    caster.transfigure_cooldown = charge_replenish_time
    Timers:CreateTimer( function()
            local current_cooldown = caster.transfigure_cooldown - 0.1
            if current_cooldown > 0.1 then
                caster.transfigure_cooldown = current_cooldown
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
    Main: Check/Reduce charge, spawn dummy and do transfigure logic
]]
function spin_transfigure( keys )
    local caster = keys.caster
    local ability = keys.ability
    local modifierName = "modifier_transfigure_charges" --*

        local bat = caster:FindAbilityByName("hazel_transfigure_bat")
        local rat = caster:FindAbilityByName("hazel_transfigure_rat")
        local slug = caster:FindAbilityByName("hazel_transfigure_slug")
        local transchars = caster:FindAbilityByName("hazel_transfigure_charges")

    -- Reduce stack if more than 0 else refund mana
    --if caster.transfigure_charges > 0 then
        -- Variables
        --*local target = keys.target_points[1]
        local ability = keys.ability
        local player = caster:GetPlayerID()

        --[[* Modifiers and dummy abilities/modifiers
        local stack_modifier = keys.stack_modifier
        local dummy_modifier = keys.dummy_modifier
        local dummy_ability = keys.dummy_ability
        ]]

        -- AbilitySpecial variables
        local maximum_charges = 3 --*ability:GetLevelSpecialValueFor( "max_charges", ( ability:GetLevel() - 1 ) )
        local charge_replenish_time = ability:GetLevelSpecialValueFor( "chargerestoretime", ( ability:GetLevel() - 1 ) )
            transchars:EndCooldown()
            transchars:UseResources(false,false,true)
            local cooltest = transchars:GetCooldownTime()

            charge_replenish_time = charge_replenish_time*cooltest
        -- Deplete charge
        local next_charge = caster.transfigure_charges - 1
        if caster.transfigure_charges == maximum_charges then
            print('Transfigure charges are maxed. Charge replenish time of '..charge_replenish_time)
            caster:RemoveModifierByName( modifierName )
            caster:AddNewModifier(caster, transchars, modifierName, { Duration = charge_replenish_time } )
            transfigure_start_cooldown( caster, charge_replenish_time )
        end
        if next_charge >= 0 then
            caster:SetModifierStackCount( modifierName, transchars, next_charge )
            caster.transfigure_charges = next_charge 
        end
        print(ability:GetName()..' has spent a charge. Current charges: '..caster.transfigure_charges)

        
        -- Check if stack is 0, display ability cooldown
        if caster.transfigure_charges <= 0 then
            -- Start Cooldown from caster.transfigure_cooldown
            bat:StartCooldown( caster.transfigure_cooldown )
            print(bat:GetName()..' has been put on a cooldown of '..caster.transfigure_cooldown)
            rat:StartCooldown( caster.transfigure_cooldown )
            print(rat:GetName()..' has been put on a cooldown of '..caster.transfigure_cooldown)
            slug:StartCooldown( caster.transfigure_cooldown )
            print(slug:GetName()..' has been put on a cooldown of '..caster.transfigure_cooldown)
        else
            bat:EndCooldown()
            print(bat:GetName().."'s cooldown has been ended.")
            rat:EndCooldown()
            print(rat:GetName().."'s cooldown has been ended.")
            slug:EndCooldown()
            print(slug:GetName().."'s cooldown has been ended.")
        end
    --[[else
        keys.ability:RefundManaCost()
        print(ability:GetName()..' has refunded mana')
    end]]
end