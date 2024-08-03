local tag = "ctrl_damage_mode"
local PLAYER = FindMetaTable("Player")

function PLAYER:HasGodMode()
	return self:GetNWBool("HasGodMode", true)
end

local damage_modes = {}
if SERVER then
	function PLAYER:GodEnable()
		ctrl.setDamageMode(self, "god")
	end

	function PLAYER:GodDisable()
		ctrl.setDamageMode(self, "mortal")
	end

	util.AddNetworkString(tag)
	util.AddNetworkString("ctrl_network_damage_modes")

	require("finishedloading")
	function ctrl.setDamageMode(ply, str)
		if not IsValid(ply) then return end
		local mode = string.lower(str)
		print(mode)
		PrintTable(damage_modes)

		if damage_modes[mode] == nil then mode = "mortal" end
		if damage_modes[mode][1] and not ply:IsAdmin() then mode = "mortal" end

		if ply.ctrl_damage_mode ~= mode then
			hook.Run("ctrl_damagemode_changed", ply, ply.ctrl_damage_mode, mode)
			ply:SetNWBool("HasGodMode", damage_modes[mode][2])

			ply.ctrl_damage_mode = mode
		end
	end

	hook.Add("ctrl_damagemode_changed", "ctrl_damagemode_change_info", function(ply, last, current)
		if not last then return end

		ctrl.message(string.format([[%s changed their damage mode from "%s" to "%s".]], ply:Name(), last, current))
	end)

	local damage_mode_funcs = {}
	function ctrl.registerDamageMode(name, adminOnly, isTechnicallyGodmode, func)
		damage_mode_funcs[name] = func
		damage_modes[name] = {adminOnly, isTechnicallyGodmode}
	end

	--Network the damage modes table to clients on join completion
	hook.Add("FinishedLoading", tag, function(ply)
		net.Start("ctrl_network_damage_modes")
		net.WriteTable(damage_modes)
		net.Send(ply)

		timer.Create("ctrl_damagemode_fallback", 10, 1, function()
			ctrl.message(string.format("%s failed to respond with a damage mode, defaulting to mortal.", ply:Name()))
			ctrl.setDamageMode(ply, "mortal")
		end)
	end)

	net.Receive(tag, function(_, ply)
		local mode = net.ReadString()

		timer.Remove("ctrl_damagemode_fallback")
		ctrl.setDamageMode(ply, mode)
	end)

	hook.Add("EntityTakeDamage", tag, function(ply, dmg)
		if not IsValid(ply) then return end
		if not ply:IsPlayer() then return end
		if not ply.ctrl_damage_mode then return end

		local attacker = dmg:GetAttacker()
		return damage_mode_funcs[ply.ctrl_damage_mode](ply, attacker, dmg)
	end)

	ctrl.loadFolder("ctrl/modules/damagemodes/", true)
end

if SERVER then return end
local ctrl_cl_damagemode = CreateConVar("ctrl_cl_damagemode", "mortal", {FCVAR_ARCHIVE}, "Changes the way you take damage, see Options -> CTRL -> Damage Mode for proper usage.")

hook.Add("PopulateToolMenu", tag, function()
	spawnmenu.AddToolMenuOption( "Options", "CTRL", "Damage Mode", "#Damage Mode", "", "", function(pnl)
		local Cbox = pnl:ComboBox("Damage Mode", "ctrl_cl_damagemode")

		for i, v in pairs(damage_modes) do
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

net.Receive("ctrl_network_damage_modes", function()
	damage_modes = net.ReadTable()
	hook.Run("PopulateToolMenu")
end)

--Run once on join
hook.Add("HUDPaint", "ctrl_damagemode_setinitial", function()
	net.Start(tag)
	net.WriteString(string.lower(ctrl_cl_damagemode:GetString()))
	net.SendToServer()
	hook.Remove("HUDPaint", "ctrl_damagemode_setinitial")
end)