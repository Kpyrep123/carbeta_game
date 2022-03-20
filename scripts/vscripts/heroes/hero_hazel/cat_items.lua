function Kitten( keys ) -- spell start
	local caster = keys.caster
	local ability = keys.ability

	local unit = CreateUnitByName("npc_testing_courier", Vector(0,0,0), true, caster, caster, caster:GetTeamNumber())
	unit:SetControllableByPlayer(caster:GetPlayerID(), true)
	unit:SetOwner(caster)

	caster.testing_storage = caster.testing_storage or {}
	if #caster.testing_storage > 0 then
		for _,itemTable in pairs(caster.testing_storage) do
			for owner,name in pairs(itemTable) do
				local item = CreateItem(name, owner, owner)
				unit:AddItem(item)
			end
		end
	end

	ability:ApplyDataDrivenModifier(caster, unit, keys.modifier, {})
end

function Nineth( keys ) -- on take damage
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.unit

	if not target:IsAlive() then
		for i=0,8 do
			local item = target:GetItemInSlot(i)
			if item then
				caster.testing_storage[i] = {[item:GetOwner()] = item:GetName()}
			end
		end
	end
end