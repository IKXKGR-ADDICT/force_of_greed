local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local SHOW_DURATION = 8
local WHITE = Color3.new(1, 1, 1)

local BAR_TWEEN = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = playerGui:WaitForChild("Services"):WaitForChild("HealthService"):WaitForChild("Health")

local TransparentBg = ScreenGui:WaitForChild("TransparentBackground")
local OuterBar = TransparentBg:WaitForChild("OuterFrame")
local Icon = TransparentBg:FindFirstChild("Icon") :: GuiObject?

local BarFrame = OuterBar:WaitForChild("BarFrame")
local FillBar = BarFrame:WaitForChild("Bar")
local Stroke = OuterBar:FindFirstChildOfClass("UIStroke")

local function setHudVisible(state: boolean)
	OuterBar.Visible = state
	if Icon and Icon:IsA("GuiObject") then
		Icon.Visible = state
	end
end

local function removeLayouts(container: Instance)
	for _, child in ipairs(container:GetChildren()) do
		if
			child:IsA("UIGridLayout")
			or child:IsA("UIListLayout")
			or child:IsA("UIPageLayout")
			or child:IsA("UITableLayout")
		then
			child:Destroy()
		end
	end
end
removeLayouts(BarFrame)
removeLayouts(FillBar)

FillBar.AutomaticSize = Enum.AutomaticSize.None
FillBar.AnchorPoint = Vector2.new(0, 0)
FillBar.Position = UDim2.new(0, 0, 0, 0)

setHudVisible(false)

local barTween: Tween? = nil
local showToken = 0

local function showForDuration()
	setHudVisible(true)
	showToken += 1
	local myToken = showToken

	task.delay(SHOW_DURATION, function()
		if showToken == myToken then
			setHudVisible(false)
		end
	end)
end

local function setBar(scale: number)
	scale = math.clamp(scale, 0, 1)

	FillBar.AnchorPoint = Vector2.new(0, 0)
	FillBar.Position = UDim2.new(0, 0, 0, 0)

	if barTween then
		barTween:Cancel()
	end
	barTween = TweenService:Create(FillBar, BAR_TWEEN, {
		Size = UDim2.new(scale, 0, 1, 0),
		BackgroundColor3 = WHITE,
	})
	barTween:Play()
end

local connections = {}

local function clearConnections()
	for _, c in ipairs(connections) do
		c:Disconnect()
	end
	table.clear(connections)
end

local function bindHumanoid(humanoid: Humanoid)
	clearConnections()
	setHudVisible(false)

	local lastHealth = humanoid.Health

	local function applyVisualOnly()
		local maxHealth = math.max(humanoid.MaxHealth, 1)
		setBar(humanoid.Health / maxHealth)
	end

	applyVisualOnly()

	table.insert(
		connections,
		humanoid.HealthChanged:Connect(function(newHealth: number)
			if newHealth ~= lastHealth then
				lastHealth = newHealth
				showForDuration()
			end
			applyVisualOnly()
		end)
	)

	table.insert(
		connections,
		humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
			applyVisualOnly()
		end)
	)

	table.insert(
		connections,
		humanoid.Died:Connect(function()
			setBar(0)
			showForDuration()
			clearConnections()
		end)
	)
end

local function onCharacter(char: Model)
	local humanoid = char:WaitForChild("Humanoid") :: Humanoid
	bindHumanoid(humanoid)
end

if player.Character then
	onCharacter(player.Character)
end

player.CharacterAdded:Connect(onCharacter)
