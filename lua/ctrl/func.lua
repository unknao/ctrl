if SERVER then
	util.AddNetworkString("ctrlmsg")
	function ctrl.SendMsg(ply,err,iserror)
		net.Start("ctrlmsg")
		net.WriteString(err)
		net.WriteBool(iserror)
		net.Send(ply)
	end
	function ctrl.EntByString(str)
		if #str==0 then
			return "Invalid String!"
		end
		local lower = string.lower(str)
		local tbl={}
		--1st pass
		for k,v in pairs(player.GetAll()) do
			if v:Name()==str then return v end
			if string.find(string.lower(v:Name()),lower,1,true) then tbl[#tbl+1]=v end
		end
		if tbl[1] then
			return tbl[1]
			else
			return string.format([[No such player %q]],str) 
		end
	end
end
if CLIENT then
	net.Receive("ctrlmsg",function()
		local str = net.ReadString()
		local err = net.ReadBool()
		if err then
			ctrl.err(str)
			else
			ctrl.msg(str)
		end
	end)
end
function ctrl.msg(str)
	if CLIENT then
		chat.AddText(Color(74,255,137),"[CTRL] ",Color(255,237,74),str)
		else
	MsgC(Color(74,255,137),os.date("[%H:%M:%S][CTRL] "),Color(255,237,74),str,"\n")
	end
end
function ctrl.err(str)
MsgC(Color(255,105,41),os.date("[%H:%M:%S][CTRL] "),Color(255,225,79),str,"\n")
if CLIENT then
notification.AddLegacy("[CTRL] "..str,NOTIFY_ERROR,3)
surface.PlaySound("buttons/button8.wav")
end
end