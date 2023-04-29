ctrl.AddCommand({"decals", "decal", "cleanupdecals"},function()
	game.CleanUpMap()
end, "<no args>: cleans up decals and sounds for you only.", false, false, CLIENT)
	