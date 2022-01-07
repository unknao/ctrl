ctrl.cmds=ctrl.cmds or {}
function ctrl.CallCommand(ply,cmd,args,argstr)
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
	local ok,err=pcall(whatis.callback,ply,cmd,args,argstr)
	if not ok then ctrl.err(err) end
	return whatis.showchat
end

function ctrl.AddCommand(name,callback,help,showchat,admin)
	if istable(name) then
		for k,v in ipairs(name) do
			ctrl.AddCommand(v,callback,help,showchat,admin)
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
local path="ctrl/commands/"
function ctrl.Load()
	ctrl.issues={}
	if SERVER then
		ctrl.msg("Loading commands..")
	end
	local files=file.Find(path.."*.lua","LUA")
	for k,v in pairs(files) do
		AddCSLuaFile(path..v)
		local ok,err=pcall(include,path..v)
		if not ok then
			ctrl.issues[#ctrl.issues+1]=string.format("%s%s %s",path,v,err)
		end
	end
	if SERVER then
		ctrl.msg("Loaded "..#files.." file(s), there were "..#ctrl.issues.." issue(s)")
	end
end
ctrl.Load()

