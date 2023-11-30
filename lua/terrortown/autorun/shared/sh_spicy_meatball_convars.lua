CreateConVar("ttt2_spicy_meatball_radius", "250", {FCVAR_ARCHIVE, FCVAR_NOTFIY, FCVAR_REPLICATED})
CreateConVar("ttt2_spicy_meatball_detonate_time", "5", {FCVAR_ARCHIVE, FCVAR_NOTFIY, FCVAR_REPLICATED})
CreateConVar("ttt2_spicy_meatball_heal", "25", {FCVAR_ARCHIVE, FCVAR_NOTFIY, FCVAR_REPLICATED})

if CLIENT then
	hook.Add("TTT2FinishedLoading", "SpicyMeatball_devicon", function()
	  AddTTT2AddonDev("76561198045840138")
	end)
end

hook.Add("TTT2SyncGlobals", "AddSpicyMeatballGlobals", function()
	SetGlobalInt("ttt2_spicy_meatball_radius", GetConVar("ttt2_spicy_meatball_radius"):GetInt())
	SetGlobalInt("ttt2_spicy_meatball_detonate_time", GetConVar("ttt2_spicy_meatball_detonate_time"):GetInt())
	SetGlobalInt("ttt2_spicy_meatball_heal", GetConVar("ttt2_spicy_meatball_heal"):GetInt())
end)

cvars.AddChangeCallback("ttt2_spicy_meatball_radius", function(name, old, new)
	SetGlobalInt("ttt2_spicy_meatball_radius", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_spicy_meatball_detonate_time", function(name, old, new)
	SetGlobalInt("ttt2_spicy_meatball_detonate_time", tonumber(new))
end)
cvars.AddChangeCallback("ttt2_spicy_meatball_heal", function(name, old, new)
	SetGlobalInt("ttt2_spicy_meatball_heal", tonumber(new))
end)