function CDOTA_BaseNPC:GetPhysicalArmorReduction()
	local armornpc = self:GetPhysicalArmorValue()
	local armor_reduction = 1 - (0.05 * armornpc) / (1 + (0.05 * math.abs(armornpc)))

	armor_reduction = 100 - (armor_reduction * 100)

	return armor_reduction
end

-- Tenacity
function CDOTA_BaseNPC:GetTenacity()

	-- Fetch tenacity from modifiers
	local tenacity = 100
	for _, modifier in pairs(self:FindAllModifiers()) do

		-- Stacks multiplicatively
		if modifier.GetCustomTenacity then
			tenacity = tenacity * (1 - 0.01 * modifier:GetCustomTenacity())
		end
	end

	return (100 - tenacity)
end

-- Cast range bonuses
local CAST_RANGE_BONUSES_FROM_ITEMS = {}
CAST_RANGE_BONUSES_FROM_ITEMS["item_aether_lens"] = 250

local CAST_RANGE_TALENT_VALUES = {50, 60, 75, 100, 125, 150, 175, 200, 250, 275, 300, 350, 400}

function CDOTA_BaseNPC:GetCastRangeIncrease()
	local cast_range_increase = 0

	-- Bonuses from items
	for i = 0,5 do
		for item_name, item_bonus in pairs(CAST_RANGE_BONUSES_FROM_ITEMS) do
			if self:GetItemInSlot(i) and self:GetItemInSlot(i):GetName() == item_name then
				cast_range_increase = math.max(cast_range_increase, item_bonus)
			end
		end
	end

	-- Bonuses from talents
	for _, cast_range_value in pairs(CAST_RANGE_TALENT_VALUES) do
		if self:FindAbilityByName("special_bonus_cast_range_"..cast_range_value) and self:FindAbilityByName("special_bonus_cast_range_"..cast_range_value):GetLevel() > 0 then
			cast_range_increase = cast_range_increase + cast_range_value
		end
	end

	return cast_range_increase
end