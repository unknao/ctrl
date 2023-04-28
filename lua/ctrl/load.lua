ctrl.cmds=ctrl.cmds or {}
function ctrl.CallCommand(ply, cmd, args, argstr)
	local whatis=ctrl.cmds[cmd]
	if not whatis then
		if CLIENT then ctrl.err("Invalid command!") end
		return
	end
	if ply then
		if whatis.admin and not ply:IsAdmin() then 
			if CLIENT then ctrl.err("Clearance level insufficient!") end
			return whatis.showchat
		end
	end
	local ok, err=pcall(whatis.callback, ply, cmd, args, argstr)
	if not ok then ctrl.err(err) end
	return whatis.showchat
end

function ctrl.AddCommand(name, callback, help, showchat, admin)
	if istable(name) then
		for k, v in ipairs(name) do
			ctrl.AddCommand(v, callback, help, showchat, admin)
		end
		return
	end
	ctrl.cmds[name]={
		callback=callback, 
		help=help, 
		showchat=showchat, 
		admin=admin or false
	}
end

ctrl.LoadFolder("ctrl/modules/")
ctrl.LoadFolder("ctrl/commands/")

if SERVER then
	ctrl.msg("Loaded "..ctrl.filesloaded.." file(s), there were "..#ctrl.issues.." issue(s)")
	ctrl.filesloaded = 0
end


