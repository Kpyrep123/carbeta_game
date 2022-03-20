LinkLuaModifier("modifier_special_bonus_unique_zip", "heroes/hero_zip/modifiers/modifier_special_bonus_unique_zip.lua", LUA_MODIFIER_MOTION_NONE)

--[[Author: TheGreatGimmick
    Date: May 24, 2017
    Zip's Q, Acceleration]]

-- Allow Zip to exceed movement the speed cap. 
-- Applies attack speed if Zip has the relevant Talent.
function ApplyThirst( event )
    print("")
    local caster = event.caster
    local ability = event.ability

    local dur = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))

    caster:AddNewModifier(caster, ability, "modifier_bloodseeker_thirst", { duration = dur })
    print("Thirst applied for "..dur.." seconds.")

            local talent_name = "special_bonus_unique_zip"
            if caster:HasAbility(talent_name) then
                local talent_level = caster:FindAbilityByName(talent_name):GetLevel()
                if talent_level > 0 then
                    caster:AddNewModifier(caster, ability, "modifier_special_bonus_unique_zip", { duration = dur })
                end
            end
end

--Stop the ability sound from playing when it is over or Zip dies.
function StopSound(event)
	local caster = event.caster
	caster:StopSound("Hero_Wisp.Relocate.Arc")
end

--Cause Zip's cooldowns to tick down at a higher rate.
function ReduceCooldowns(event)
    local caster = event.caster
    local a = event.ability

    -- how fast should the cooldowns decrement?
    local reduction = 0.00 + a:GetLevelSpecialValueFor("cdfastreal", (a:GetLevel() - 1))

    --apply to all of Zip's abilities
    for c = 0, 15, 1 do
        local ability = caster:GetAbilityByIndex(c)
        if ability and ability ~= nil then
            local current_cd = ability:GetCooldownTimeRemaining()
            if current_cd > 0 then
                local new_cd = current_cd - reduction
                if new_cd > 0 then
                    ability:EndCooldown()
                    ability:StartCooldown(new_cd)
                    --print("Cooldown reduced from "..current_cd.." to "..new_cd..".")
                else
                    ability:EndCooldown()
                end
            end
        end
    end
    --apply to all of Zip's items
    for i = 0, 14, 1 do
        local ability = caster:GetItemInSlot(i)
        if ability and ability ~= nil then
            local current_cd = ability:GetCooldownTimeRemaining()
            if current_cd > 0 then
                local new_cd = current_cd - reduction
                if i > 5 and i < 9 then
                    new_cd = current_cd - reduction/2
                end
                if new_cd > 0 then
                    ability:EndCooldown()
                    ability:StartCooldown(new_cd)
                else
                    ability:EndCooldown()
                end
            end
        end
    end

end