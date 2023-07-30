local repeat_offenders = {}

if SERVER then
	require("finishedloading")
	
	hook.Add("FinishedLoading", "ctrl_repeatoffender", function(ply)
		if not repeat_offenders[ply:SteamID()] then return end
		
		ply.ctrl_repeatoffender_until = CurTime() + 3600
		ctrl.msg(string.format('WARNING: potential repeat offender "%s".', ply:Name()))
	end)
end

ctrl.AddCommand("kick",function(ply,cmd,args,argstr)
	local to_kick = ctrl.EntByString(args[1])
	
	if type(to_kick) == "string" then
		if CLIENT then ctrl.err(to_kick) end
		return
	end
	
	if CLIENT then return end	
	
	local kickstr=table.concat(args, ", ", 2)
	if not to_kick:IsBot() and not to_kick:IsAdmin() then
		--You're on the shitlist for 1 hour after joining from a kick
		if IsValid(ply.ctrl_repeatoffender_until) and ply.ctrl_repeatoffender_until <= CurTime() then
			repeat_offenders[to_kick:SteamID()] = nil
		end
		
		if repeat_offenders[to_kick:SteamID()] then
			to_kick:Ban(repeat_offenders[to_kick:SteamID()], false)
		end
		
		--Every consecutive kick after the first is a 30 * times kicked min ban
		repeat_offenders[to_kick:SteamID()] = math.max(repeat_offenders[to_kick:SteamID()] + 30, 1440)
	end
	
	to_kick:Kick(#kickstr==0 and "byebye!" or kickstr)
end,"<ply>, <reason(optional)>: kicks <ply> with <reason>.",true,true)


ctrl.AddCommand("kickbots",function(ply,cmd,args,argstr)
	for k,v in pairs(player.GetBots())do
		v:Kick("Bot Kick")
	end
end,"<no args>: kick all bots from the server.",true,true, SERVER)

ctrl.AddCommand("ban",function(ply, cmd, args, argstr)
	local to_ban = ctrl.EntByString(args[1])
	
	if type(to_ban) == "string" then
		if CLIENT then ctrl.err(to_ban) end
		return
	end
	
	if to_ban:IsBot() then -- Banning bots is pointless, kick them instead.
		ctrl.CallCommand(ply, "kick", args, argstr)
		return
	end
	
	if not SERVER then return end
	
	local banstr = table.concat(args, ", ", 3)
	to_ban:Ban(tonumber(args[2]), false)
	to_ban:Kick(#banstr==0 and "Banned by admin." or banstr)
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