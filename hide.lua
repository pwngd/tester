local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Configuration
local WHITELIST_URL = "https://raw.githubusercontent.com/pwngd/tester/refs/heads/main/whitelist.json"
local activeConnections = {} -- Stores CharacterAdded connections
local whitelist = {} -- Stores the allowed User IDs

-- LIST OF IDS TO TURN INTO (Add IDs here separated by commas)
local DISGUISE_POOL = {
	9680391136,          -- Roblox
	9673704646,   -- Stylis Studios
	9726984161,
	9197842120,
	4423877940,
	8891520798,
	8814232984,
	5319257942,
	9531822872,
	9999609751,
	9040482868,
	10096282291,
	8238180387,
	8076223259,
	6095486727,
	7046376856,
	9565569609,
	7522189665,
	4679402937,
	8792755785,
	8366568810,-- Builderman (Example)
	8125581270,
	9395615369,
	9986535637,
	9395615369,
	9812016142
	-- Add more IDs here...
}

--------------------------------------------------------------------------------
-- Whitelist Logic
--------------------------------------------------------------------------------

local function updateWhitelist()
	local success, result = pcall(function()
		return HttpService:GetAsync(WHITELIST_URL)
	end)

	if success then
		-- Decode the JSON string into a Lua table
		local decoded = HttpService:JSONDecode(result)
		whitelist = decoded
		-- print("Whitelist updated.") 
	else
		warn("Failed to fetch whitelist from GitHub:", result)
	end
end

-- Fetch the whitelist immediately
task.spawn(updateWhitelist)

-- Update the whitelist every 60 seconds
task.spawn(function()
	while true do
		task.wait(60)
		updateWhitelist()
	end
end)

--------------------------------------------------------------------------------
-- Blankify/Hide Logic
--------------------------------------------------------------------------------

local function applyHide(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- Pick a random ID from the pool
	local randomTargetId = DISGUISE_POOL[math.random(1, #DISGUISE_POOL)]

	-- Fetch the Name and Appearance of that ID
	local success, info = pcall(function()
		local desc = Players:GetHumanoidDescriptionFromUserId(randomTargetId)
		local name = Players:GetNameFromUserIdAsync(randomTargetId)
		return {Description = desc, Name = name}
	end)

	if success and info then
		-- 1. Apply the Fake Name
		-- We allow the name to be seen (Viewer) so people see the disguise name
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer 
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged

		humanoid.DisplayName = info.Name -- Changes the overhead name
		-- Note: We cannot change character.Name securely on client/server replication 
		-- in a way that fully tricks other scripts, but DisplayName tricks players.

		-- 2. Apply the Appearance
		humanoid:ApplyDescription(info.Description)
	else
		warn("Failed to fetch disguise info for ID: " .. randomTargetId)
	end
end

local function applyUnhide(player, character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- 1. Ensure Name is Visible
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged

	-- 2. Restore Original Avatar & Name
	pcall(function()
		local originalDesc = Players:GetHumanoidDescriptionFromUserId(player.UserId)
		humanoid:ApplyDescription(originalDesc)
		humanoid.DisplayName = player.DisplayName -- Revert to original DisplayName
	end)
end

--------------------------------------------------------------------------------
-- Command Handler
--------------------------------------------------------------------------------

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		-- Convert to lowercase and remove any spaces at the end
		local msg = message:lower():gsub("%s+$", "")

		-- CHECK WHITELIST
		local userIdString = tostring(player.UserId)

		if not whitelist[userIdString] then
			return -- Stop if not on the list
		end

		-- COMMAND: %HIDE (Accepts "%hide" OR "/e %hide")
		if msg == "%hide" or msg == "/e %hide" then
			if player.Character then
				applyHide(player.Character)
			end

			-- Persistence (Re-apply if they die/reset)
			if not activeConnections[player.UserId] then
				activeConnections[player.UserId] = player.CharacterAdded:Connect(function(char)
					task.wait(0.5) -- Slight wait to ensure character is ready
					applyHide(char)
				end)
			end

			-- COMMAND: %UNHIDE (Accepts "%unhide" OR "/e %unhide")
		elseif msg == "%unhide" or msg == "/e %unhide" then
			-- Stop Persistence
			if activeConnections[player.UserId] then
				activeConnections[player.UserId]:Disconnect()
				activeConnections[player.UserId] = nil
			end

			if player.Character then
				applyUnhide(player, player.Character)
			end
		end
	end)

	-- Cleanup when player leaves
	player.AncestryChanged:Connect(function()
		if not player:IsDescendantOf(game) and activeConnections[player.UserId] then
			activeConnections[player.UserId]:Disconnect()
			activeConnections[player.UserId] = nil
		end
	end)
end)
