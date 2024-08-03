ctrl.registerDamageMode("attacker drops weapon", true, true, function(ply, attacker, dmg) --Attacker drops weapon
	if dmg:IsFallDamage() then return true end
	if attacker == ply then return true end

	--Don't affect anyone with admin damagemodes
	if attacker.damagemode and damagemodes[attacker.damagemode][2] then return true end

	if not (attacker:IsPlayer() or attacker:IsNPC()) then return end
	local wep = attacker:GetActiveWeapon()

	if IsValid(wep) then
		attacker:DropWeapon(wep)
	else
		for k, v in pairs(constraint.GetAllConstrainedEntities(attacker)) do
			if not v:IsVehicle() then continue end

			local driver = v:GetDriver()
			if IsValid(driver) then driver:ExitVehicle() end
		end
	end

	return true
end)