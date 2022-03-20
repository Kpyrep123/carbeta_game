
function ScepterCreated( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    if caster:HasScepter() then 
        caster:AddAbility("lanaya_ability_The_will_of_the_temple")
        ability:GetLevel( 0 )
    else
        caster:RemoveAbility("lanaya_ability_The_will_of_the_temple")
    end
end