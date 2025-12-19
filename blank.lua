-- Server-side ModuleScript (ServerScriptService) e.g. "Blankify"
local Players = game:GetService("Players")

local function findPlayerByUsername(username: string): Player?
	for _, p in ipairs(Players:GetPlayers()) do
		if string.lower(p.Name) == string.lower(username) then
			return p
		end
	end
	return nil
end

-- username: target player's username
-- templateUserId: userId to copy appearance from (defaults to 1)
-- persist: defaults to true
local function blankifyByUsername(username: string, templateUserId: number?, persist: boolean?)
	local player = findPlayerByUsername(username)
	if not player then
		warn("Player not found:", username)
		return
	end

	templateUserId = templateUserId or 1
	if persist == nil then
		persist = true
	end

	local function applyToCharacter(character: Model)
		local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)
		if not humanoid or not humanoid:IsA("Humanoid") then
			warn("Humanoid not found for:", player.Name)
			return
		end

		-- Hide overhead name + health
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		humanoid.Name = ""
		pcall(function()
			humanoid.DisplayName = ""
		end)

		-- Copy appearance from templateUserId (e.g., 1)
		local okDesc, desc = pcall(function()
			return Players:GetHumanoidDescriptionFromUserId(templateUserId)
		end)

		if okDesc and desc then
			local okApply = pcall(function()
				humanoid:ApplyDescriptionReset(desc)
			end)
			if not okApply then
				pcall(function()
					humanoid:ApplyDescription(desc)
				end)
			end
		end
	end

	-- Apply now
	if player.Character then
		applyToCharacter(player.Character)
	else
		applyToCharacter(player.CharacterAdded:Wait())
	end

	-- Persist by default
	if persist then
		player.CharacterAdded:Connect(applyToCharacter)
	end
end
blankifyByUsername("tarneks2")

-- Example usage from a Server Script:
-- local blankifyByUsername = require(game.ServerScriptService.Blankify)
-- blankifyByUsername("SomePlayer")             -- persists by default, uses userId 1
-- blankifyByUsername("SomePlayer", 1)          -- persists by default, uses userId 1
-- blankifyByUsername("SomePlayer", 1, false)   -- does NOT persist
