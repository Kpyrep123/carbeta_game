
LinkLuaModifier("modifier_troy_ill_be_back", "heroes/troy/troy_ill_be_back.lua", LUA_MODIFIER_MOTION_NONE)

troy_ill_be_back = class({})

function troy_ill_be_back:GetIntrinsicModifierName()
	return "modifier_troy_ill_be_back"
end

function troy_ill_be_back:IsInnateAbility() return true end

function troy_ill_be_back:OnInventoryContentsChanged()
	if IsServer() then
		if self:GetCaster():HasScepter() then
			self:SetHidden(false)
			self:SetLevel(1)
		else
			self:SetHidden(true)
		end
	end
end

-------------------------------

modifier_troy_ill_be_back = class({})

function modifier_troy_ill_be_back:IsHidden() return true end
function modifier_troy_ill_be_back:IsDebuff() return false end
function modifier_troy_ill_be_back:IsPurgable() return false end

function modifier_troy_ill_be_back:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_REINCARNATION,
	}
end

function modifier_troy_ill_be_back:ReincarnateTime()
	if not IsServer() then return end
	local ability = self:GetAbility()
	if not ability:IsHidden() and ability:IsCooldownReady() then
		-- reincarnate here
		local delay = ability:GetSpecialValueFor("delay")

		ability:StartCooldown(ability:GetCooldown(1))


		Timers:CreateTimer(delay + 0.1, function()
			-- cast the current level of fury for free
			local parent = self:GetParent()
			local furyAbility = parent:FindAbilityByName("troy_fury")

			local furyCost = parent:GetMaxHealth() * furyAbility:GetSpecialValueFor("health_cost") * 0.01
			local respawnHealth = (parent:GetMaxHealth() / 2) + furyCost

			parent:SetHealth(respawnHealth)

			parent:CastAbilityNoTarget(furyAbility, parent:GetPlayerOwnerID())

			furyAbility:EndCooldown()
		end)

		return delay
	else
		return 0
	end
end