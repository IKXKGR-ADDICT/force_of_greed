local Players = game:GetService("Players")

local function disableRegen(character: Model)
	local healthScript = character:FindFirstChild("Health")
	if healthScript and healthScript:IsA("Script") then
		healthScript:Destroy()
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(disableRegen)
	if player.Character then
		disableRegen(player.Character)
	end
end)
