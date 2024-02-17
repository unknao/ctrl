local tag = "ctrl_damagemode"
local PLAYER = FindMetaTable("Player")

function PLAYER:HasGodMode()
	return self:GetNWBool("HasGodMode", true)
end

local damagemodes = {}
if SERVER then
	function PLAYER:GodEnable()
		ctrl.SetDamageMode(self, "god")
	end

	function PLAYER:GodDisable()
		ctrl.SetDamageMode(self, "mortal")
	end

	util.AddNetworkString(tag)
	util.AddNetworkString("ctrl_network_damagemodes")

	require("finishedloading")
	function ctrl.SetDamageMode(ply, mode)
		if not IsValid(ply) then return end
		local mode = string.lower(mode)

		if damagemodes[mode] == nil then mode = "mortal" end
		if damagemodes[mode][1] and not ply:IsAdmin() then mode = "mortal" end

		if ply.ctrl_damagemode ~= mode then
			hook.Run("ctrl_damagemode_changed", ply, ply.ctrl_damagemode, mode)
			ply:SetNWBool("HasGodMode", damagemodes[mode][2])

			ply.ctrl_damagemode = mode
		end
	end

	hook.Add("ctrl_damagemode_changed", "ctrl_damagemode_change_info", function(ply, last, current)
		if not last then return end

		ctrl.msg(string.format([[%s changed their damage mode from "%s" to "%s".]], ply:Name(), last, current))
	end)

	local damagemode_funcs = {}
	function ctrl.RegisterDamageMode(name, adminonly, is_technically_godmode, func)
		damagemode_funcs[name] = func
		damagemodes[name] = {adminonly, is_technically_godmode}
	end

	net.Receive(tag, function(_, ply)
		local mode = net.ReadString()

		timer.Remove("ctrl_damagemode_fallback")
		ctrl.SetDamageMode(ply, mode)
	end)

	--Network the damage modes table to clients on join completion
	hook.Add("FinishedLoading", tag, function(ply)
		net.Start("ctrl_network_damagemodes")
		net.WriteTable(damagemodes)
		net.Send(ply)

		timer.Create("ctrl_damagemode_fallback", 10, 1, function()
			ctrl.msg(string.format("%s failed to respond with a damage mode, defaulting to mortal.", ply:Name()))
			ctrl.SetDamageMode(ply, "mortal")
		end)
	end)

	hook.Add("EntityTakeDamage", tag, function(ply, dmg)
		if not IsValid(ply) then return end
		if not ply:IsPlayer() then return end
		if not ply.ctrl_damagemode then return end

		return damagemode_funcs[ply.ctrl_damagemode](ply, dmg)
	end)

	ctrl.LoadFolder("ctrl/modules/damagemodes/", true)
end

if SERVER then return end
local cl_damagemode = CreateConVar("ctrl_cl_damagemode", "mortal", {FCVAR_ARCHIVE}, "Changes the way you take damage, see Options -> CTRL -> Damage Mode for proper usage.")

hook.Add("PopulateToolMenu", tag, function()
	spawnmenu.AddToolMenuOption( "Options", "CTRL", "Damage Mode", "#Damage Mode", "", "", function(pnl)
		local Cbox = pnl:ComboBox("Damage Mode", "ctrl_cl_damagemode")

		for i, v in pairs(damagemodes) do
			if v[1] and not LocalPlayer():IsAdmin() then continue end

			Cbox:AddChoice(i, nil, false, v[1] and "icon16/shield.png" or "icon16/user_suit.png")
		end
	end)
end)

cvars.AddChangeCallback("ctrl_cl_damagemode", function(_, old, new)
	net.Start(tag)
	net.WriteString(string.lower(new))
	net.SendToServer()
end, "nettrigger")

net.Receive("ctrl_network_damagemodes", function()
	damagemodes = net.ReadTable()
	hook.Run("PopulateToolMenu")
end)

--Run once on join
hook.Add("HUDPaint", "ctrl_damagemode_setinitial", function()
	net.Start(tag)
	net.WriteString(string.lower(cl_damagemode:GetString()))
	net.SendToServer()
	hook.Remove("HUDPaint", "ctrl_damagemode_setinitial")
end)