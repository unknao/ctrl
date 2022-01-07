ctrl.AddCommand({"go","goto"},function(ply,_,_,argstr)
	local ply2=ctrl.EntByString(argstr)
	if ply==ply2 then
		if CLIENT then ctrl.err("You can't go to yourself!") end
		return
	end
	if type(ply2)=="string" then
		if CLIENT then ctrl.err(ply2) end
		return
	end
	if CLIENT then return end
	local gt={}
	gt.pos = ply2:GetPos()-ply2:GetForward()*-80
	ply:SetPos(gt.pos)
	ply:SetEyeAngles((ply2:GetShootPos()-ply:GetShootPos()):Angle())
	ply:EmitSound("NPC_Antlion.Footstep")
	ctrl.msg(string.format("%s went to %s.",ply:Name(),ply2:Name()))
end,"<playername>: takes you to <playername>.",true)

ctrl.AddCommand("bring",function(ply,_,_,argstr)
	local ply2=ctrl.EntByString(argstr)
	if ply==ply2 then
		if CLIENT then ctrl.err("You can't bring yourself!") end
		return
	end
	if type(ply2)=="string" then
		if CLIENT then ctrl.err(ply2) end
		return
	end
	if CLIENT then return end
	local br={}
	br.pos = ply:GetPos()+ply:GetForward()*150
	if IsValid(ply2:GetVehicle()) then ply2:ExitVehicle() end
	if !ply2:Alive() then ply2:Spawn() end
	ply2:SetPos(br.pos)
	ply2:EmitSound("NPC_Barnacle.PullPant")
	ctrl.msg(string.format("%s brought %s to themselves.",ply:Name(),ply2:Name()))	
end,"<playername>: takes <playername> to you.",true,true)
