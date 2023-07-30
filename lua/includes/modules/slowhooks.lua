AddCSLuaFile()

local SlowThink = 0
hook.Add("Think", "SlowThink", function()
	if SlowThink == 0 then hook.Run("SlowThink") end
	SlowThink = (SlowThink + 1) % 3
end)

local SlowTick = 0
hook.Add("Tick", "SlowTick", function()
	if SlowTick == 0 then hook.Run("SlowTick") end
	SlowTick = (SlowTick + 1) % 3
end)
	