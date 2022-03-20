
--[[Author: TheGreatGimmick
    Date: March 1, 2017
    Retreives the last spell/item cast from modifier_horror_lastspell,
    refreshes that ability's cooldown
    and transfers the cooldown to Deja vu]]

function Remember(event)
    --variables 
    local caster = event.caster
    local ability = event.ability
    local recall = caster:FindModifierByName("modifier_horror_lastspell"):RequestLastSpell()

    --calculate mana cost 
    local mana = caster:GetMana()
    local max_mana = caster:GetMaxMana()
    local mana_prct = ability:GetLevelSpecialValueFor("manacost", (ability:GetLevel() - 1))

    local mana_cost = (mana_prct/100)*max_mana

    if mana >= mana_cost then
        --if the caster has enough mana, determine cooldown left on the last ability used
        if recall and recall ~= nil then 
        	local CD = recall:GetCooldownTimeRemaining()
        	print("")
        	print('Deja vu Cast')
        	print("Last Spell: "..recall:GetName())
        	print('Cooldown transferred: '..CD)
        	if CD > 0 then
            	--if this cooldown is still going, transfer it to Deja vu and expend the mana cost. 
            	caster:SetMana(mana - mana_cost)
            	ability:StartCooldown(CD)
            	recall:EndCooldown()
            	caster:EmitSound("wisp_imort")
        	else
            	print('No cooldown to refresh')
            	--if the cooldown is not still going, do nothing. 
        	end
        end
    else
        print('Not enough mana.')
        caster:EmitSound("life_stealer_lifest_nomana_07")
    end
end

function LastSpellModifier(event)
    local caster = event.caster
    local ability = event.ability

    if not caster:HasModifier("modifier_horror_lastspell") then
        caster:AddNewModifier(caster,ability,"modifier_horror_lastspell",{})
    end
end