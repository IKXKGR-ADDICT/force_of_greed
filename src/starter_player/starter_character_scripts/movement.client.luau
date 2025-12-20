local Humanoid : Humanoid = game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Camera = game:GetService("Workspace").CurrentCamera
local TweenService: TweenService = game:GetService("TweenService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Values = require(ReplicatedStorage.Config.Movement).Settings
local Keybinds = require(ReplicatedStorage.Config.Movement).Keybindings
local Global = require(ReplicatedStorage.GlobalVariables.CameraVariables)
local States = require(ReplicatedStorage.GlobalVariables.AnimateStates).States

local crouchSpeed = Values.CrouchSpeed
local sprintSpeed = Values.SprintSpeed
local crouchFOV = Values.CrouchFOV
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

local crouchTween = TweenService:Create(Global.GlobalOffset, tweenInfo, {Value = Values.crouchOffset})
local standTween = TweenService:Create(Global.GlobalOffset, tweenInfo, {Value = Values.standOffset})

Humanoid.WalkSpeed = defaultSpeed

function doSprint(_, inputState: Enum.UserInputState)
    if inputState == Enum.UserInputState.Begin then
        Humanoid.WalkSpeed = sprintSpeed

    elseif inputState == Enum.UserInputState.End then
        Humanoid.WalkSpeed = defaultSpeed

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
    if States.sprint then
        targetFOV = Values.SprintFOV
    else
        targetFOV = Values.DefaultFOV
    end
    
    local FOVAlpha = 1 - math.exp(-FOVSmoothing * delta)

    currentFOV = currentFOV + ((targetFOV - currentFOV) * FOVAlpha)

    print(currentFOV)

    Camera.FieldOfView = currentFOV
end)

