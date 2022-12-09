ctrl.AddCommand("maps",function(ply)
	if CLIENT then return end
	local maps = file.Find("maps/*.bsp","THIRDPARTY")
	table.Merge(maps, file.Find("maps/*.bsp","MOD"))
	for k,v in pairs(maps) do
		ply:ChatPrint(string.gsub(v,".bsp",""))
	end
end,"<no args>: shows list of server maps",false,false)

ctrl.AddCommand("restart",function()
	if CLIENT then return end
	RunConsoleCommand("changelevel",game.GetMap())
end,"<no args>: restarts current map",true,true)

ctrl.AddCommand({"map","changelevel"},function(_,_,_,str)
	if CLIENT then return end
	RunConsoleCommand("changelevel",str)
end,"<no args>: changes current map",true,true)


