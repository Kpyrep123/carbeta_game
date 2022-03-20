--function Call( keys )
--	local caster = keys.caster
--	local target = keys.target
--	local ability = keys.ability
--	local ability_level = ability:GetLevel() - 1
--	local lvl = caster:FindAbilityByName("Call_of_cthulhu"):GetLevel()
--	local target_point = ability:GetCursorPosition()
--	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
--
--
--	YogSothoth = CreateUnitByName("Azathoth", target_point, true, caster, caster, caster:GetTeamNumber())
--
--	local modifier = ability:ApplyDataDrivenModifier(caster, YogSothoth, "modifier_azathoth", {duration = duration})
--

--end


function CreateSprout(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local point = ability:GetCursorPosition()
	local polypMax = 100000
	local duration = ability:GetLevelSpecialValueFor("killing", ability_level)
	local dur = ability:GetSpecialValueFor("killing") + caster:GetTalentValue("special_bonus_unquie_chtonic_structure_dur")
	local lvl = caster:FindAbilityByName("Call_of_cthulhu"):GetLevel()
	-- Creates 8 temporary trees at each 45 degree interval around the clicked point
	Timers:CreateTimer(0.5, function()
		YogSothoth = CreateUnitByName("Azathoth", point, true, caster, caster, caster:GetTeamNumber())
			 YogSothoth:SetMaxHealth(polypMax)
				YogSothoth:SetBaseMaxHealth(polypMax)
				YogSothoth:SetHealth(polypMax)
		ult = YogSothoth:AddAbility("nerub_curse")
		ult:SetLevel(lvl)
		local fk = ability:ApplyDataDrivenModifier(caster, YogSothoth, "modifier_azathoth", {duration = dur})
		if caster:HasScepter() then
			ability:ApplyDataDrivenModifier(caster, YogSothoth, "modifier_scepter", {duration = dur})
		end
	end)
end