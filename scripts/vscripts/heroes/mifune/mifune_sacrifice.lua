mifune_sacrifice = class({})

LinkLuaModifier("modifier_sacrifice_scepter_checker", "heroes/mifune/mifune_sacrifice",LUA_MODIFIER_MOTION_NONE)

function mifune_sacrifice:IsStealable() return false end
function mifune_sacrifice:IsInnateAbility() return true end

function mifune_sacrifice:GetIntrinsicModifierName()
	return "modifier_sacrifice_scepter_checker"
end

function mifune_sacrifice:CastFilterResultTarget(target)
	if target:HasModifier("modifier_genso_chest") then
		return UF_SUCCESS
	else
		return UF_FAIL_CUSTOM
	end
end

function mifune_sacrifice:GetCustomCastErrorTarget(target)
	if target:HasModifier("modifier_genso_chest") then
		return UF_SUCCESS
	else
		return "#mifune_sacrifice_target_error"
	end
end

function mifune_sacrifice:OnSpellStart()
	if IsServer() then

		-- Parameters
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local bonus_health = self:GetSpecialValueFor("bonus_health")
		local sword_count = 0

		if (not target.other_chests) then return nil end

		for _, sword in pairs(target.other_chests) do
			if (not sword:IsNull()) and sword:IsAlive() then
				sword_count = sword_count + 1
			end
		end

		if sword_count < 1 then return nil end

		bonus_health = math.floor(3 * bonus_health / sword_count)

		for _, sword in pairs(target.other_chests) do
			if (not sword:IsNull()) and sword:IsAlive() then
				local health = sword:GetHealth()
				local max_health = sword:GetMaxHealth()
				sword:SetBaseMaxHealth(max_health + bonus_health)
				sword:SetMaxHealth(max_health + bonus_health)
				sword:SetHealth(health + bonus_health)
			end
		end
		target:EmitSound("Hero_Mifune.Sacrifice")
		target:ForceKill(false)
	end
end



modifier_sacrifice_scepter_checker = class({})

function modifier_sacrifice_scepter_checker:IsDebuff() return false end
function modifier_sacrifice_scepter_checker:IsHidden() return true end
function modifier_sacrifice_scepter_checker:IsPurgable() return false end

function modifier_sacrifice_scepter_checker:OnCreated(keys)
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_sacrifice_scepter_checker:OnIntervalThink()
	if IsServer() then
		self:GetAbility():SetHidden(not self:GetCaster():HasScepter())
	end
end