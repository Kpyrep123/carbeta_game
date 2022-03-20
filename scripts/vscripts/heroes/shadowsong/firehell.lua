function DealDamage( keys )
    local caster        = keys.caster
    local target        = keys.target
    local damage_pct    = keys.DamagePct
    local damage        = keys.Damage 
    local ability       = keys.ability 
    local mana = caster:GetMana()
    local MaxMana = caster:GetMaxMana()
    local int_damage = ability:GetLevelSpecialValueFor("mana_damage_pct", (ability:GetLevel() -1)) + caster:GetTalentValue("special_bonus_arkosh_unquie")

    damage = damage
    damage_pct = damage_pct


    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = ((damage * damage_pct) + ((MaxMana - mana) * int_damage /100))/2

    ApplyDamage(damage_table)

end

function firehell_start( keys )
    local caster = keys.caster
    local ability = keys.ability
    local burn = ability:GetSpecialValueFor("mana_per_sec") / 250
    local mana_per_sec = caster:GetMaxMana() * burn
    local nova_tick = 0.5
    
    firehell_take_mana({caster=caster,
                        ability=ability,
                        mana_per_sec=mana_per_sec,
                        nova_tick=nova_tick})
end

function firehell_take_mana( params )
    if not params.ability then return end
    if params.ability:GetToggleState() == false then
        return
    end
    params.caster:ReduceMana(params.mana_per_sec)
    if params.caster:GetMana() < params.mana_per_sec then
        params.ability:ToggleAbility()
    end
    Timers:CreateTimer("firehell_".. params.caster:GetPlayerID(),{ --таймер следующей дуэльки
                endTime =params.nova_tick,
                callback = function()
                    firehell_take_mana({caster=params.caster,
                        ability=params.ability,
                        mana_per_sec=params.mana_per_sec,
                        nova_tick=params.nova_tick})
                    return nil
                end})
end

function firehell_stop( keys )
    local caster = keys.caster
    local sound = "Hero_DoomBringer.ScorchedEarthAura"
    StopSoundEvent(sound, caster)  
    Timers:RemoveTimer("firehell_".. caster:GetPlayerID())
end

function firehell_check_mana( keys )
    local mana_per_sec = keys.ability:GetLevelSpecialValueFor("mana_per_sec", keys.ability:GetLevel() - 1)
    print("trying check mana")

    if keys.caster:GetMana() < mana_per_sec then
        keys.ability:ToggleAbility()
        print("trying check mana off ability")
        keys.caster:RemoveModifierByName("modifier_firehell")
    end
end