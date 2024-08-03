ctrl.cmds = ctrl.cmds or {}

if SERVER then
	util.AddNetworkString("ctrlcmd")
	net.Receive("ctrlcmd", function(_, ply)
		local tbl = net.ReadTable()
		ctrl.CallCommand(ply, unpack(tbl))
	end)
end

function ctrl.CallCommand(ply, cmd, args, argstr)
	local commandTable = ctrl.cmds[cmd]

	if not commandTable then
		if CLIENT then ctrl.error("Invalid command!") end
		return true
	end

	if ply then
		if commandTable.admin and not ply:IsAdmin() then
			if CLIENT then
				ctrl.error("Clearance level insufficient!", true)
			end
			return commandTable.showChat
		end
	end

	--Handle Clientside only commands
	if SERVER and commandTable.realm == CLIENT then return end

	--Handle sending to server
	if CLIENT then
		if commandTable.realm == "shared" or commandTable.realm == SERVER then
			net.Start("ctrlcmd")
			net.WriteTable({cmd, args, argstr})
			net.SendToServer()
		end

		if commandTable.realm == SERVER then return end
	end

	local ok, err = pcall(commandTable.callback, ply, cmd, args, argstr)
	if not ok then ctrl.error(err) end
end

function ctrl.AddCommand(name, callback, help, showChat, admin, realm)
	if istable(name) then
		for k, v in ipairs(name) do
			ctrl.AddCommand(v, callback, help, showChat, admin, realm)
		end
		return
	end
	if realm == nil then realm = "shared" end
	ctrl.cmds[name] = {
		callback = callback,
		help = help,
		showChat = showChat,
		admin = admin or false,
		realm = realm
	}
end

ctrl.loadFolder("ctrl/modules/")
ctrl.loadFolder("ctrl/commands/")

ctrl.message("Loaded " .. ctrl.filesLoaded .. " file(s), there were " .. #ctrl.issues .. " issue(s)")
ctrl.filesLoaded = 0



