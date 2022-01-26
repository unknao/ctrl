m={}
m.lt=m.lt or {}

ctrl.AddCommand("karmagod",function(ply)
    m.lt[ply]=not m.lt[ply]
	local karmacheck=m.lt[ply] and "enabled" or "disabled"
	local str=CLIENT and  string.format("karmagod %s",karmacheck) or string.format("%s %s karmagod.",ply:Name(),karmacheck)
    ctrl.msg(str)
	if SERVER then
		ply._bloodcolor=ply._bloodcolor or ply:GetBloodColor()
		ply:SetBloodColor(m.lt[ply] and 3 or ply._bloodcolor)
	end
end,"<no args>: toggles complete damage reflection (karmagod)",false,true)

if not SERVER then return end
hook.Add("EntityTakeDamage","karmagod",function(ply,dmg)
    local criminal=dmg:GetAttacker()
	if m.lt[ply] then
		local infl=dmg:GetInflictor()
		infl:EmitSound("weapons/ric"..math.random(1,5)..".wav")
		if type(criminal)~="Player" then
			if infl.CPPIGetOwner and IsValid(infl:CPPIGetOwner()) then
				if infl:CPPIGetOwner()~=ply then
					infl=infl:CPPIGetOwner()
				end
			end
		end
		local po=ply:GetPhysicsObject()
		if IsValid(po) then
			--print("bounce",po,-po:GetVelocity()*2)
			po:SetVelocity(-po:GetVelocity()*2)
			po:AddAngleVelocity(-po:GetAngleVelocity())
		end
		if IsValid(criminal) and criminal~=ply and not m.lt[criminal] then
			local po=criminal:GetPhysicsObject()
			local df=dmg:GetDamageForce()
			dmg:SetAttacker(ply)
			dmg:SetInflictor(ply)
			dmg:SetDamageForce(df)
			dmg:SetReportedPosition(ply:GetPos()-(ply:GetPos()-criminal:GetPos())*2)
			criminal:TakeDamageInfo(dmg)
		end
		return true
	end
	
end)