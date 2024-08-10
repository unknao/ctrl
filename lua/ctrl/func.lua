ctrl.issues = {}
ctrl.filesLoaded = 0

function ctrl.EntByString(str)
	if #str == 0 then
		return "Invalid String!"
	end
	local lower = string.lower(str)
	local tbl = {}
	--1st pass
	for k, v in pairs(player.GetAll()) do
		if v:Name() == str then return v end
		if string.find(string.lower(v:Name()), lower, 1, true) then tbl[#tbl + 1] = v end
	end
	if tbl[1] then
		return tbl[1]
		else
		return string.format([[No such player %q]], str)
	end
end

function ctrl.message(str, bShowChat)
	if SERVER then
		MsgC(Color(148, 255, 61), os.date("[%X][CTRL]: "), Color(235, 255, 218), str, "\n")
	else
		if bShowChat then
			chat.AddText(Color(148, 255, 61), "[CTRL]: ", Color(235, 255, 218), str)
		else
			MsgC(Color(148, 255, 61), os.date("[%X][CTRL]: "), Color(235, 255, 218), str, "\n")
		end
	end
end

function ctrl.error(str, bAudible)
	MsgC(Color(255, 105, 41), os.date("[%X][CTRL]: "), Color(255, 203, 181), str, "\n")
	if CLIENT and bAudible then
		notification.AddLegacy(str, NOTIFY_ERROR, 3)
		surface.PlaySound("buttons/button8.wav")
	end
end

function ctrl.loadFolder(path, serverOnly)
	local files = file.Find(path .. "*.lua", "LUA")

	for k, v in pairs(files) do
		if not serverOnly then AddCSLuaFile(path .. v) end

		local ok, err = pcall(include, path .. v)
		if not ok then
			ctrl.issues[#ctrl.issues + 1] = string.format("%s%s %s", path, v, err)
			continue
		end

		ctrl.filesLoaded = ctrl.filesLoaded + 1
	end
end

function ctrl.getVersion()
	local addonfolder = "addons/ctrl"
	local time_str = "Unknown"
	local name = "Unknown"
	local hash = "0"

	if file.Exists(addonfolder, "GAME") then
		addonfolder = addonfolder .. "/.git"
		local head = file.Read(addonfolder .. "/HEAD", "GAME")
		if head then
			name = string.match(head, ".*/(%S*)")
			addonfolder = addonfolder .. "/" .. string.sub(head, 6, -2)
			if file.Exists(addonfolder, "GAME") then
				time_str = os.date("%Y.%m.%d", file.Time(addonfolder, "GAME"))
				hash = file.Read(addonfolder, "GAME"):sub(1, 7)
			end
		end
	end
	return string.format("Local %s (%s:%s)", time_str, name, hash)
end
