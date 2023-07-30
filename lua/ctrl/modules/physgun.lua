local tag="ctrl_physgun_admin"
local held_by_who = {}
local whos_holding = {}

require("slowhooks")

hook.Add("PhysgunPickup", tag, function(ply, ent)
	if not ply:IsAdmin() then return end
	if ent:GetClass() ~= "player" then return end
	
	if SERVER then
		ent:RemoveFlags(FL_FROZEN)
		ent:SetMoveType(MOVETYPE_NOCLIP)
	end
	
	held_by_who[ent] = ply
	whos_holding[ply] = ent
	
	ent._LastPos = Vector(0, 0, 0)
	ent._Pos = Vector(0, 0, 0)
	ent._Vel = Vector(0, 0, 0)
	return true 
end)

hook.Add("PhysgunDrop",tag,function(ply,ent)
	if ent:GetClass() ~= "player" then return end
	
	held_by_who[ent] = nil
	whos_holding[ply] = nil
	
	if ply:KeyDown(IN_ATTACK2) then
		ent:AddFlags(FL_FROZEN)
		ent:SetMoveType(MOVETYPE_NOCLIP)
		else
		ent:SetMoveType(MOVETYPE_WALK)
	end
	
	ent:SetVelocity(ent._Vel * 10)
end)

hook.Add("PlayerNoClip", tag, function(ply)
	if IsValid(held_by_who[ply]) then return false end
end)

--Calculate speed of the throw
hook.Add("SlowTick", tag, function()
	for _, ent in pairs(whos_holding) do
		if not IsValid(ent) then continue end
		
		ent._LastPos = ent._Pos
		ent._Pos = ent:GetPos()
		ent._Vel = ent._Pos - ent._LastPos
	end
end)

if SERVER then
	util.AddNetworkString(tag)
	
	hook.Add("PlayerDisconnected", tag, function(ply)
		if IsValid(whos_holding[ply]) then
			net.Start(tag)
			net.WriteEntity(ply)
			net.WriteEntity(whos_holding[ply])
			net.Broadcast()
			
			hook.Run("PhysgunDrop", ply, whos_holding[ply])
		end
		
		if IsValid(held_by_who[ply]) then 
			net.Start(tag)
			net.WriteEntity(held_by_who[ply])
			net.WriteEntity(ply)
			net.Broadcast()
			
			hook.Run("PhysgunDrop", held_by_who[ply], ply)
		end
	end)
	
	hook.Add("OnPhysgunReload", tag, function(_, ply)
		if not ply:IsAdmin() then return end
		
		local ent = ply:GetEyeTrace().Entity
		if not ent:IsFlagSet(FL_FROZEN) then return end
		
		ply:SendLua([[GAMEMODE:AddNotify(string.format("Unfrozen player %s",LocalPlayer():GetEyeTrace().Entity:Name()), NOTIFY_GENERIC, 5); surface.PlaySound("npc/roller/mine/rmine_chirp_answer1.wav")]])
		ent:RemoveFlags(FL_FROZEN)
		ent:SetMoveType(MOVETYPE_WALK)
	end)
end

if not CLIENT then return end

net.Receive(tag, function()
	local ent1 = net.ReadEntity()
	local ent2 = net.ReadEntity()
	hook.Run("PhysgunDrop", ent1, ent2)
end)

hook.Add("PlayerBindPress", tag, function(ply, bind, press)
	if not ply:IsAdmin() then return end
	if not IsValid(whos_holding[ply]) then return end
	if not (bind == "gmod_undo" or bind == "undo") then return end
	
	local target = whos_holding[ply]:Name()
	
	ctrl.CallCommand(ply, "kick", {target}, target)
	
	hook.Run("OnUndo", target)
	return true
end)