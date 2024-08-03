ctrl.AddCommand({"go","goto"},function(ply,_,_,argstr)
	local ply2 = ctrl.EntByString(argstr)
	if ply == ply2 then
		if CLIENT then ctrl.error("You can't go to yourself!") end
		return
	end
	if type(ply2) == "string" then
		if CLIENT then ctrl.error(ply2) end
		return
	end
	if CLIENT then return end
	local GotoPos = ply2:GetPos() - ply2:GetForward() * -80

	ply:SetPos(GotoPos)
	ply:SetEyeAngles((ply2:GetShootPos() - ply:GetShootPos()):Angle())
	ply:EmitSound("NPC_Antlion.Footstep")

	ctrl.message(string.format("%s went to %s.",ply:Name(),ply2:Name()))
end,"<playername>: takes you to <playername>.",true)

ctrl.AddCommand("bring",function(ply,_,_,argstr)
	local ply2 = ctrl.EntByString(argstr)

	if ply == ply2 then
		if CLIENT then ctrl.error("You can't bring yourself!") end
		return
	end

	if type(ply2) == "string" then
		if CLIENT then ctrl.error(ply2) end
		return
	end

	if CLIENT then return end
	local trace = util.TraceLine({
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:GetAimVector() * 300,
		filter = function(ent) return ent ~= ply end
	})
	local BringPos = trace.HitPos

	if IsValid(ply2:GetVehicle()) then ply2:ExitVehicle() end
	if not ply2:Alive() then ply2:Spawn() end

	ply2:SetPos(BringPos)
	ply2:SetVelocity(-ply2:GetVelocity())
	ply2:EmitSound("NPC_Barnacle.PullPant")

	ctrl.message(string.format("%s brought %s to themselves.",ply:Name(),ply2:Name()))
end, "<playername>: takes <playername> to you.", true, true)
