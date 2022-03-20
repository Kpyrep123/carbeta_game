function SpawnOoze(keys)
	local hero = keys.caster
	local ability = keys.ability

	local level = hero:GetLevel()
	local networth = 0
	for i = 0, 9 do
		local item = hero:GetItemInSlot(i)
		if item then 
			networth = networth + item:GetCost()
			item:RemoveSelf()
		end
	end

	local XP = PlayerResource:GetTotalEarnedXP(hero:GetPlayerOwnerID())
	local newHero = PlayerResource:ReplaceHeroWith(hero:GetPlayerOwnerID(), "npc_dota_hero_viscous_ooze", PlayerResource:GetGold(hero:GetPlayerOwnerID()), hero:GetCurrentXP())	
	local modifier = newHero:AddNewModifier(newHero,nil,"modifier_consume_item_strength",{})
	modifier.consumedGold = networth
	modifier:SetStackCount(networth / 100)

	for i = 2, level do
		newHero:HeroLevelUp(false)
	end

	newHero:AddExperience(XP,0,false,true)
	--newHero:SetCustomHeroMaxLevel(25)

	EmitGlobalSound("Hero_Viscous_Ooze.Spawn")
	newHero:EmitSound("Hero_Viscous_Ooze.Consume_items")
	newHero:StartGesture(ACT_DOTA_CAST_ABILITY_2)
end