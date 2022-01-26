ctrl.AddCommand("maps",function(ply)
	if CLIENT then return end
	for k,v in pairs(file.Find("maps/*.bsp","MOD")) do
		ply:ChatPrint(string.gsub(v,".bsp",""))
	end
end,"<no args>: shows list of server maps",false,true)

ctrl.AddCommand("restart",function()
	if CLIENT then return end
	RunConsoleCommand("changelevel",game.GetMap())
end,"<no args>: restarts current map",true,true)

ctrl.AddCommand({"map","changelevel"},function(_,_,_,str)
	if CLIENT then return end
	RunConsoleCommand("changelevel",str)
end,"<no args>: changes current map",true,true)

