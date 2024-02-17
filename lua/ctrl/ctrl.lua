local speed = SysTime()

hook.Add("ctrl_initialized", "ctrlinit", function(inittime)
	ctrl.msg(string.format("Initialized! (Took %G ms)",inittime))
end)

ctrl = ctrl or {}
ctrl.prefix = "[!./]"
ctrl.seperator = "^%w+."

AddCSLuaFile("ctrl/func.lua")
AddCSLuaFile("ctrl/load.lua")
AddCSLuaFile("ctrl/dispatch.lua")

include("ctrl/func.lua")
include("ctrl/load.lua")
include("ctrl/dispatch.lua")

if CLIENT then
	hook.Add( "AddToolMenuCategories", "ctrl.settings", function()
		spawnmenu.AddToolCategory( "Options", "CTRL", "#CTRL" )
	end)
end

hook.Run("ctrl_initialized", (SysTime() - speed) * 1000)
