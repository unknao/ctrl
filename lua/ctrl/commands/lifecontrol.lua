ctrl.AddCommand("revive",function(ply)
	if ply:Alive() then return end

	local pos = ply:GetPos()
	local eye = ply:EyeAngles()
	ply:Spawn()
	ply:SetPos(pos)
	ply:SetEyeAngles(eye)
end," <no args>: revives you.", false, false, SERVER)

ctrl.AddCommand({"kill","killyourself"},function(ply)
	ply:Kill()
end,"<no args>: kills you.", true, false, SERVER)