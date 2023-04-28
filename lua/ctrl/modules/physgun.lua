AddCSLuaFile()
local tag="sh_physgun"
local holdingplayer
local heldplayers = {}

hook.Add("PhysgunPickup", tag, function(ply, ent)
	if not ply:IsAdmin() then return end
	if not ent:CPPIGetOwner() and ent:GetClass() ~= "player" then return false end
	if ent:GetClass() == "player" then
		if SERVER then
			ent:RemoveFlags(FL_FROZEN)
			ent:SetMoveType(MOVETYPE_NOCLIP)
		end
		if CLIENT then
			holdingplayer = ent
		end
		heldplayers[ent] = true
		ent._LastPos = ent:GetPos()
		ent._Pos = ent:GetPos()
		return true 
	end
end)

hook.Add("PhysgunDrop",tag,function(ply,ent)
	if ent:GetClass() == "player" then
		if ply:KeyDown(2048) then
			ent:AddFlags(FL_FROZEN)
			ent:SetMoveType(MOVETYPE_NOCLIP)
		else
			ent:SetMoveType(MOVETYPE_WALK)
		end
		if CLIENT then
			holdingplayer = nil
		end
		ent:SetVelocity(ent._Vel*10)
		heldplayers[ent] = nil
		--ent._LastPos = nil ent._Pos = nil ent._Vel = nil
	end
end)

--Calculate speed of the throw
local slow = 0
hook.Add("Tick","Physgun_FakePlayerVelocity",function()
	--Slow Think bullshit (necessary unless you want to perfectly time throwing (which you do not))
	slow = (slow+1)%3
	if slow != 0 then return end
	for k,v in pairs(heldplayers) do
		if not IsValid(k) then continue end
		k._LastPos = k._Pos
		k._Pos = k:GetPos()
		k._Vel = k._Pos-k._LastPos
	end
end)

if SERVER then
	hook.Add("PlayerDisconnected",tag,function(ply)
		heldplayers[ply] = nil
	end)
	
	hook.Add("OnPhysgunReload",tag,function(_,ply)
		if not ply:IsAdmin() then return end
		local ent = ply:GetEyeTrace().Entity
		if ent:IsFlagSet(FL_FROZEN) then
			ply:SendLua([[GAMEMODE:AddNotify(string.format("Unfrozen player %s",LocalPlayer():GetEyeTrace().Entity:Name()), NOTIFY_GENERIC, 5); surface.PlaySound("npc/roller/mine/rmine_chirp_answer1.wav")]])
			ent:RemoveFlags(FL_FROZEN)
			ent:SetMoveType(MOVETYPE_WALK)
		end
	end)
end

if not CLIENT then return end
hook.Add("PlayerBindPress", tag, function(ply, bind, press)
	if not ply:IsAdmin() then return end
	if not holdingplayer then return end
	if bind == "undo" or bind == "gmod_undo" then
		ctrl.CallCommand(ply, "kick", {holdingplayer:Name()}, holdingplayer:Name())
		net.Start("ctrlcmd")
		net.WriteString("kick "..holdingplayer:Name())
		net.SendToServer()
		
		hook.Run("OnUndo",holdingplayer:Name())
		holdingplayer = nil
		return true
	end
end)