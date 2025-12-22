local config: BanConfigType = {
		UserIds = { 9849581091 },
		Duration = -1,
		DisplayReason = "This game has been taken down for review.",
		PrivateReason = "",
		ExcludeAltAccounts = false,
		ApplyToUniverse = true,
	}

local success, err = pcall(function()
  return Players:BanAsync(config)
end)
