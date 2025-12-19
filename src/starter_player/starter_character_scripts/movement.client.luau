local Humanoid : Humanoid = game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Camera = game:GetService("Workspace").CurrentCamera
local TweenService: TweenService = game:GetService("TweenService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Values = require(ReplicatedStorage.Config.Movement).Settings
local Keybinds = require(ReplicatedStorage.Config.Movement).Keybindings

local crouchSpeed = Values.CrouchSpeed
local sprintSpeed = Values.SprintSpeed
local crouchFOV = Values.CrouchFOV
local sprintFOV = Values.SprintFOV
local defaultFOV = Values.DefaultFOV

local targetFOV = defaultFOV
local defaultSpeed = Values.DefaultSpeed
local FOVSmoothing = Values.FOVSmoothing
local currentFOV = Camera.FieldOfView

local tweenInfo = TweenInfo.new(
    Values.CrouchOffSetSmoothing,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)

local crouchTween = TweenService:Create(Humanoid, tweenInfo, {CameraOffset = Values.crouchOffset})
local standTween = TweenService:Create(Humanoid, tweenInfo, {CameraOffset = Values.standOffset})

Humanoid.WalkSpeed = defaultSpeed

function doSprint(_, inputState: Enum.UserInputState)
    if inputState == Enum.UserInputState.Begin then
        Humanoid.WalkSpeed = sprintSpeed
        targetFOV = sprintFOV

    elseif inputState == Enum.UserInputState.End then
        Humanoid.WalkSpeed = defaultSpeed
        targetFOV = defaultFOV

    end
end

function doCrouch(_, inputState: Enum.UserInputState)
    if inputState == Enum.UserInputState.Begin then
        Humanoid.WalkSpeed = crouchSpeed
        targetFOV = crouchFOV
        crouchTween:Play()
    elseif inputState == Enum.UserInputState.End then
        Humanoid.WalkSpeed = defaultSpeed
        targetFOV = defaultFOV
        standTween:Play()
    end
end

crouchTween.Completed:Connect(function() Humanoid.CameraOffset = Values.crouchOffset; print("hello") end)
standTween.Completed:Connect(function() Humanoid.CameraOffset = Values.standOffset; end)

ContextActionService:BindAction(
    "Sprint", 
    doSprint, 
    false,
    Keybinds.Sprint
)

ContextActionService:BindAction(
    "Crouch",
    doCrouch,
    false,
    Keybinds.Crouch
)

RunService.RenderStepped:Connect(function (delta) 
    local FOVAlpha = 1 - math.exp(-FOVSmoothing * delta)

    currentFOV = currentFOV + ((targetFOV - currentFOV) * FOVAlpha)
    Camera.FieldOfView = currentFOV
end)

