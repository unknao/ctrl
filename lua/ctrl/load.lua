ctrl.cmds=ctrl.cmds or {}

if SERVER then
	util.AddNetworkString("ctrlcmd")
	net.Receive("ctrlcmd", function(_, ply)
		local tbl = net.ReadTable()
		ctrl.CallCommand(ply, unpack(tbl))
	end)
end

function ctrl.CallCommand(ply, cmd, args, argstr)
	local whatis = ctrl.cmds[cmd]

	if not whatis then
		if CLIENT then ctrl.err("Invalid command!") end
		return true
	end
	
	if ply then
		if whatis.admin and not ply:IsAdmin() then 
			if CLIENT then ctrl.err("Clearance level insufficient!") end
			return whatis.showchat
		end
	end

	--Handle Clientside only commands.
	if SERVER then
		if whatis.realm == CLIENT then return end
	end

	--Handle sending to server.
	if CLIENT then
		if whatis.realm == "shared" or whatis.realm == SERVER then
			net.Start("ctrlcmd")
			net.WriteTable({cmd, args, argstr})
			net.SendToServer()
			
			if whatis.realm == SERVER then return end
		end
	end	
	
	local ok, err=pcall(whatis.callback, ply, cmd, args, argstr)
	if not ok then ctrl.err(err) end
end

function ctrl.AddCommand(name, callback, help, showchat, admin, realm)
	if istable(name) then
		for k, v in ipairs(name) do
			ctrl.AddCommand(v, callback, help, showchat, admin, realm)
		end
		return
	end
	if realm == nil then realm = "shared" end
	ctrl.cmds[name] = {
		callback = callback, 
		help = help, 
		showchat = showchat, 
		admin = admin or false,
		realm = realm
	}
end

ctrl.LoadFolder("ctrl/modules/")
ctrl.LoadFolder("ctrl/commands/")

ctrl.msg("Loaded "..ctrl.filesloaded.." file(s), there were "..#ctrl.issues.." issue(s)")
ctrl.filesloaded = 0



