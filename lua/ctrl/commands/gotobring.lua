local function GenerateFakeName(target)
    if not IsValid(target) then return "noname" end
    local model = target:GetModel()
	if not isstring(model) then return "noname" end

    if #model > 0 then
        model = string.match(model, ".*/(%S+)%.")
    else
        model = target:GetClass()
    end

    return string.format("[%u]%s", target:EntIndex(), model)
end

ctrl.AddCommand({"go","goto"},function(ply,_,_,argstr)
	local target = ctrl.EntByString(argstr)
	if not IsValid(target) then
		if CLIENT then ctrl.error(string.format("Invalid target %q!", tostring(target)), true) end
		return
	end
	if ply == target then
		if CLIENT then ctrl.error("You can't go to yourself!", true) end
		return
	end
	if CLIENT then return end
	if not ply:isAlive() then ply:Spawn() end

	local GotoPos = target:GetPos() - target:GetForward() * -80
	ply:SetPos(GotoPos)
	ply:SetEyeAngles((target:NearestPoint(ply:GetShootPos()) - ply:GetShootPos()):Angle())
	ply:EmitSound("NPC_Antlion.Footstep")

	local name
	if target:IsPlayer() then
		name = target:Name()
	else
		name = GenerateFakeName(target)
	end

	ctrl.message(string.format("%s went to %s.", ply:Name(), name))
end,"<playername>: takes you to <playername>.",true)

ctrl.AddCommand("bring",function(ply,_,_,argstr)
	local target = ctrl.EntByString(argstr)
	if not IsValid(target) then
		if CLIENT then ctrl.error(string.format("Invalid target %q!", tostring(target)), true) end
		return
	end
	if ply == target then
		if CLIENT then ctrl.error("You can't bring yourself!", true) end
		return
	end
	if CLIENT then return end

	local trace = util.TraceLine({
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:GetAimVector() * 300,
		filter = function(ent) return ent ~= ply end
	})
	local BringPos = trace.HitPos

	if target:IsPlayer() then
		if IsValid(target:GetVehicle()) then target:ExitVehicle() end
		if not target:Alive() then target:Spawn() end
	end

	target:SetPos(BringPos)
	target:SetVelocity(-target:GetVelocity())
	target:EmitSound("NPC_Barnacle.PullPant")
	local name
	if target:IsPlayer() then
		name = target:Name()
	else
		name = GenerateFakeName(target)
	end

	ctrl.message(string.format("%s brought %s to themselves.",ply:Name(), name))
end, "<playername>: takes <playername> to you.", true, true)
