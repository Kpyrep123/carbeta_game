--[[Author: TheGreatGimmick
    Date: Mar 17, 2017
    Collector's Q, Bitter Spirits]]

--Heal the target, or begins the damage if they reach full health
function HealorTurn( keys )
 
    local caster = keys.caster
    local ability = keys.ability
    local unit = keys.target

    local max_health = unit:GetMaxHealth()
    local current_health = unit:GetHealth()
    print("")
    print("Current health is "..current_health..", max health is "..max_health..".")

    if max_health == current_health then
    	--end healing, start damage
    	print("Turned")
		--unit:EmitSound("Hero_DeathProphet.Exorcism.Damage")
    	unit:RemoveModifierByName("modifier_bitter_spirits_heal")
    	ability:ApplyDataDrivenModifier(caster, unit, keys.modifier, { duration = 10 })
    else
    	--heal
    	print("Healed")
    	local healing = ability:GetLevelSpecialValueFor("health", (ability:GetLevel() - 1))
        local percent = ability:GetLevelSpecialValueFor("healthprcnt", (ability:GetLevel() - 1))
    	unit:Heal((healing+max_health*(percent/100))/10, caster)

    end
end

--deal damage
function Turned( keys )
    local caster = keys.caster
    local ability = keys.ability
    local unit = keys.target

    local percent = ability:GetLevelSpecialValueFor("healthprcnt", (ability:GetLevel() - 1))
    local max_health = unit:GetMaxHealth()

    unit:EmitSound("Hero_DeathProphet.Exorcism.Damage")

    --deal damage
    local damage = ability:GetLevelSpecialValueFor("health", (ability:GetLevel() - 1))

    		local damageTable = {
				victim = unit,
				attacker = caster,
				damage = (damage+max_health*(percent/100))/10,
				damage_type = DAMAGE_TYPE_PURE,
				}
 
	ApplyDamage(damageTable)

end