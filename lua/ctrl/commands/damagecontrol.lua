ctrl.AddCommand({"god", "godmode"},function(ply)
	RunConsoleCommand("ctrl_cl_damagemode", ply:HasGodMode() and 1 or 2)
	ctr.msg(string.format("Godmode %s.", ply:HasGodMode() and "enabled" or "disabled"))
end, '<no args>: toggles between "God" and "Mortal" modes.', false, false, CLIENT)

ctrl.AddCommand("buddha",function(ply)
	local dmgmode = GetConVar("ctrl_cl_damagemode"):GetInt()
	
	RunConsoleCommand("ctrl_cl_damagemode", (dmgmode ~= 3) and 3 or 1)
	ctr.msg(string.format("Buddha %s.", (dmgmode ~= 3) and "enabled" or "disabled"))
end, '<no args>: toggles between "Buddha" and "Mortal" modes.', false, false, CLIENT)

ctrl.AddCommand("karmagod",function(ply)
	local dmgmode = GetConVar("ctrl_cl_damagemode"):GetInt()
	
	RunConsoleCommand("ctrl_cl_damagemode", (dmgmode ~= 5) and 5 or 1)
	ctr.msg(string.format("Karmagod %s.", (dmgmode ~= 5) and "enabled" or "disabled"))
end, '<no args>: toggles between "Damage reflection" and "Mortal" modes.', false, true, CLIENT)

ctrl.AddCommand("butterfingers",function(ply)
	local dmgmode = GetConVar("ctrl_cl_damagemode"):GetInt()
	
	RunConsoleCommand("ctrl_cl_damagemode", (dmgmode ~= 6) and 6 or 1)
	ctr.msg(string.format("Butterfingers %s.", (dmgmode ~= 6) and "enabled" or "disabled"))
end, '<no args>: toggles between "Attacker drops weapon" and "Mortal" modes.', false, true, CLIENT)

