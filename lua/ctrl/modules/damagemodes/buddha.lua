ctrl.registerDamageMode("buddha", false, true, function(ply, _, dmg)
	if dmg:GetDamageCustom() == 1337 then return end

	--dmg:SetDamageType(DMG_RADIATION)
	ply:SetVelocity(dmg:GetDamageForce() * 0.03) -- needed or else it stops setting player force
	dmg:SetDamage(math.min(ply:Health() - 1, dmg:GetDamage()))
end)

hook.Add("ctrl_damagemode_changed", "ctrl_buddha_knockbackfix", function(ply, last, current)
	if not(last == "buddha" or current == "buddha") then return end

	if current == "buddha" then
		ply:AddEFlags(EFL_NO_DAMAGE_FORCES)
	else
		ply:RemoveEFlags(EFL_NO_DAMAGE_FORCES)
	end
end)