ctrl.RegisterDamageMode("damage reflection", true, true, function(ply, dmg)
	if dmg:IsFallDamage() then return true end
	
	local attacker = dmg:GetAttacker()
	if attacker == ply then return true end
	--Don't affect anyone with admin damagemodes
	if attacker.damagemode then
		if damagemodes[attacker.damagemode][1] then return true end
	end
	
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

ctrl.RegisterDamageMode("attacker instantly dies", true, true, function(ply, dmg)
	if dmg:IsFallDamage() then return true end
	
	local attacker = dmg:GetAttacker()
	if attacker == ply then return true end
	
	--Don't affect anyone with admin damagemodes
	if attacker.damagemode then
		if damagemodes[attacker.damagemode][2] then return true end
	end
	
	dmg:SetAttacker(ply)
	attacker:Ignite(50)
	dmg:SetDamageType(DMG_DISSOLVE)
	dmg:SetDamageCustom(1337) --For damaging others through godmode
	dmg:SetDamageForce(-dmg:GetDamageForce())
	dmg:SetDamage(math.huge)
	attacker:TakeDamageInfo(dmg)
	
	return true
end)