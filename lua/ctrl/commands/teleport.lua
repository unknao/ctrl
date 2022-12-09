ctrl.AddCommand({"tp","teleport"},function(pl,...)
	if not SERVER then return end
	local start = pl:GetPos() + Vector(0,0,1)
	local pltrdat = util.GetPlayerTrace( pl )
	pltrdat.mask = bit.bor(MASK_PLAYERSOLID_BRUSHONLY,MASK_SHOT_HULL)
	local pltr = util.TraceLine( pltrdat )
	
	local endpos = pltr.HitPos
	local wasinworld=util.IsInWorld(start)
	
	local diff=start-endpos
	local len=diff:Length()
	len=len>100 and 100 or len
	diff:Normalize()
	diff=diff*len
	--start=endpos+diff
	
	if not wasinworld and util.IsInWorld(endpos-pltr.HitNormal * pl:OBBMaxs().z) then
		pltr.HitNormal=-pltr.HitNormal
	end
	start=endpos+pltr.HitNormal * pl:OBBMaxs().z
	
	local tracedata = {start=start,endpos=endpos}
	
	tracedata.filter = pl
	tracedata.mins = pl:OBBMins()
	tracedata.maxs = pl:OBBMaxs()
	tracedata.mask = bit.bor(CONTENTS_PLAYERCLIP,MASK_PLAYERSOLID_BRUSHONLY,MASK_SHOT_HULL)
	local tr = util.TraceHull( tracedata )
	
	if tr.StartSolid or (wasinworld and not util.IsInWorld(tr.HitPos)) then
		tr = util.TraceHull( tracedata )
		tracedata.start=endpos+pltr.HitNormal*3
		
	end
	if tr.StartSolid or (wasinworld and not util.IsInWorld(tr.HitPos)) then
		tr = util.TraceHull( tracedata )
		tracedata.start=pl:GetPos()+Vector(0,0,1)
		
	end
	if tr.StartSolid or (wasinworld and not util.IsInWorld(tr.HitPos)) then
		tr = util.TraceHull( tracedata )
		tracedata.start=endpos+diff
		
	end
	if tr.StartSolid then return end
	if not util.IsInWorld(tr.HitPos) and wasinworld then return end
	
	pl:SetPos(tr.HitPos)
	pl:EmitSound("Chain.ImpactSoft")
end,"<no args>: brings you to cursor.")