local ContextActionService = game:GetService("ContextActionService")
local Humanoid: Humanoid = game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid")
local Config = require(game:GetService("ReplicatedStorage").Services.MovementService.Shared.Config.Movement)

function sprint(_, inputState: Enum.UserInputState)
    if inputState == Enum.UserInputState.Begin then
        Humanoid.WalkSpeed = Config.Settings.sprintWalkSpeed
    elseif inputState == Enum.UserInputState.End then
        Humanoid.WalkSpeed = Config.Settings.defaultWalkSpeed
    end
end

function crouch(_, inputState: Enum.UserInputState)
    if inputState == Enum.UserInputState.Begin then
        Humanoid.WalkSpeed = Config.Settings.crouchWalkSpeed
    elseif inputState == Enum.UserInputState.End then
        Humanoid.WalkSpeed = Config.Settings.defaultWalkSpeed
    end
end
    
ContextActionService:BindAction(
    "sprint", 
    sprint, 
    false,
    Config.Keybinds.sprint
)

ContextActionService:BindAction(
    "crouch", 
    crouch, 
    false,
    Config.Keybinds.crouch
)


