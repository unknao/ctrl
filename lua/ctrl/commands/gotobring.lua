ctrl.AddCommand({"go","goto"},function(ply,_,_,argstr)
	local gt={}
	local ply2=ctrl.EntByString(argstr)
	if ply==ply2 then
		ctrl.SendMsg(ply,"You can't go to yourself!",true)
		return
	end
	if type(ply2)=="string" then
		ctrl.SendMsg(ply,ply2,true)
		return
	end
	gt.pos = ply2:GetPos()-ply2:GetForward()*-80
	ply:SetPos(gt.pos)
	ply:SetEyeAngles((ply2:GetShootPos()-ply:GetShootPos()):Angle())
	ply:EmitSound("NPC_Antlion.Footstep")
	ctrl.msg(string.format("%s went to %s.",ply:Name(),ply2:Name()))
end,"<playername>: takes you to <playername>.",true)

ctrl.AddCommand("bring",function(ply,_,_,argstr)
	local ply2=ctrl.EntByString(argstr)
	if ply==ply2 then
		ctrl.SendErrorToPlayer(ply,"You can't bring yourself!")
		return
	end
	if type(ply2)=="string" then
		ctrl.SendMsg(ply,ply2,true)
		return
	end
	local br={}
	br.pos = ply:GetPos()+ply:GetForward()*150
	if IsValid(ply2:GetVehicle()) then ply2:ExitVehicle() end
	ply2:SetPos(br.pos)
	ply2:EmitSound("NPC_Barnacle.PullPant")
	ctrl.msg(string.format("%s brought %s to themselves.",ply:Name(),ply2:Name()))	
end,"<playername>: takes <playername> to you.",true,true)
