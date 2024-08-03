ctrl.registerDamageMode("mortal", false, false, function(ply, dmg) end)

ctrl.registerDamageMode("god", false, true, function(ply, dmg)
	return dmg:IsFallDamage() or dmg:GetDamageCustom() ~= 1337
end)

ctrl.registerDamageMode("only mortals can hurt you", false, false, function(ply, dmg) --Only mortals can hurt you
	if not IsValid(attacker) then return true end

	if not attacker:IsPlayer() then
		attacker = attacker:CPPIGetOwner()
	end

	if dmg:GetDamageCustom() == 1337 then return end

	return attacker:HasGodMode()
end)