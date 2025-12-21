local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Humanoid: Humanoid = game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")
local Animations = ReplicatedStorage.PlayerAnimations
local States = require(ReplicatedStorage.GlobalVariables.AnimationVariables).States
local MovementConfig = require(ReplicatedStorage.Config.Movement)
local AnimationConfig = require(ReplicatedStorage.Config.Animation)

local AnimationStates = {
    walk = {
        Track = Animator:LoadAnimation(Animations.Walk),
        condition = function(speed: number, magnitude: number) return magnitude > 0 and speed == MovementConfig.Settings.defaultWalkSpeed end,
        weight = 1
    },
    sprint = {
        Track = Animator:LoadAnimation(Animations.Sprint),
        condition = function(speed: number, magnitude: number) return magnitude > 0 and speed == MovementConfig.Settings.sprintWalkSpeed end,
        weight = 1
    },
    crouchWalk = {
        Track = Animator:LoadAnimation(Animations.CrouchWalk),
        condition = function(speed: number, magnitude: number) return magnitude > 0 and speed == MovementConfig.Settings.crouchWalkSpeed end,
        weight = 1
    },
    crouchIdle = {
        Track = Animator:LoadAnimation(Animations.CrouchIdle),
        condition = function(speed: number, magnitude: number) return magnitude == 0 and speed == MovementConfig.Settings.crouchWalkSpeed end,
        weight = 1
    },
    idle = {
        Track = Animator:LoadAnimation(Animations.Idle),
        condition = function(speed: number, magnitude: number) return magnitude == 0 and speed == MovementConfig.Settings.defaultWalkSpeed end,
        weight = 1
    }
}

function setMovementMode(table, speed: number, magnitude: number)
    for key, value in pairs(table) do
        if value.condition(speed, magnitude) then 
            value.weight = 1
            States[key] = true

        else 
            value.weight = 0
            States[key] = false
        end

        if not value.Track.isPlaying then value.Track:Play(0, value.weight) end
        value.Track:AdjustWeight(value.weight, AnimationConfig.Settings.smoothTime)
    end
end

function initialize(table) 
    for key, value in pairs(table) do
        value.Track.Priority = Enum.AnimationPriority.Movement
        value.Track:Play(0, value.Weight)
    end
end

function processAnimation()
    task.wait(0.001)

    local magnitude = Humanoid.MoveDirection.Magnitude
    local speed = Humanoid.WalkSpeed

    setMovementMode(AnimationStates, speed, magnitude)
end

initialize(AnimationStates)
   

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    processAnimation()
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    processAnimation()
end)

