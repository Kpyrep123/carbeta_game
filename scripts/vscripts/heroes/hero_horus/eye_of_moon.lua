--[[Author: TheGreatGimmick
    Date: Jan 3, 2017
    Creates the Eye of the Moon, 
    deals damage and gives healing while channelling,
    and stops the channelling when needed.]]
    
function MoonlightStart( event )
    -- Variables
    local caster = event.caster
    local point = event.target_points[1]
    local ability = event.ability
    caster.horus = caster

    caster.moonlight_dummy = CreateUnitByName("eye_of_the_moon_dummy", point, false, caster, caster, caster:GetTeam())

    --If daytime, do nothing and stun Horus extremely breifly to end the channelling, but refund mana and cooldown. 
    if GameRules:IsDaytime() then

    	ability:EndCooldown() --Cooldown refund so can cast again
        ability:RefundManaCost() --Manacost refund
        caster.horus:AddNewModifier(caster.horus, ability, 'modifier_stunned', {duration = 0.01}) --stop channelling. 

    else
        --if nighttime, give vision and start the dummy's thinker
		event.ability:ApplyDataDrivenModifier(caster, caster.moonlight_dummy, "modifier_moonlight_thinker", nil)
		AddFOWViewer(caster:GetTeamNumber(), point, 425, 6, false)

	end

end

--deal damage and give healing in pulses. Called once per interval. 
function MoonlightPulse(event)


	local ability = event.ability
	local caster = event.caster
	local adamage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() - 1))

            local talent_name = "special_bonus_unique_horus1"
            if caster:HasAbility(talent_name) then
                local talent_level = caster:FindAbilityByName(talent_name):GetLevel()
                if talent_level > 0 then
                    adamage = adamage + 120
                end
            end

	local acost = ability:GetLevelSpecialValueFor("costpsec", (ability:GetLevel() - 1))
	local manaleft = caster.horus:GetMana()

    --check if mana left is sufficient
	if manaleft < acost then
        --if not, stun extremely breifly to end channelling. 
		caster.horus:AddNewModifier(caster.horus, ability, 'modifier_stunned', {duration = 0.01})
	else
        --if so, find all valid targets... 
		local hero_enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                             caster.moonlight_dummy:GetAbsOrigin(),
                             nil,
                             425,
                             DOTA_UNIT_TARGET_TEAM_ENEMY,
                             DOTA_UNIT_TARGET_HERO,
                             DOTA_UNIT_TARGET_FLAG_NONE,
                             FIND_ANY_ORDER,
                             false)

		local creep_enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                             caster.moonlight_dummy:GetAbsOrigin(),
                             nil,
                             425,
                             DOTA_UNIT_TARGET_TEAM_ENEMY,
                             DOTA_UNIT_TARGET_BASIC,
                             DOTA_UNIT_TARGET_FLAG_NONE,
                             FIND_ANY_ORDER,
                             false)

		local hero_allies = FindUnitsInRadius(caster:GetTeamNumber(),
                             caster.moonlight_dummy:GetAbsOrigin(),
                             nil,
                             425,
                             DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                             DOTA_UNIT_TARGET_HERO,
                             DOTA_UNIT_TARGET_FLAG_NONE,
                             FIND_ANY_ORDER,
                             false)

		local creep_allies = FindUnitsInRadius(caster:GetTeamNumber(),
                             caster.moonlight_dummy:GetAbsOrigin(),
                             nil,
                             425,
                             DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                             DOTA_UNIT_TARGET_BASIC,
                             DOTA_UNIT_TARGET_FLAG_NONE,
                             FIND_ANY_ORDER,
                             false)		

        --and damage/heal them 
		for _,unit in pairs(hero_enemies) do
		
			local damageTable = {
				victim = unit,
				attacker = caster,
				damage = adamage / 1,
				damage_type = DAMAGE_TYPE_MAGICAL,
				}
            if not unit:IsMagicImmune() then
			     ApplyDamage(damageTable)
            end
 	   end

		for _,unit in pairs(creep_enemies) do
		
			local damageTable = {
				victim = unit,
				attacker = caster,
				damage = adamage / 1,
				damage_type = DAMAGE_TYPE_MAGICAL,
				}
            if not unit:IsMagicImmune() then
                ApplyDamage(damageTable)
            end
 	   end

 	   for _,unit in pairs(hero_allies) do
	    	unit:Heal(adamage / 1, caster)
	    end

 	   for _,unit in pairs(creep_allies) do
	    	unit:Heal(adamage / 1, caster)
	    end
	end
end

--check if mana left is sufficient, and if not end channelling via extremely breif stun.
function MoonlightCheck(event)

	local ability = event.ability
	local caster = event.caster
	local acost = ability:GetLevelSpecialValueFor("costpsec", (ability:GetLevel() - 1))
	local manaleft = caster.horus:GetMana()

	if manaleft < acost then
		caster.horus:AddNewModifier(caster.horus, ability, 'modifier_stunned', {duration = 0.01})
	end

end

--remove dummy once the spell is over. 
function MoonlightEnd( event )
    local caster = event.caster

    caster.moonlight_dummy:RemoveSelf()
end
