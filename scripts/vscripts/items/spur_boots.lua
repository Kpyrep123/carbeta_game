function spur_purge( keys )
	local caster = keys.caster

	caster:Purge(false, true, false, false, false)
end