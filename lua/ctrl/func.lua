ctrl.issues={}
ctrl.filesloaded = 0

function ctrl.EntByString(str)
	if #str==0 then
		return "Invalid String!"
	end
	local lower = string.lower(str)
	local tbl={}
	--1st pass
	for k, v in pairs(player.GetAll()) do
		if v:Name()==str then return v end
		if string.find(string.lower(v:Name()), lower, 1, true) then tbl[#tbl+1]=v end
	end
	if tbl[1] then
		return tbl[1]
		else
		return string.format([[No such player %q]], str) 
	end
end

function ctrl.msg(str)
	MsgC(Color(74, 255, 137), os.date("[%H:%M:%S][CTRL] "), Color(255, 237, 74), str, "\n")
end

function ctrl.err(str)
	MsgC(Color(255, 105, 41), os.date("[%H:%M:%S][CTRL] "), Color(255, 225, 79), str, "\n")
	if CLIENT then
		notification.AddLegacy(str, NOTIFY_ERROR, 3)
		surface.PlaySound("buttons/button8.wav")
	end
end

function ctrl.LoadFolder(path)
	local files=file.Find(path.."*.lua", "LUA")
	for k, v in pairs(files) do
		AddCSLuaFile(path..v)
		local ok, err=pcall(include, path..v)
		if not ok then
			ctrl.issues[#ctrl.issues+1]=string.format("%s%s %s", path, v, err)
			continue
		end
		ctrl.filesloaded = ctrl.filesloaded + 1
	end
end