LinkLuaModifier("spike_conclusion_lua_cooldown_red", "heroes/spike/conclusion.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("spike_conclusion_lua_talent", "heroes/spike/conclusion.lua", LUA_MODIFIER_MOTION_NONE)

local forbidden_refresh = {
	["item_refresher"] 					= 1,
	["item_recovery_orb"]				= 1,	
	["spike_conclusion"]				= 1,	
	["spike_conclusion_lua"]			= 1,
}
function ForEveryAbility( caster, functor )
	for i = 0, caster:GetAbilityCount() - 1 do
		functor( caster:GetAbilityByIndex(i) )
	end

	for i = 0, 12 do
		functor( caster:GetItemInSlot(i) )
	end

	-- TP Slot
	functor( caster:GetItemInSlot(15) )

	-- neutral slot
	functor( caster:GetItemInSlot(16) )
end


spike_conclusion_lua = class({})

function spike_conclusion_lua:OnSpellStart()
	local caster = self:GetCaster()
	local selfAbility = self
	local duration = self:GetSpecialValueFor("duration")
	caster:AddNewModifier(caster, self, "spike_conclusion_lua_cooldown_red", {duration = duration})

	caster:Purge( false, true, false, true, false )

	while(caster:HasModifier("modifier_huskar_burning_spear_counter")) do
		caster:RemoveModifierByName("modifier_huskar_burning_spear_counter")
	end

	caster:RemoveModifierByName("modifier_huskar_burning_spear_debuff")
	caster:RemoveModifierByName("modifier_dazzle_weave_armor")
	caster:RemoveModifierByName("modifier_dazzle_weave_armor_debuff")

	selfAbility.list = {}
	selfAbility.startTime = GameRules:GetGameTime()


	local subrefresh = function(ability)
		if not ability then return end

		local name = ability:GetName()

		if forbidden_refresh[ name ] then return end

		local cd = ability:GetCooldownTimeRemaining()

		if cd > 0 then
			selfAbility.list[name] = cd
		end

		ability:RefreshCharges()
		ability:EndCooldown()	
	end

	ForEveryAbility( caster, subrefresh )
end

function spike_conclusion_lua:GetIntrinsicModifierName(  )
	return "spike_conclusion_lua_talent"
end

spike_conclusion_lua_cooldown_red = class({})

spike_conclusion_lua_cooldown_red = class({})
function spike_conclusion_lua_cooldown_red:IsHidden() return false end
function spike_conclusion_lua_cooldown_red:IsPurgable() return true end
function spike_conclusion_lua_cooldown_red:GetTexture() return end
function spike_conclusion_lua_cooldown_red:GetEffectName() return end

function spike_conclusion_lua_cooldown_red:OnCreated()
if not IsServer() then return end
	local caster = self:GetCaster()
	self.reduct = self:GetAbility():GetSpecialValueFor("total_cooldown")
end

function spike_conclusion_lua_cooldown_red:OnRefresh()
if not IsServer() then return end
self.reduct = self:GetAbility():GetSpecialValueFor("total_cooldown")
end

function spike_conclusion_lua_cooldown_red:DeclareFunctions()
return
	{
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
	}
end

function spike_conclusion_lua_cooldown_red:GetModifierPercentageCooldown()
	if self:GetCaster():HasAbility("special_bonus_unquie_coold_red") and self:GetCaster():FindAbilityByName("special_bonus_unquie_coold_red"):GetLevel() > 0 then 
		tal_red = 15 
	else
		tal_red = 0
	end
	return -self.reduct + tal_red
end

spike_conclusion_lua_talent = class({})

spike_conclusion_lua_talent = class({})
function spike_conclusion_lua_talent:IsHidden() return self:GetStackCount()==0 end
function spike_conclusion_lua_talent:IsPurgable() return false end
function spike_conclusion_lua_talent:GetTexture() return end
function spike_conclusion_lua_talent:GetEffectName() return end

function spike_conclusion_lua_talent:OnCreated()
if not IsServer() then return end
self.str = 10
end

function spike_conclusion_lua_talent:OnRefresh()
if not IsServer() then return end
self.str = 10
end

function spike_conclusion_lua_talent:DeclareFunctions()
return
	{
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
end

function spike_conclusion_lua_talent:OnDeath( params )
	if self:GetCaster() ~= params.attacker then return end
	if not params.unit:IsRealHero() then return end
	if not self:GetCaster():HasTalent("spike_special_bonus_attack") then return end
	self:SetStackCount(self:GetStackCount() + 1)
end

function spike_conclusion_lua_talent:GetModifierBonusStats_Strength(  )
	return self.str * self:GetStackCount()
end
