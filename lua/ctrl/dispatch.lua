if SERVER then
	util.AddNetworkString("ctrlcmd")
	local function text2command(txt)
		local cmd=string.match(txt,"%w+")
		local str=string.gsub(txt,ctrl.seperator,"")
		local args=string.Explode(", ",str)
		return cmd,args,str
	end
	hook.Add("PlayerSay","ctrlcmd",function(ply,str)
		local txt=string.lower(str)
		if not string.match(txt[1],ctrl.prefix) then return end
		txt=string.gsub(txt,"^"..ctrl.prefix,"")
		shouldhide=ctrl.CallCommand(ply,text2command(txt))
		if not shouldhide then
			return ""
		end
	end)
	net.Receive("ctrlcmd",function(_,ply)
		local txt=net.ReadString()
		ctrl.CallCommand(ply,text2command(txt))
	end)
end
if CLIENT then
	concommand.Add("ctrl",function(ply,cmd,args,argstr)
		if #argstr==0 then return end
		net.Start("ctrlcmd")
		net.WriteString(argstr)
		net.SendToServer()
	end,
	function(cmd,args)
		local ply=LocalPlayer()
		local tbl={}
		local subcmd = string.Explode(" ",string.gsub(args,"^ ",""))[1]
		if ctrl.cmds[subcmd] then
			if ply:IsAdmin() or !ctrl.cmds[subcmd].admin then
				tbl={string.format("%s %s %s",cmd,subcmd,ctrl.cmds[subcmd].help)}
			end
		else
			for k,v in pairs(ctrl.cmds) do
				if string.find(k,subcmd) then
					if ply:IsAdmin() or !v.admin then
						tbl[#tbl+1]=string.format("%s %s",cmd,k)
					end
				end
			end
		end
		return tbl
	end)
end
