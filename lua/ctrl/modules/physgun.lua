local tag = "ctrl_physgun_admin"
local tHeldPlayers = {}

require("slowthink")

if SERVER then
	hook.Add("OnPhysgunReload", tag, function(_, ply)
		if not ply:IsAdmin() then return end
		local ent = ply:GetEyeTrace().Entity
		if not ent:IsPlayer() then return end
		if not ent:IsFrozen() then return end

		ply:SendLua([[GAMEMODE:AddNotify(string.format("Unfrozen %s",LocalPlayer():GetEyeTrace().Entity:Name()), NOTIFY_GENERIC, 5); surface.PlaySound("npc/roller/mine/rmine_chirp_answer1.wav")]])
		ent:Freeze(false)
		ent:SetMoveType(MOVETYPE_WALK)
		tHeldPlayers[ent] = nil
	end)

	hook.Add("PlayerSpawnObject", tag, function(ply)
		if ply:IsFrozen() then return false end
	end)
end

hook.Add("PhysgunPickup", tag, function(ply, ent)
	if not ply:IsAdmin() then return end
	if not ent:IsPlayer() then return end

	tHeldPlayers[ent] = true
	if SERVER then
		ent:Freeze(false)
		ent:SetMoveType(MOVETYPE_NOCLIP)

		undo.Create("Player")
		undo.AddEntity(ent)
		undo.SetPlayer(ply)
		undo.AddFunction(function(tab)
			if not IsValid(tab.Entities[1]) then return end
			local target = tab.Entities[1]:Name()
			ctrl.CallCommand(ply, "kick", {target}, target)
		end)
		ply.PlayerHoldingUndoID = undo.Finish()
	end

	ent._LastPos = Vector(0, 0, 0)
	ent._Pos = Vector(0, 0, 0)
	ent._Vel = Vector(0, 0, 0)
	return true
end)

hook.Add("PhysgunDrop",tag,function(ply,ent)
	if not ent:IsPlayer() then return end

	if ply:KeyDown(IN_ATTACK2) then
		ent:Freeze(true)
		ent:SetMoveType(MOVETYPE_NOCLIP)
		else
		ent:SetMoveType(MOVETYPE_WALK)
		tHeldPlayers[ent] = nil
	end
	if SERVER and ply.PlayerHoldingUndoID then
		undo.Remove(ply, ply.PlayerHoldingUndoID)
		ply.PlayerHoldingUndoID = nil
	end

	if not ent._Vel then return end
	ent:SetVelocity(ent._Vel * 10)
end)

hook.Add("PlayerNoClip", tag, function(ply)
	if tHeldPlayers[ply] then return false end
end)

hook.Add("PlayerBindPress", tag, function(ply, bind)
	if not bind:find("noclip") then return end
	if tHeldPlayers[ply] then return false end
end)

--Calculate speed of the throw
hook.Add("SlowThink", tag, function()
	for ent, v in pairs(tHeldPlayers) do
		if not IsValid(ent) then
			v = nil
			continue
		end

		ent._LastPos = ent._Pos
		ent._Pos = ent:GetPos()
		ent._Vel = ent._Pos - ent._LastPos
	end
end)