LinkLuaModifier("modifier_consume_item_strength","heroes/viscous_ooze/viscous_ooze_consume_items.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_consume_item_treasure_dummy","heroes/viscous_ooze/viscous_ooze_consume_items.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_consumed_item","heroes/viscous_ooze/viscous_ooze_consume_items.lua",LUA_MODIFIER_MOTION_NONE)


viscous_ooze_consume_items = class({})

function viscous_ooze_consume_items:IsStealable()
    return false
end

function viscous_ooze_consume_items:CastFilterResult()
	if not IsServer() then return end

	local modifiers = self:GetCaster():FindAllModifiersByName("modifier_consumed_item")
	if #modifiers >= self:GetSpecialValueFor("max_items") then return UF_FAIL_CUSTOM end

	return UF_SUCCESS
end


function viscous_ooze_consume_items:GetCustomCastError()
	return "Consuming Too Many Items"
end

function viscous_ooze_consume_items:OnUpgrade()
	if IsServer() then 
		local modifier = self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_consume_item_strength",{})
		if not modifier.consumedGold then
			modifier.consumedGold = 0
		end

		if not modifier.treasureTracker then
			local caster = self:GetCaster()
			local dummy = CreateUnitByName("npc_dota_hero_viscous_ooze", caster:GetAbsOrigin() + Vector(100,0,0), true, caster:GetPlayerOwner(), caster, caster:GetTeam())
			dummy:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
			dummy:SetOwner(caster)
			-- dummy:AddItem(CreateItem("item_bloodthorn", dummy, dummy))
			-- dummy:SetOwner(nil)
			dummy:AddNewModifier(caster, self, "modifier_consume_item_treasure_dummy", {})
			dummy:SetAbsOrigin(Vector(-30000,0,0))
			dummy:AddNoDraw()
			dummy:MakeIllusion()
			-- local item = dummy:AddItem(CreateItem("item_gold_counter", caster, caster))
			modifier.treasureTracker = dummy
			-- item:SetCurrentCharges(1000)
			-- modifier.goldItem = item
		end
		local subability = self:GetCaster():FindAbilityByName("viscous_ooze_treasure_magic")
		if subability then
			subability:UpgradeAbility(false)
			if subability:GetLevel() == 1 then
				subability:SetActivated(false)
			end
		end
	end
end

function viscous_ooze_consume_items:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local modifier = caster:FindModifierByName("modifier_consume_item_strength")

		local baseCooldown = self:GetSpecialValueFor("base_cooldown")
		local strengthPerGold = self:GetSpecialValueFor("strength_per_gold")
		local cooldownPerGold = self:GetSpecialValueFor("cooldown_per_gold")

		--Consume items in backpack, add total networth
		local cooldown = 0
		for i = 6, 8 do
			local item = caster:GetItemInSlot(i)
			if item and self:CanConsumeItem(item) then
				local networth = item:GetCost()
				local itemName = item:GetName()
				local duration = baseCooldown + (networth * cooldownPerGold / 100)
				-- modifier.consumedGold = modifier.consumedGold + networth
				local itemModifier = caster:AddNewModifier(caster, item, "modifier_consumed_item", {duration = duration, interval = cooldownPerGold, itemName = itemName, networth = networth})
				caster:DropItemAtPositionImmediate(item, Vector(-50000, 0, 0))
				itemModifier.item = item
				item:SetOwner(nil)
				item:SetPurchaser(nil)
				
				-- cooldown = cooldown + (networth * cooldownPerGold / 100)
				caster:EmitSound("Hero_Viscous_Ooze.Consume_items")
			end
		end

		-- local dummy = CreateUnitByName("npc_dota_hero_viscous_ooze", caster:GetAbsOrigin() + Vector(100,0,0), true, caster:GetPlayerOwner(), caster, caster:GetTeam())
		-- 	dummy:SetControllableByPlayer(caster:GetPlayerOwnerID(), false)
		-- 	dummy:SetOwner(caster)
		-- 	dummy:AddItem(CreateItem("item_bloodthorn", dummy, dummy))
		-- modifier:ModifyStacks()
		-- caster:CalculateStatBonus( true )

		-- caster:SetGold(caster:GetGold() + 10000, true)
		-- caster:ModifyGold(-10000, true, DOTA_ModifyGold_PurchaseItem)
		-- local testModifier = caster:AddNewModifier(caster, nil, "modifier_item_moon_shard_consumed", {duration = 10, consumed_bonus = 100})
		-- modifier.goldItem:SetCurrentCharges(modifier.consumedGold)
		-- PlayerResource:AddGoldSpentOnSupport(caster:GetPlayerOwnerID(), 10000)
		-- PlayerResource:AddClaimedFarm(caster:GetPlayerOwnerID(), -10000, false)
		-- print(PlayerResource:GetClaimedFarm(caster:GetPlayerOwnerID(), false))
		-- caster:ModifyGold(1000, false, DOTA_ModifyGold_PurchaseItem)
		-- PlayerResource:SpendGold(caster:GetPlayerOwnerID(), 1000, DOTA_ModifyGold_PurchaseItem)

		-- modifier.treasureTracker:AddItem(CreateItem("item_gold_counter", caster, caster))

		self:StartCooldown(cooldown)
	end
