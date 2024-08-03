if SERVER then
	local maps = file.Find("maps/*.bsp","THIRDPARTY")
	table.Merge(maps, file.Find("maps/*.bsp","MOD"))
	ctrl.maps = ctrl.maps or {}

	for _, v in pairs(maps) do
		ctrl.maps[v:gsub(".bsp", "")] = true
	end
end

ctrl.AddCommand("maps",function(ply)

	for k, _ in pairs(ctrl.maps) do
		ply:ChatPrint(k:gsub(".bsp", ""))
	end

end,"<no args>: shows list of server maps.",false,false, SERVER)

ctrl.AddCommand("restart",function(_, _, args, _)

	local duration = tonumber(args[1]) or 30
	ctrl.countdown(duration, "Restarting map...", true, RunConsoleCommand, "changelevel", game.GetMap())

end,"<delay (optional)>: restarts current map after <delay> seconds.",true,true, SERVER)

ctrl.AddCommand({"map","changelevel"},function(_, _, args, str)

	if not ctrl.maps[args[1]] then ctrl.error("Invalid map!") return end

	local duration = tonumber(args[2]) or 30
	ctrl.countdown(duration, string.format("Changing level to %s...", args[1]), true, RunConsoleCommand, "changelevel", args[1])

end,"<map name>, <delay (optional)>: changes current map after <delay> seconds.",true,true, SERVER)


