

function jugger( keys )
	local caster = keys.caster
	local target = keys.target
	CosmeticLib:EquipHeroSet( keys.caster, 21397 )
	CosmeticLib:ReplaceWithSlotName( caster, "arcana", 7592 )

end
