ctrl.AddCommand("revive",function(ply)
	if ply:Alive() then return end 
	if CLIENT then return end
	
	local pos=ply:GetPos()
	local eye=ply:EyeAngles()
	ply:Spawn()
	ply:SetPos(pos)
	ply:SetEyeAngles(eye)
end," <no args>: revives you.")

ctrl.AddCommand({"kill","killyourself"},function(ply) 
	if CLIENT then return end
	ply:Kill() 
end,"<no args>: kills you.")