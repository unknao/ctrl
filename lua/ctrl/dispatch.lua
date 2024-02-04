local function text2command(txt)
	local cmd = string.match(txt, "%w+")
	local str = string.gsub(txt, ctrl.seperator, "")
	local args = string.Explode(", ", str)
	return cmd, args, str
end

if SERVER then

	hook.Add("PlayerSay", "ctrlcmd", function(ply, str)

		local txt = string.lower(str)
		if not string.match(txt[1], ctrl.prefix) then return end
		txt=string.gsub(txt, "^"..ctrl.prefix, "")
		local cmd, args, str = text2command(txt)

		net.Start("ctrlcmd")
		net.WriteTable({cmd, args, str})
		net.Send(ply)

		if not ctrl.cmds[cmd].showchat then return "" end

	end)

end

if CLIENT then
	net.Receive("ctrlcmd", function()
		ctrl.CallCommand(LocalPlayer(), unpack(net.ReadTable()))
	end)

	concommand.Add("ctrl", function(ply, cmd, args, argstr)
		if #argstr==0 then return end
		ctrl.CallCommand(ply, text2command(argstr))
	end,
	function(cmd, args)
		local ply=LocalPlayer()
		local tbl={}
		local subcmd = string.Explode(" ", string.gsub(args, "^ ", ""))[1]
		if ctrl.cmds[subcmd] then
			if ply:IsAdmin() or !ctrl.cmds[subcmd].admin then
				tbl={string.format("%s %s %s", cmd, subcmd, ctrl.cmds[subcmd].help)}
			end
			else
			for k, v in pairs(ctrl.cmds) do
				if string.find(k, subcmd) then
					if ply:IsAdmin() or !v.admin then
						tbl[#tbl+1]=string.format("%s %s", cmd, k)
					end
				end
			end
		end
		return tbl
	end)
end