end

function viscous_ooze_consume_items:CanConsumeItem(item)
	if not item:IsPermanent() then return false end

	local caster = self:GetCaster()

	local modifiers = caster:FindAllModifiersByName("modifier_consumed_item")
	if #modifiers >= self:GetSpecialValueFor("max_items") then return false end

	for k, modifier in pairs(modifiers) do
		if modifier.itemName and modifier.itemName == item:GetName() and item:GetCost() > 1000 then 
			return false
		end
	end

	return true
end

modifier_consumed_item = class({})

function modifier_consumed_item:IsHidden() return false end
function modifier_consumed_item:IsPermanent() return true end
function modifier_consumed_item:IsBuff() return true end
function modifier_consumed_item:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_consumed_item:OnCreated(keys)
	self.interval = keys.interval
	self.networth = keys.networth
	self.icon = keys.icon


	if IsServer() then 
		self:StartIntervalThink(self.interval)
	end
end

function modifier_consumed_item:OnIntervalThink()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local modifier = caster:FindModifierByName("modifier_consume_item_strength")

	local gold = 0
	local networth = self.networth

	if networth > 100 then 
		gold = 100
		self.networth = self.networth - 100
	else
		gold = networth
		self.networth = 0
	end

	modifier.consumedGold = modifier.consumedGold + gold

	modifier:ModifyStacks()
	caster:CalculateStatBonus( true )

	if self.networth == 0 then
		self:StartIntervalThink(-1)
	end
end

function modifier_consumed_item:OnDestroy()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local modifier = caster:FindModifierByName("modifier_consume_item_strength")

	local gold = 0
	local networth = self.networth
	if networth > 100 then 
		gold = 100
		networth = networth - 100
	else
		gold = networth
		networth = 0
	end

	modifier.consumedGold = modifier.consumedGold + gold

	modifier:ModifyStacks()
	caster:CalculateStatBonus( true )

	if self.item then self.item:Destroy() end
end

function modifier_consumed_item:DeclareFunctions() 
	local funcs = {
		MODIFIER_PROPERTY_TOOLTIP
	}
	return funcs
end

function modifier_consumed_item:OnTooltip() 
	return self:GetDuration()
end


modifier_consume_item_strength = class({})

function modifier_consume_item_strength:IsPermanent()
	return true
end

function modifier_consume_item_strength:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
    }
    return funcs
end

function modifier_consume_item_strength:IsDebuff()
	return false
end

function modifier_consume_item_strength:GetModifierBonusStats_Strength()
	if self:GetParent():PassivesDisabled() then 
		return 0
	end
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("strength_per_gold")
end

function modifier_consume_item_strength:ModifyStacks()
	self:SetStackCount(self.consumedGold / 100)
	
	-- Determine what value of items the treasure tracker should have to match the consumed gold amount
	if self.treasureTracker then

		--Remove all counter items 
		for i = 0, 8 do
			local item = self.treasureTracker:GetItemInSlot(i)
			if item then
				self.treasureTracker:RemoveItem(self.treasureTracker:GetItemInSlot(i))
				-- print("Removing item")
			end
		end

		local networth = 0
		local consumedNetworth = self.consumedGold / 100
		-- print("Consumed Networth:" .. (consumedNetworth * 100))
		local loopCounter = 0
		while loopCounter < 9 and networth < consumedNetworth do
			--add items
			local difference = consumedNetworth - networth

			-- 512 is maximum gold counter value
			while difference > 1024 do
				difference = difference / 2
			end

			if difference >= 1 then
				local counter = 1

				--double counter
				while counter <= difference do
					counter = counter * 2
				end

				counter = counter / 2

				networth = networth + counter
				local goldItem = self.treasureTracker:AddItem(CreateItem("item_gold_counter_"..(counter * 100), nil, nil))
				-- print("Add Networth Item:" .. goldItem:GetName())
			end

			loopCounter = loopCounter + 1
		end
	end

	if self.consumedGold >= 100 then
		local subability = self:GetCaster():FindAbilityByName("viscous_ooze_treasure_magic")
		if subability and not subability:IsActivated() then
			subability:SetActivated(true)
		end
	end

	return false
end

modifier_consume_item_treasure_dummy = class({})

function modifier_consume_item_treasure_dummy:CheckState()
	local states = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
	}
	return states
end

function modifier_consume_item_treasure_dummy:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE
	}
	return funcs
end

function modifier_consume_item_treasure_dummy:GetBonusVisionPercentage()
	return -100
end
