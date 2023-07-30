ctrl.AddCommand("kick",function(ply,cmd,args,argstr)
	local tokick=ctrl.EntByString(args[1])
	if type(tokick)=="string" then
	
		if CLIENT then ctrl.err(tokick) end
		return
		
	end
	
	if CLIENT then return end	
	
	local kickstr=table.concat(args, ", ", 2)
	if not tokick:IsBot() then
		tokick:Ban(1,false)
	end
	
	tokick:Kick(#kickstr==0 and "byebye!" or kickstr)
end,"<ply>, <reason(optional)>: kicks <ply> with <reason>.",true,true)

ctrl.AddCommand("kickbots",function(ply,cmd,args,argstr)
	for k,v in pairs(player.GetBots())do
		v:Kick("Bot Kick")
	end
end,"<no args>: kick all bots from the server.",true,true, SERVER)

ctrl.AddCommand("ban",function(ply, cmd, args, argstr)
	local toban=ctrl.EntByString(args[1])
	if type(toban)=="string" then
		if CLIENT then ctrl.err(toban) end
		return
	end
	
	if toban:IsBot() then -- Banning bots is pointless, kick them instead.
		ctrl.CallCommand(ply, "kick", args, argstr)
		return
	end
	
	if not SERVER then return end
	
	local banstr = table.concat(args, ", ", 3)
	toban:Ban(tonumber(args[2]), false)
	toban:Kick(#banstr==0 and "Banned by admin." or banstr)
end,"<ply>, <time>, <reason(optional)>: ban <ply> with <reason> for <time>.",true,true)

ctrl.AddCommand({"bot", "spawnbot"}, function(_, _, args, _)
	if type(tonumber(args[1])) == "number" then
		for i=1,args[1] do
			player.CreateNextBot("Bot"..#player.GetBots()+1).hurtmode = 1
		end
		return
	end
	
	for k,v in pairs(args) do
		if v=="" then v="Bot"..#player.GetBots()+1 end
		player.CreateNextBot(v).hurtmode = 1
	end
end, "<args>: create one or multiple (if number input) bots named <args>.", true, true, SERVER)

ctrl.AddCommand("cleanup", function(_, _, args, _)
	
	local duration = type(tonumber(args[1])) == "number"  and args[1] or 30
	ctrl.countdown(duration, duration, "Cleaning up map...", false, game.CleanUpMap)
	
end, "<delay (optional)>: cleans up the map in <delay or 30 sec> seconds.", true, true, SERVER)