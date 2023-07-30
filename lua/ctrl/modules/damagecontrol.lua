local tag = "ctrl_damagemode"

local PLAYER = getmetatable("Player")

function PLAYER:HasGodMode()
	return self:GetNWBool("HasGodMode", true)
end

--Name, SuperAdmin only?
local damagemodes = {
	[1] = {"Mortal", false},
	[2] = {"God", false},
	[3] = {"Buddha", false},
	[4] = {"Only mortals can hurt you", false},
	[5] = {"Damage reflection", true},
	[6] = {"Attacker drops weapon", true},
	[7] = {"Attacker instantly dies", true}
}

if SERVER then
	util.AddNetworkString(tag)
	require("finishedloading")
	
	net.Receive(tag, function(_, ply)
		local dmode = net.ReadInt(6)
		local dmode = math.Clamp(dmode, 1, #damagemodes) -- no funny business
		
		if damagemodes[dmode][2] then
			if not ply:IsAdmin() then 
				dmode = 1
			end
		end
		
		ply:SetNWBool("HasGodMode", not(dmode == 1 or dmode == 4))
		timer.Remove("ctrl_damagemode_fallback")
		ply.damagemode = dmode
	end)
	
	hook.Add("FinishedLoading", tag, function(ply)
		timer.Create("ctrl_damagemode_fallback", 10, 1, function()
			ctrl.msg(string.format("%s failed to request a damage mode, setting to mortal.", ply:Name()))
			ply.damagemode = 1
			ply:SetNWBool("HasGodMode", false)
		end)
	end)
	
	--FUNCTIONS (probably a better way of doing this)
	local damagemode_funcs = {
		[1] = function(ply, dmg) end, --Mortal
		
		[2] = function(ply, dmg) --God
			return dmg:IsFallDamage() or dmg:GetDamageCustom() ~= 1337
		end,
		
		[3] = function(ply, dmg) --Buddha
			if dmg:GetDamageCustom() == 1337 then return end
			dmg:SetDamageType(DMG_RADIATION)
			ply:SetVelocity(dmg:GetDamageForce() * 0.03) -- needed or else it stops setting player force
			dmg:SetDamageForce(Vector(0, 0, 0))
			dmg:SetDamage(math.min(ply:Health() - 1, dmg:GetDamage()))
		end,
		
		[4] = function(ply, dmg) --Only mortals can hurt you
			local attacker = dmg:GetAttacker()
			
			if not attacker:IsPlayer() then
				attacker = attacker:CPPIGetOwner()
			end
			
			if attacker.damagemode == 1 then return end -- Mortal
			if attacker.damagemode == 4 then return end -- Same as us
			
			return dmg:GetDamageCustom() ~= 1337
		end,
		
		[5] = function(ply, dmg) --Damage reflection
			if dmg:IsFallDamage() then return true end
			local attacker = dmg:GetAttacker()
			
			if attacker == ply then return true end
			--Don't affect anyone with admin damagemodes
			if attacker.damagemode then
				if damagemodes[attacker.damagemode][2] then return true end
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
			dmg:SetDamageCustom(1337) --For damaging others through godmode
			dmg:SetDamageForce(-dmg:GetDamageForce())
			dmg:SetDamagePosition(attacker:LocalToWorld(pos))
			
			attacker:TakeDamageInfo(dmg)
			return true
		end,
		
		[6] = function(ply, dmg) --Attacker drops weapon
			local attacker = dmg:GetAttacker()
			if attacker == ply then return true end
			
			--Don't affect anyone with admin damagemodes
			if attacker.damagemode then
				if damagemodes[attacker.damagemode][2] then return true end
			end
			
			if not (attacker:IsPlayer() or attacker:IsNPC()) then return end
			local wep = attacker:GetActiveWeapon()
			
			if IsValid(wep) then
				attacker:DropWeapon(wep)
				
				else
				
				for k, v in pairs(constraint.GetAllConstrainedEntities(attacker)) do
					if not v:IsVehicle() then continue end
					local driver = v:GetDriver()
					
					if IsValid(driver) then driver:ExitVehicle() end
				end
			end
			
			return true
		end,
		
		[7] = function(ply, dmg) --Attacker instantly dies
			local attacker = dmg:GetAttacker()
			if attacker == ply then return true end
			
			--Don't affect anyone with admin damagemodes
			if attacker.damagemode then
				if damagemodes[attacker.damagemode][2] then return true end
			end
			
			if attacker:IsPlayer() or attacker:IsNPC() then
				dmg:SetAttacker(ply)
				dmg:SetDamageCustom(1337) --For damaging others through godmode
				dmg:SetDamage(math.huge)
				attacker:TakeDamageInfo(dmg)
			end
			
			return true
		end
	}
	--END OF FUNCTIONS
		
	hook.Add("EntityTakeDamage", tag, function(ply, dmg)
		if not IsValid(ply) then return end
		if not ply:IsPlayer() then return end
		if not ply.damagemode then return true end
			
		return damagemode_funcs[ply.damagemode](ply, dmg)
	end)
end

if SERVER then return end
local cl_damagemode = CreateConVar("ctrl_cl_damagemode", "1", {FCVAR_ARCHIVE}, "Changes the way you take damage, see Options -> CTRL -> Damage Mode for proper usage.")

hook.Add("PopulateToolMenu", tag, function()
	spawnmenu.AddToolMenuOption( "Options", "CTRL", "Damage Mode", "#Damage Mode", "", "", function(pnl)
		local Cbox = pnl:ComboBox("Damage Mode", "ctrl_cl_damagemode")
		
		for i, v in ipairs(damagemodes) do
			if v[2] then 
				if not LocalPlayer():IsSuperAdmin() then continue end
			end
			
			Cbox:AddChoice(v[1], i)
		end
	end)
end)

cvars.AddChangeCallback("ctrl_cl_damagemode", function(_, _, val)
	net.Start(tag)
	net.WriteInt(val, 6)
	net.SendToServer()
end, "nettrigger")

--Run once on join completion
hook.Add("HUDPaint", "ctrl_damagemode_setinitial", function()
	net.Start(tag)
	net.WriteInt(cl_damagemode:GetInt(), 6)
	net.SendToServer()
	hook.Remove("HUDPaint", "ctrl_damagemode_setinitial")
end)