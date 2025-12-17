local PlayerService = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Character = PlayerService.LocalPlayer.Character
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = game:GetService("Workspace").CurrentCamera

local targetFOV = 70
local FOVSmoothing = 10
local currentFOV = Camera.FieldOfView

Humanoid.WalkSpeed = 16


function doSprint(_, inputState: Enum.UserInputState)
    if inputState == Enum.UserInputState.Begin then
        Humanoid.WalkSpeed = 25
        targetFOV = 85
    elseif inputState == Enum.UserInputState.End then
        Humanoid.WalkSpeed = 16
        targetFOV = 70
    end
end

ContextActionService:BindAction(
    "Sprint", 
    doSprint, 
    false,
    Enum.KeyCode.LeftShift
)

RunService.RenderStepped:Connect(function (delta) 
    local alpha = 1 - math.exp(-FOVSmoothing * delta)
    currentFOV = currentFOV + ((targetFOV - currentFOV) * alpha)
    Camera.FieldOfView = currentFOV
end)




