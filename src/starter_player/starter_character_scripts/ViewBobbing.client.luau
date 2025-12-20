local Player = game:GetService("Players").LocalPlayer
local Humanoid: Humanoid = Player.Character:WaitForChild("Humanoid")
local Camera: Camera = game:GetService("Workspace").CurrentCamera
local RunService: RunService = game:GetService("RunService")
local Config = require(game:GetService("ReplicatedStorage").Config.ViewBobbing)
local Settings = Config.Settings
local Var = Config.Variables
local Global = require(game:GetService("ReplicatedStorage").GlobalVariables.CameraVariables)

local finalOffset = Vector3.zero
local translationVector = Vector3.zero
local rotationDegrees = 0

local customTick = 0
local sign = 1

local xTime = math.pi / 2

function newcustomTick(delta: number)
    customTick += delta * Var.tickMultiplier * sign

    if customTick >= Var.upperBound then sign = -1
    elseif customTick <= Var.lowerBound then sign = 1 end

    return customTick
end

function translationOffset(time: number): Vector3
    local x = 0

    if time == 0 then
        x = math.cos(xTime * Settings.Frequency) / Settings.XRange
    else
        x = math.cos(time * Settings.Frequency) / Settings.XRange
    end

    local y = math.abs(math.sin(time * Settings.Frequency) / Settings.YRange)
    
    return Vector3.new(x, y, 0)
end

function rotationOffset(time: number): number
    return math.sin(time * Settings.RotateFrequency) / Settings.MaxRotate
end

Player.CameraMode = Enum.CameraMode.LockFirstPerson

RunService.RenderStepped:Connect(function(delta)
    local magnitude = Humanoid.MoveDirection.Magnitude
    local time = newcustomTick(delta)
    local rotationTime = tick()
    
    if magnitude > 0 then
        translationVector = translationOffset(time)
        finalOffset = translationVector + Global.GlobalOffset.Value
    else
        customTick = 0

        translationVector *= Settings.IdleDecay
        rotationDegrees *= Settings.IdleDecay

        finalOffset = Global.GlobalOffset.Value + translationVector
    end

    rotationDegrees = rotationOffset(rotationTime)

    Humanoid.CameraOffset = finalOffset

    Camera.CFrame = Camera.CFrame * CFrame.Angles(0, 0, rotationDegrees)
end)


