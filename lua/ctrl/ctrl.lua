local speed=SysTime()
ctrl=ctrl or {}
ctrl.prefix="[!./]"
ctrl.seperator="^%w+."

AddCSLuaFile("ctrl/func.lua")
AddCSLuaFile("ctrl/damagecontrol.lua")
AddCSLuaFile("ctrl/cmds.lua")
AddCSLuaFile("ctrl/dispatch.lua")

include("ctrl/func.lua")
include("ctrl/damagecontrol.lua")
include("ctrl/cmds.lua")
include("ctrl/dispatch.lua")

if CLIENT then
	hook.Add( "AddToolMenuCategories", "ctrl.settings", function()
		spawnmenu.AddToolCategory( "Options", "CTRL", "#CTRL" )
	end)
end

hook.Run("CtrlInitialized")
ctrl.msg(string.format("Initialized! (Took %G ms)",(SysTime()-speed) * 1000))
