local speed=CurTime()
ctrl=ctrl or {}
ctrl.prefix="[!./]"
ctrl.seperator="^%w+."

AddCSLuaFile("ctrl/func.lua")
AddCSLuaFile("ctrl/cmds.lua")
AddCSLuaFile("ctrl/dispatch.lua")
include("ctrl/func.lua")
include("ctrl/cmds.lua")
include("ctrl/dispatch.lua")

hook.Run("CtrlInitialized")
ctrl.msg(string.format("Initialized! (Took %f seconds)",CurTime()-speed))
