ctrl.AddCommand({"god","godmode"},function(ply)
	if ply:HasGodMode() then ply:GodDisable() else ply:GodEnable() end
	ctrl.SendMsg(ply,string.format("Godmode %s.",ply:HasGodMode() and "enabled" or "disabled"),false)
	net.Send(ply)
	ctrl.msg(string.format("%s %s godmode.",ply:Name(),ply:HasGodMode() and "enabled" or "disabled"))
end,"<no args>: toggles between godmode state.")

ctrl.AddCommand("revive",function(ply)
	if ply:Alive() then ctrl.SendMsg(ply,"Can't revive whats not dead!",true) return end 
	local pos=ply:GetPos()
	local eye=ply:EyeAngles()
	ply:Spawn()
	ply:SetPos(pos)
	ply:SetEyeAngles(eye)
end," <no args>: revives you.")

ctrl.AddCommand({"kill","killyourself"},function(ply) 
	if not ply then return end
	ply:Kill() 
end,"<no args>: kills you.")