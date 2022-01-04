ctrl.AddCommand("kick",function(ply,cmd,args,argstr)
	if string.gsub(argstr," .*","")== "bots" then
		for k,v in pairs(player.GetBots())do
			v:Kick("Bot Kick")
		end
		return
	end
	local tokick=ctrl.EntByString(args[1])
	if type(tokick)=="string" then
		ctrl.SendMsg(ply,tokick,true)
		return
	end
	local kickstr=table.concat(args,", ",2)
	if not tokick:IsBot() then
		tokick:Ban(1,false)
	end
	tokick:Kick(#kickstr==0 and "byebye!" or kickstr)
end,"<ply>, <reason(optional)>: kicks <ply> with <reason>.",true,true)

ctrl.AddCommand("ban",function(ply,cmd,args,argstr)
	local toban=ctrl.EntByString(args[1])
	if type(toban)=="string" then
		ctrl.SendMsg(ply,toban,true)
		return
	end
	if toban:IsBot() then
		ctrl.SendMsg(ply,"You can't ban a bot!",true)
		return
	end
	local banstr=table.concat(args,", ",3)
	toban:Ban(tonumber(args[2]),false)
	toban:Kick(#banstr==0 and "Banned by admin." or banstr)
end,"<ply>, <time>, <reason(optional)>: ban <ply> with <reason> for <time>.",true,true)

ctrl.AddCommand({"bot","spawnbot"},function(_,_,args,_)
	if tonumber(args[1])~= nil then
		for i=1,args[1] do
			player.CreateNextBot("Bot"..#player.GetBots()+1)
		end
		return
	end
	for k,v in pairs(args) do
		if v=="" then v="Bot"..#player.GetBots()+1 end
		player.CreateNextBot(v)
	end
end,"<args>: create one or multiple bots named <args>.",true,true)