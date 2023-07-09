local maps = file.Find("maps/*.bsp","THIRDPARTY")
table.Merge(maps, file.Find("maps/*.bsp","MOD"))
ctrl.maps = ctrl.maps or {}

for _, v in pairs(maps) do
	ctrl.maps[v:gsub(".bsp", "")] = true
end

ctrl.AddCommand("maps",function(ply)
	if CLIENT then return end
	for _, v in pairs(maps) do
		ply:ChatPrint(string.gsub(v,".bsp",""))
	end
end,"<no args>: shows list of server maps",false,false)

ctrl.AddCommand("restart",function(_, _, args, _)
	
	if CLIENT then return end
	local duration = type(tonumber(args[1])) == "number"  and args[1] or 10
	ctrl.countdown(duration, duration, "Restarting map...", true, RunConsoleCommand, "changelevel", game.GetMap())
	
end,"<time (optional)>: restarts current map",true,true)

ctrl.AddCommand({"map","changelevel"},function(_, _, args, str)
	
	if CLIENT then return end
	if not ctrl.maps[args[1]] then ctrl.err("Invalid map!") return end
	
	local duration = type(tonumber(args[2])) == "number"  and args[1] or 10
	ctrl.countdown(duration, duration, string.format("Changing level to %s...", str), true, RunConsoleCommand, "changelevel",str)
	
end,"<map name>, <time (optional)>: changes current map",true,true)


