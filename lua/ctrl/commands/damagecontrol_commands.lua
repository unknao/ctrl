ctrl.AddCommand({"god", "godmode"},function(ply)
	RunConsoleCommand("ctrl_cl_damagemode", ply:HasGodMode() and "mortal" or "god")
	ctrl.msg(string.format("Godmode %s.", ply:HasGodMode() and "enabled" or "disabled"))
end, '<no args>: toggles between "god" and "mortal" modes.', false, false, CLIENT)

ctrl.AddCommand("buddha",function(ply)
	local dmgmode = GetConVar("ctrl_cl_damagemode"):GetString()
	
	RunConsoleCommand("ctrl_cl_damagemode", (dmgmode ~= "buddha") and "buddha" or "mortal")
	ctrl.msg(string.format("Buddha %s.", (dmgmode ~= "buddha") and "enabled" or "disabled"))
end, '<no args>: toggles between "buddha" and "mortal" modes.', false, false, CLIENT)

ctrl.AddCommand("karmagod",function(ply)
	local dmgmode = GetConVar("ctrl_cl_damagemode"):GetString()
	
	RunConsoleCommand("ctrl_cl_damagemode", (dmgmode ~= "damage reflection") and "damage reflection" or "mortal")
	ctrl.msg(string.format("Karmagod %s.", (dmgmode ~= "damage reflection") and "enabled" or "disabled"))
end, '<no args>: toggles between "damage reflection" and "mortal" modes.', false, true, CLIENT)

ctrl.AddCommand("butterfingers",function(ply)
	local dmgmode = GetConVar("ctrl_cl_damagemode"):GetString()
	
	RunConsoleCommand("ctrl_cl_damagemode", (dmgmode ~= "attacker drops weapon") and "attacker drops weapon" or "mortal")
	ctrl.msg(string.format("Butterfingers %s.", (dmgmode ~= "attacker drops weapon") and "enabled" or "disabled"))
end, '<no args>: toggles between "attacker drops weapon" and "mortal" modes.', false, true, CLIENT)

ctrl.AddCommand("damocles",function(ply)
	local dmgmode = GetConVar("ctrl_cl_damagemode"):GetString()
	
	RunConsoleCommand("ctrl_cl_damagemode", (dmgmode ~= "attacker instantly dies") and "attacker instantly dies" or "mortal")
	ctrl.msg(string.format("Damocles %s.", (dmgmode ~= "attacker instantly dies") and "enabled" or "disabled"))
end, '<no args>: toggles between "attacker instantly dies" and "mortal" modes.', false, true, CLIENT)

