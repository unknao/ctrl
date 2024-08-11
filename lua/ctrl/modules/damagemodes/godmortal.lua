ctrl.registerDamageMode("mortal", false, false, function(ply, _, dmg) end)

ctrl.registerDamageMode("god", false, true, function(ply, _, dmg)
	return dmg:IsFallDamage() or dmg:GetDamageCustom() ~= 1337
end)

ctrl.registerDamageMode("only mortals can hurt you", false, false, function(ply, attacker, dmg) --Only mortals can hurt you
	if not attacker:IsPlayer() then
		print(1)
		attacker = attacker:CPPIGetOwner()
	end

	print(2)
	if dmg:GetDamageCustom() == 1337 then return end

	return attacker:HasGodMode()
end)