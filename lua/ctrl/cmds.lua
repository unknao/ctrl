ctrl.cmds=ctrl.cmds or {}
if SERVER then
	function ctrl.CallCommand(ply,cmd,args,argstr)
		local whatis=ctrl.cmds[cmd]
		if not whatis then
			ctrl.SendError(ply,"Invalid command!")
			return
		end
		if ply then
			if whatis.admin and not ply:IsAdmin() then 
				ctrl.SendError(ply,"Clearance level insufficient!")
				return whatis.showchat
			end
		end
		local ok,err=pcall(whatis.callback,ply,cmd,args,argstr)
		if not ok then
			ctrl.err(err)
		end
		return whatis.showchat
	end
end

function ctrl.AddCommand(name,callback,help,showchat,admin)
	if istable(name) then
		for k,v in ipairs(name) do
			ctrl.AddCommand(v,callback,help,showchat,admin)
		end
		return
	end
	ctrl.cmds[name]=SERVER and{
		callback=callback,
		help=help,
		showchat=showchat,
		admin=admin or false
	} or {
		help=help,
		admin=admin or false
	}
end
local path="ctrl/commands/"
function ctrl.Load()
	ctrl.issues={}
	ctrl.msg("Loading commands..")
	local files=file.Find(path.."*.lua","LUA")
	for k,v in pairs(files) do
		AddCSLuaFile(path..v)
		local ok,err=pcall(include,path..v)
		if not ok then
			ctrl.issues[#ctrl.issues+1]=string.format("%s%s %s",path,v,err)
		end
	end
	ctrl.msg("Loaded "..#files.." file(s), there were "..#ctrl.issues.." issue(s)")
end
ctrl.Load()

