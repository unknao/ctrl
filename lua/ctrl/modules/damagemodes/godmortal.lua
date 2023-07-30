ctrl.RegisterDamageMode("mortal", false, false, function(ply, dmg) end)

ctrl.RegisterDamageMode("god", false, true, function(ply, dmg)
	return dmg:IsFallDamage() or dmg:GetDamageCustom() ~= 1337
end)

ctrl.RegisterDamageMode("only mortals can hurt you", false, false, function(ply, dmg) --Only mortals can hurt you
	local attacker = dmg:GetAttacker()
	if not IsValid(attacker) then return true end
	
	if not attacker:IsPlayer() then
		attacker = attacker:CPPIGetOwner()
	end
	
	if dmg:GetDamageCustom() == 1337 then return end
	
	return attacker:HasGodMode()
end)