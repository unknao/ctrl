ctrl.registerDamageMode("damage reflection", true, true, function(ply, attacker, dmg)
	if dmg:IsFallDamage() then return true end
	if attacker == ply then return true end
	if attacker.damagemode and damagemodes[attacker.damagemode][1] then return true end --Don't affect anyone with admin damagemodes

	if not attacker:IsPlayer() and not attacker:IsNPC() then
		local phys = attacker:GetPhysicsObject()
		if not IsValid(phys) then return true end

		phys:ApplyForceOffset(dmg:GetDamageForce(), dmg:GetDamagePosition())
		attacker:TakeDamageInfo(dmg)
	end
	ply:EmitSound("FX_RicochetSound.Ricochet")

	local pos = ply:WorldToLocal(dmg:GetDamagePosition())
	dmg:SetAttacker(ply)
	dmg:SetDamageCustom(1337) --For damaging others through godmode
	dmg:SetDamageForce(-dmg:GetDamageForce())
	dmg:SetDamagePosition(attacker:LocalToWorld(pos))

	attacker:TakeDamageInfo(dmg)
	return true
end)

ctrl.registerDamageMode("attacker instantly dies", true, true, function(ply, attacker, dmg)
	if dmg:IsFallDamage() then return true end
	if attacker == ply then return true end
	if attacker.damagemode and damagemodes[attacker.damagemode][1] then return true end --Don't affect anyone with admin damagemodes

	dmg:SetAttacker(ply)
	attacker:Ignite(50)
	dmg:SetDamageType(DMG_DISSOLVE)
	dmg:SetDamageCustom(1337) --For damaging others through godmode
	dmg:SetDamageForce(-dmg:GetDamageForce())
	dmg:SetDamage(math.huge)
	attacker:TakeDamageInfo(dmg)

	return true
end)