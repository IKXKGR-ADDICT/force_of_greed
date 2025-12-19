local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character:WaitForChild("Humanoid")

local frequencyMultiplier = 5
local xRangeMultiplier = 2
local yRangeMultiplier = 1.5
local smoothingFactor = 0.5
local idleDecaySmoothing = 0.75

local rollFrequencyMultiplier = 1.5
local rollDegrees = 1

local rotFactor = 0
local bobVector = 0

--Player.CameraMode = Enum.CameraMode.LockFirstPerson

function translationCalc(time: number,frequencyMult: number, xRangeMult: number, yRangeMult: number): vector
    local x = math.cos(time * frequencyMult) / xRangeMult
    local y = math.abs(math.sin(time * frequencyMult) / yRangeMult)

    print("value x   " .. tostring(x))
    print("value y   " .. tostring(y))

    local total = Vector3.new(x, y, 0)

    return total
end

function rotationCalc(time: number, frequencyMult: number, rollFrequencyMult: number, rollDegree: number, smoothingFact: number): number
    local rollCurrent = 0
    local rollTarget = 0

    rollTarget = math.sin(time * frequencyMult * rollFrequencyMult) * math.rad(rollDegree)
    rollCurrent = rollCurrent + (rollTarget - rollCurrent) * smoothingFact

    return rollCurrent
end

RunService.RenderStepped:Connect(function(delta)
    local time = tick()

    if Humanoid.MoveDirection.Magnitude > 0 then
        bobVector = translationCalc(time, frequencyMultiplier, xRangeMultiplier, yRangeMultiplier)
        rotFactor = rotationCalc(time, frequencyMultiplier, rollFrequencyMultiplier, rollDegrees, smoothingFactor)

        Humanoid.CameraOffset = Humanoid.CameraOffset:lerp(bobVector, smoothingFactor)
    else
        Humanoid.CameraOffset = Humanoid.CameraOffset * idleDecaySmoothing
        rotFactor = rotFactor * idleDecaySmoothing
    end

    Camera.CFrame = Camera.CFrame * CFrame.Angles(0, 0, rotFactor)
end)