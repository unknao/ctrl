ctrl.AddCommand("me",function(ply,_,_,txt)
	if CLIENT then return end
	net.Start("chatprint")
	net.WriteTable({
		ply:GetPlayerColor():ToColor(),
		ply:Name().." "..txt
	})
	net.WriteBool(true)
	net.Broadcast()
end,"<text>: says <text> in 3rd person.")
ctrl.AddCommand("tts",function(ply,_,_,txt) 
	net.Start("3dplay")
	net.WriteTable({
		"https://translate.google.com/translate_tts?ie=UTF-8&&tl=en&client=tw-ob&q="..txt,
		ply,
	})
	if CLIENT then return end
	net.Broadcast()
	net.Start("chatprint")
	net.WriteTable({
		ply:GetPlayerColor():ToColor(),
		ply:Name(),
		Color(200,200,200),
		"[TTS]",
		Color(255,255,255),
		": "..txt
	})
	net.WriteBool(true)
	net.Broadcast()
end,"<text>: vocalizes <text> via Text-To-Speech.")
ctrl.AddCommand("rainbow",function(ply,_,_,txt)
	if CLIENT then return end
	local tbl={
		a=1,
		contents={}
	}
	if txt=="" then 
		net.Start("chatprint")
		net.WriteTable({
			Color(255,153,0),
			"Invalid Message!"
		})
		net.Send(ply)
		return
	end
	for i=1,#txt do
		tbl.contents[tbl.a]=HSVToColor((360/#txt)*(i-1),1,1)
		tbl.a=tbl.a+1
		tbl.contents[tbl.a]=txt[i]
		tbl.a=tbl.a+1
	end
	net.Start("chatprint")
	net.WriteTable({
		ply:GetPlayerColor():ToColor(),
		ply:Name(),
		Color(255,255,255),
		": ",
		unpack(tbl.contents)
	})
	net.WriteBool(true)
	net.Broadcast()
end,"<text>: rainbowises <text>.")