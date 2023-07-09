ctrl.AddCommand({"abort","stop"},function()
	
	if CLIENT then return end
	ctrl.abort()
	
end,"<no args>: aborts current countdown",true,true)