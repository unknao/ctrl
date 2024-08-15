
ctrl.AddCommand("kickbots",function(ply,cmd,args,argstr)
	for _,v in ipairs(player.GetBots()) do
		v:Kick("Bot Kick")
	end
end,"<no args>: kick all bots from the server.", true, true, SERVER)

ctrl.AddCommand("kick",function(ply,cmd,args,argstr)
	local victim = ctrl.EntByString(args[1])
	if not IsValid(victim) then
		if CLIENT then ctrl.error("Invalid target %q") end
		return
	end
	if CLIENT then return end

	local kickstr = table.concat(args, ", ", 2)
	ctrl.kick(victim, kickstr)
end,"<ply>, <reason(optional)>: kicks <ply> with <reason>.",true,true)


ctrl.AddCommand("ban", function(ply, cmd, args, argstr)
	local victim = ctrl.EntByString(args[1])
	if not IsValid(victim) then
		if CLIENT then ctrl.error("Invalid target %q") end
		return
	end
	if CLIENT then return end

	local banstr = table.concat(args, ", ", 3)
	ctrl.ban(victim, tonumber(args[2]), banstr)
end,"<ply>, <time>, <reason(optional)>: ban <ply> with <reason> for <time>.", true, true)

ctrl.AddCommand({"bot", "spawnbot"}, function(_, _, args, _)
	if type(tonumber(args[1])) == "number" then
		for _ = 1,args[1] do
			local bot = player.CreateNextBot("Bot" .. #player.GetBots() + 1)
			if not IsValid(bot) then return end

			bot.hurtmode = 1
		end
		return
	end

	for k,v in pairs(args) do
		if v == "" then v = "Bot" .. #player.GetBots() + 1 end
		local bot = player.CreateNextBot(v)
		if not IsValid(bot) then return end

		bot.hurtmode = 1
	end
end, "<args>: create one or multiple (if number input) bots named <args>.", true, true, SERVER)

ctrl.AddCommand("cleanup", function(_, _, args, _)
	local duration = type(tonumber(args[1])) == "number"  and args[1] or 30
	ctrl.countdown(duration, duration, "Cleaning up map...", false, game.CleanUpMap)
end, "<delay (optional)>: cleans up the map in <delay or 30 sec> seconds.", true, true, SERVER)