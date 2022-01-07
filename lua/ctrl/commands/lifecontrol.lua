if CLIENT then
	local meta = FindMetaTable( "Player" )
	function meta:HasGodMode()
		return self:GetNWBool( "HasGodMode" )
	end
end
if SERVER then
	local meta = FindMetaTable( "Player" )
	meta.DefaultGodEnable  = meta.DefaultGodEnable  or meta.GodEnable
	meta.DefaultGodDisable = meta.DefaultGodDisable or meta.GodDisable
	function meta:GodEnable()
		self:SetNWBool( "HasGodMode", true )
		self:DefaultGodEnable()
	end
	function meta:GodDisable()
		self:SetNWBool( "HasGodMode", false )
		self:DefaultGodDisable()
	end
end
ctrl.AddCommand({"god","godmode"},function(ply)
	if CLIENT then ctrl.msg(string.format("Godmode %s.",not ply:HasGodMode() and "enabled" or "disabled")) return end
	if ply:HasGodMode() then ply:GodDisable() else ply:GodEnable() end
	ctrl.msg(string.format("%s %s godmode.",ply:Name(),ply:HasGodMode() and "enabled" or "disabled"))
end,"<no args>: toggles between godmode state.")

ctrl.AddCommand("revive",function(ply)
	if ply:Alive() then if CLIENT then ctrl.err("Can't revive whats not dead!") end return end 
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