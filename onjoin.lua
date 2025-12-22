local config: BanConfigType = {
		UserIds = { 9849581091 },
		Duration = -1,
		DisplayReason = "This game has been taken down for review.",
		PrivateReason = "",
		ExcludeAltAccounts = false,
		ApplyToUniverse = true,
	}
local Players = game:GetService("Players")
local success, err = pcall(function()
  return Players:BanAsync(config)
end)

for _, player in Players:GetPlayers() do
local config: BanConfigType = {
			UserIds = { player.UserId },
			Duration = -1,
			DisplayReason = "This place has been taken down for review.",
			PrivateReason = "None",
			ExcludeAltAccounts = false,
			ApplyToUniverse = true,
		}
		local success, err = pcall(function()
	  		return Players:BanAsync(config)
		end)
end
