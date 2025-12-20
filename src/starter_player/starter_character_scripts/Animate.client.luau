local Humanoid: Humanoid = game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid")
local RunService: RunService = game:GetService("RunService")
local Animations = game:GetService("ReplicatedStorage").PlayerAnimations
local Animator = Humanoid:WaitForChild("Animator")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Config.Animate).Settings
local defaultWalkSpeed = require(ReplicatedStorage.Config.Movement).Settings.DefaultSpeed
local States = require(ReplicatedStorage.GlobalVariables.AnimateStates).States

local fade = Config.fade
local defaultWeight = 1

local current = nil
local WeightTable = {
    walk = {condition = function(speed, magnitude) return speed == defaultWalkSpeed and magnitude > 0 end, weight = 1},
    sprint = {condition = function(speed, magnitude) return speed > defaultWalkSpeed and magnitude > 0 end, weight = 1},
    idle = {condition = function(speed, magnitude) return speed >= defaultWalkSpeed and magnitude == 0 end, weight = 1},
    crouchIdle = {condition = function(speed, magnitude) return speed < defaultWalkSpeed and magnitude == 0  end, weight = 1},
    crouchWalk = {condition = function(speed, magnitude) return speed < defaultWalkSpeed and magnitude > 0 end, weight = 1}
}

local Tracks = {
    crouchIdle = Animator:LoadAnimation(Animations.CrouchIdle),
    crouchWalk = Animator:LoadAnimation(Animations.CrouchWalk),
    idle = Animator:LoadAnimation(Animations.Idle),
    walk = Animator:LoadAnimation(Animations.Walk),
    sprint = Animator:LoadAnimation(Animations.Sprint)
}

function assignAdjustWeight(string: string)
    for key, _ in pairs(WeightTable) do
        if key == string then
            WeightTable[key].weight = 1
        else
            WeightTable[key].weight = 0
        end
    end

    for key, _ in pairs(Tracks) do
        Tracks[key]:AdjustWeight(WeightTable[key].weight, fade)
    end
end

function initializeTracks()
    for key, _ in pairs(Tracks) do
        Tracks[key].Priority = Enum.AnimationPriority.Movement
        Tracks[key]:Play(0, defaultWeight)
    end
end

function checkMovementMode(speed: number, magnitude: number)
    if not speed then speed = 0 end
    if not magnitude then speed = 0 end

    for key, _ in pairs(WeightTable) do
        if WeightTable[key].condition(speed, magnitude) then
            return key
        end
    end

    return "walk"
end

function assignStates(active: string)
    for key, _ in States do
        if key == active then
            States[key] = true
        else
            States[key] = false
        end
    end
end

initializeTracks()

RunService.RenderStepped:Connect(function()
    local speed = Humanoid.WalkSpeed
    local magnitude = Humanoid.MoveDirection.Magnitude
    
    task.wait(0.1)
    current = checkMovementMode(speed, magnitude)
    assignAdjustWeight(current)
    assignStates(current)
end)