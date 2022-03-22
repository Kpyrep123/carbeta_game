achlys_nights_embrace_lua = class({})

function achlys_nights_embrace_lua:OnSpellStart(  )
	local caster = self:GetCaster()
	local ability = self
	local ability_level = ability:GetLevel() - 1
	local duration = self:GetSpecialValueFor("duration")
	
	ParticleManager:CreateParticle("particles/achlys_nights_embrace.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	EmitSoundOn("Hero_Bane.Enfeeble", self:GetCaster())
	Timers:CreateTimer(0.2, function()
		caster:AddNewModifier(caster, ability, "modifier_achlys_nights_embrace_lua", {duration = duration})
	end)
end

modifier_achlys_nights_embrace_lua = class({})
LinkLuaModifier("modifier_achlys_nights_embrace_lua", "heroes/hero_riki/achlys_nights_embrace_lua.lua", LUA_MODIFIER_MOTION_NONE)
modifier_achlys_nights_embrace_lua = class({})
function modifier_achlys_nights_embrace_lua:IsHidden() return false end
function modifier_achlys_nights_embrace_lua:IsPurgable() return false end
function modifier_achlys_nights_embrace_lua:GetTexture() return end
function modifier_achlys_nights_embrace_lua:GetEffectName() return end

function modifier_achlys_nights_embrace_lua:OnCreated()
if not IsServer() then return end
	self.dmg_sec = self:GetAbility():GetSpecialValueFor("damage_per_sec") / 10
	self.mana_per_sec = (((self:GetAbility():GetSpecialValueFor("mana_cost_pct")) + self:GetCaster():GetTalentValue("special_bonus_unquie_manacost_veerah")) * self:GetCaster():GetMaxMana()) / 1000
self:StartIntervalThink(0.1)
self:OnIntervalThink()
end

function modifier_achlys_nights_embrace_lua:OnRefresh()
if not IsServer() then return end
	self.dmg_sec = self:GetAbility():GetSpecialValueFor("damage_per_sec") / 10
	self.mana_per_sec = (((self:GetAbility():GetSpecialValueFor("mana_cost_pct")) + self:GetCaster():GetTalentValue("special_bonus_unquie_manacost_veerah")) * self:GetCaster():GetMaxMana()) / 1000
end

function modifier_achlys_nights_embrace_lua:OnIntervalThink()
	local heroes = HeroList:GetAllHeroes()
	local isHidden = true

	for k,v in pairs(heroes) do 
		if v:GetTeam() ~= self:GetCaster():GetTeam() then
			if v:CanEntityBeSeenByMyTeam(self:GetCaster()) then
				isHidden = false
			end
		end
	end
	if isHidden then
	self:SetStackCount(self:GetStackCount() + self.dmg_sec + self:GetCaster():GetTalentValue("special_bonus_unquie_veerah_bonus_dmg"))
	end
	self:GetCaster():SpendMana(self.mana_per_sec, self:GetAbility())
	if self:GetCaster():GetMana() < self.mana_per_sec then 
		self:Destroy()
	end
end
function modifier_achlys_nights_embrace_lua:CheckState()
	return {[MODIFIER_STATE_INVISIBLE] = true}
end

function modifier_achlys_nights_embrace_lua:DeclareFunctions()
	return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_EVENT_ON_ATTACK,
			MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end

function modifier_achlys_nights_embrace_lua:GetModifierInvisibilityLevel()
	return 1
end

function modifier_achlys_nights_embrace_lua:OnAttack( params )
	if params.attacker ~= self:GetParent() then return end
	if self:GetCaster():HasScepter() then 
		self:SetStackCount(0)
	else
		self:Destroy()
	end
end

function modifier_achlys_nights_embrace_lua:OnAbilityExecuted( params )
	if IsServer() then
		if params.unit~=self:GetParent() then return end
		if self:GetCaster():HasScepter() then return end
		self:Destroy()
	end
end

function modifier_achlys_nights_embrace_lua:GetEffectName(  )
	return "particles/achlys_nights_embrace_invis.vpcf"
end

function modifier_achlys_nights_embrace_lua:GetEffectAttachType(  )
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_achlys_nights_embrace_lua:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end