local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local SHOW_DURATION = 8
local MAX_STAMINA = 100
local DRAIN_PER_SEC = 25
local REGEN_PER_SEC = 18

local WHITE = Color3.new(1, 1, 1)
local BAR_TWEEN = TweenInfo.new(0.12, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = playerGui:WaitForChild("Services"):WaitForChild("StaminaService"):WaitForChild("Stamina")

local TransparentBg = ScreenGui:WaitForChild("TransparentBackground")
local OuterBar = TransparentBg:WaitForChild("OuterFrame")
local Icon = (
	ScreenGui:FindFirstChild("Icon")
	or TransparentBg:FindFirstChild("Icon")
	or OuterBar:FindFirstChild("Icon")
) :: GuiObject?

local BarFrame = OuterBar:WaitForChild("BarFrame")
local FillBar = BarFrame:WaitForChild("Bar")
local Stroke = OuterBar:FindFirstChildOfClass("UIStroke")

if Stroke then
	Stroke.Color = WHITE
end

local function setHudVisible(state: boolean)
	OuterBar.Visible = state
	if Icon and Icon:IsA("GuiObject") then
		Icon.Visible = state
	end
end

local function forceLeftAnchored()
	FillBar.AutomaticSize = Enum.AutomaticSize.None
	FillBar.AnchorPoint = Vector2.new(0, 0)
	FillBar.Position = UDim2.new(0, 0, 0, 0)
end
forceLeftAnchored()

setHudVisible(true)
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

local barTween: Tween? = nil
local function setBar(scale: number)
	scale = math.clamp(scale, 0, 1)
	forceLeftAnchored()

	if barTween then
		barTween:Cancel()
	end
	barTween = TweenService:Create(FillBar, BAR_TWEEN, {
		Size = UDim2.new(scale, 0, 1, 0),
		BackgroundColor3 = WHITE,
	})
	barTween:Play()
end

local draining = false
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		draining = true
		showForDuration()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		draining = false
	end
end)

local stamina = MAX_STAMINA
local lastShown = stamina

local function reset()
	stamina = MAX_STAMINA
	lastShown = stamina
	setBar(1)
	setHudVisible(false)
end

player.CharacterAdded:Connect(function()
	reset()
end)
if player.Character then
	reset()
end

RunService.Heartbeat:Connect(function(dt)
	local old = stamina

	if draining and stamina > 0 then
		stamina -= DRAIN_PER_SEC * dt
		if stamina <= 0 then
			stamina = 0
			draining = false
		end
	else
		stamina += REGEN_PER_SEC * dt
		if stamina >= MAX_STAMINA then
			stamina = MAX_STAMINA
		end
	end

	if stamina ~= old then
		setBar(stamina / MAX_STAMINA)
		if stamina ~= lastShown then
			lastShown = stamina
			showForDuration()
		end
	end
end)
