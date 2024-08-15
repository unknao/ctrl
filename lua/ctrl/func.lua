ctrl.issues = {}
ctrl.filesLoaded = 0

function ctrl.EntByString(str)
	if #str == 0 then return NULL end
	if str[1] == "_" then --if the string stars with _, find by entity id instead
		local id = tonumber(string.sub(str, 2))
		if not isnumber(id) then return NULL end

		return Entity(id)
	end

	local name = string.lower(str)
	for _, ply in ipairs(player.GetAll()) do --1st pass look for exact match
		local name_lower = string.lower(ply:Name())
		if name_lower == name then return ply end
	end
	for _, ply in ipairs(player.GetAll()) do --2nd pass return the first match
		local name_lower = string.lower(ply:Name())
		if string.find(name_lower, name, 1, true) then
			return ply
		end
	end

	return NULL --nothing was found
end

function ctrl.message(str, showChat)
	if SERVER then
		MsgC(Color(148, 255, 61), os.date("[%X][CTRL]: "), Color(235, 255, 218), str, "\n")
	else
		if showChat then
			chat.AddText(Color(148, 255, 61), "[CTRL]: ", Color(235, 255, 218), str)
		else
			MsgC(Color(148, 255, 61), os.date("[%X][CTRL]: "), Color(235, 255, 218), str, "\n")
		end
	end
end

function ctrl.error(str, audible)
	MsgC(Color(255, 105, 41), os.date("[%X][CTRL]: "), Color(255, 203, 181), str, "\n")
	if CLIENT and audible then
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
