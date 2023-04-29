--Name, Superadmin only?
local hurtmodes = {
	{"Mortal", false}, --1
	{"God", false}, --2
	{"Buddha", false}, --3
	{"Only mortals can hurt you", false}, --4
	{"Damage reflection", true}, --5
	{"Attacker drops weapon", true} --6
}

if SERVER then
	util.AddNetworkString("ctrl.hurtmode")
	
	net.Receive("ctrl.hurtmode", function(_, ply)
		local dmode = net.ReadInt(6)
		local dmode = math.Clamp(dmode, 1, #hurtmodes) -- no funny business
		
		if hurtmodes[dmode][2] then
			if not ply:IsSuperAdmin() then return end
		end
		ply.hurtmode = dmode
	end)
	
	--FUNCTIONS (probably a better way of doing this)
	local hurtmode_funcs = {
		function(ply, dmg) end, --Mortal
		
		function(ply, dmg)
			return not (dmg:GetDamageCustom() == 584536)
		end, --God
		
		function(ply, dmg) --Buddha
			if dmg:GetDamageCustom() == 584536 then return end
			ply:SetVelocity(dmg:GetDamageForce() * 0.011) -- needed or else it stops setting player force
			dmg:SetDamageForce(Vector(0, 0, 0))
			dmg:SetDamage(math.min(ply:Health() - 1, dmg:GetDamage()))
		end,
		
		function(ply, dmg) --Only mortals can hurt you
			if dmg:IsFallDamage() then return end
			local attacker = dmg:GetAttacker()
			
			if not attacker:IsPlayer() then
				attacker = attacker:CPPIGetOwner()
			end
			
			if attacker.hurtmode == 1 then return end -- Mortal
			if attacker.hurtmode == 4 then return end -- Same as us
			
			return not (dmg:GetDamageCustom() == 584536)
		end,
		
		function(ply, dmg) --Damage reflection
			if dmg:IsFallDamage() then return end
			local attacker = dmg:GetAttacker()
			
			if attacker == ply then return true end
			if attacker.hurtmode then
				if hurtmodes[attacker.hurtmode][2] then return true end
			end
			
			if not attacker:IsPlayer() and not attacker:IsNPC() then
				local phys = attacker:GetPhysicsObject()
				if not IsValid(phys) then return true end
				
				phys:ApplyForceOffset(dmg:GetDamageForce(), dmg:GetDamagePosition())
				attacker:TakeDamageInfo(dmg)
			end
			ply:EmitSound("FX_RicochetSound.Ricochet")
			
			local pos = ply:WorldToLocal(dmg:GetDamagePosition())
			dmg:SetAttacker(ply)
			dmg:SetDamageCustom(584536) --For damaging others through godmode
			dmg:SetDamageForce(-dmg:GetDamageForce())
			dmg:SetDamagePosition(attacker:LocalToWorld(pos))
			
			attacker:TakeDamageInfo(dmg)
			return true
		end,
		
		function(ply, dmg) --Attacker drops weapon
			local attacker = dmg:GetAttacker()
			if attacker == ply then return true end
			
			if attacker.hurtmode then
				if hurtmodes[attacker.hurtmode][2] then return true end
			end
			
			if attacker:IsPlayer() or attacker:IsNPC() then 
				local wep = attacker:GetActiveWeapon()
				if IsValid(wep) then
					attacker:DropWeapon(wep)
				end
				else
				
				for k, v in pairs(constraint.GetAllConstrainedEntities(attacker)) do
					if v:IsVehicle() then
						local driver = v:GetDriver()
						if IsValid(driver) then
							driver:ExitVehicle()
						end
					end
				end
			end
			return true
		end,
}
--END OF FUNCTIONS

	hook.Add("EntityTakeDamage","ctrl.hurtcontrol",function(ply, dmg)
		if not ply:IsPlayer() then return end
		return hurtmode_funcs[ply.hurtmode](ply, dmg)
	end)
end

if SERVER then return end
local cl_hurtmode = CreateConVar("ctrl_cl_hurt_mode", "1", {FCVAR_ARCHIVE}, "Changes the way you take damage, see Options -> CTRL -> Hurt Mode for proper usage.")

hook.Add( "PopulateToolMenu", "ctrl.hurtmode", function()
spawnmenu.AddToolMenuOption( "Options", "CTRL", "Hurt Mode", "#Hurt Mode", "", "", function(pnl)
	local Cbox = pnl:ComboBox("Hurt Mode", "ctrl_cl_hurt_mode")

	for i, v in ipairs(hurtmodes) do
		if v[2] then 
		if not LocalPlayer():IsSuperAdmin() then continue end
		end

		Cbox:AddChoice(v[1], i)
		end
	end)
end)

cvars.AddChangeCallback("ctrl_cl_hurt_mode", function(_, _, val)
	net.Start("ctrl.hurtmode")
	net.WriteInt(val, 6)
	net.SendToServer()
end, "nettrigger")

--Run once on join completion
hook.Add("HUDPaint", "ctrl.hurtmode.setinitial", function()
	net.Start("ctrl.hurtmode")
	net.WriteInt(cl_hurtmode:GetInt(), 6)
	net.SendToServer()
	hook.Remove("HUDPaint", "ctrl.hurtmode.setinitial")
end)