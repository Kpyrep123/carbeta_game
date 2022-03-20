LinkLuaModifier("modifier_whipped", "scripts/vscripts/heroes/sobek/koh_whiplash.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_sobek_voracious_appetite', 'scripts/vscripts/heroes/sobek/modifier_sobek_voracious_appetite.lua', LUA_MODIFIER_MOTION_NONE)

koh_whiplash = class({})

function koh_whiplash:OnSpellStart()

	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()
	local target_loc = caster:GetCursorPosition()
	local end_loc = caster_loc + (target_loc - caster_loc):Normalized() * (self:GetSpecialValueFor("whip_length") + caster:GetTalentValue("special_bonus_unique_sobek_3"))
	local whip_radius = self:GetSpecialValueFor("whip_radius") + caster:GetTalentValue("special_bonus_unique_sobek_3")
	local base_damage = self:GetSpecialValueFor("base_damage")
	local str_damage = caster:GetStrength() * self:GetSpecialValueFor("str_damage") * 0.01
	local root_duration = self:GetSpecialValueFor("root_duration")

	caster:EmitSound("Hero_Koh.Whiplash")

	local whip_particle = ParticleManager:CreateParticle("particles/hero/koh/whiplash.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(whip_particle, 0, caster_loc)
	ParticleManager:SetParticleControl(whip_particle, 1, end_loc)
	ParticleManager:ReleaseParticleIndex(whip_particle)

	local end_particle = ParticleManager:CreateParticle("particles/econ/items/tiny/tiny_prestige/tiny_prestige_avalanche_projectile_flash.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(end_particle, 0, end_loc)
	ParticleManager:SetParticleControl(end_particle, 1, end_loc)
	ParticleManager:ReleaseParticleIndex(end_particle)

	local line_enemies = FindUnitsInLine(caster:GetTeamNumber(), caster_loc, end_loc, nil, whip_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE)
	for _, enemy in pairs(line_enemies) do
		ApplyDamage({victim = enemy, attacker = caster, damage = base_damage, damage_type = DAMAGE_TYPE_MAGICAL})
		enemy:EmitSound("Hero_Koh.Whiplash.Path")
	end

	local end_enemies = FindUnitsInRadius(caster:GetTeamNumber(), end_loc, nil, whip_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(end_enemies) do
		local talent = caster:FindAbilityByName("special_bonus_unique_sobek_2")
		if talent and talent:GetLevel() > 0 then
			enemy:AddNewModifier(caster, self, "modifier_stunned", {duration = root_duration})
		else
			enemy:AddNewModifier(caster, self, "modifier_whipped", {duration = root_duration})
		end
			if caster:HasModifier("modifier_item_aghanims_shard") and enemy:IsRealHero() then
					local subability = caster:FindAbilityByName("sobek_voracious_appetite")
					local str_stacks = subability:GetSpecialValueFor("bonus_str")
					local str_modifier = caster:AddNewModifier(caster, self, 'modifier_sobek_voracious_appetite', {})
				
					str_modifier:SetStackCount(str_modifier:GetStackCount() + str_stacks)
					caster:CalculateStatBonus(true)
			end
		ApplyDamage({victim = enemy, attacker = caster, damage = str_damage, damage_type = DAMAGE_TYPE_MAGICAL})
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE , enemy, base_damage + str_damage, nil)
		enemy:EmitSound("Hero_Koh.Whiplash.End")
	end
end


modifier_whipped = class({})

function modifier_whipped:IsDebuff() return true end
function modifier_whipped:IsPurgable() return true end
function modifier_whipped:IsPurgeException() return false end
function modifier_whipped:IsHidden() return false end

function modifier_whipped:CheckState()
	local states = {
		[MODIFIER_STATE_ROOTED] = true,
	}
	return states
end