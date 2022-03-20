function SpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

		ability:ApplyDataDrivenModifier(caster,target,"modifier_hylonome_eldritch_pull", {Duration = 0.1})
		if caster:HasTalent("special_bonus_unquie_capture_root") then 
			ability:ApplyDataDrivenModifier(caster, target, "modifier_capture_root", {duration = 2.0*(1 - target:GetStatusResistance())})
		end
end


function Interrupt( keys )
    local target = keys.target
    target:InterruptMotionControllers(false)
    keys.caster:SetAttacking(target)
end