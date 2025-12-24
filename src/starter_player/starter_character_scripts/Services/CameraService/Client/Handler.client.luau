local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Humanoid: Humanoid = game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid")
local Camera: Camera = game:GetService("Workspace").CurrentCamera
local States = require(ReplicatedStorage.Services.AnimationService.Shared.Data.AnimationVariables).States
local Config = require(ReplicatedStorage.Services.CameraService.Shared.Config.Camera)
local ViewBobbingConfig = Config.ViewBobbing
local DynamicFOVConfig = Config.DynamicFOV
local CrouchOffsetConfig = Config.CrouchOffset

local function expSmoothing(current, target, timeToTarget, dt)
    local k = -math.log(0.05) / timeToTarget
    local alpha = 1 - math.exp(-k * dt)
    return current + (target - current) * alpha
end

local ViewBobbing = {
    Values = {
        radians = 0,
        sign = 1,
        x = 0,
        y = 0,
    },

    Constants = {
        FULL_REVOLUTION = 2 * math.pi,
        HALF_REVOLUTION = math.pi / 2
    },

    customTick = function(self, delta: number)
        self.Values.radians += delta * self.Values.sign * ViewBobbingConfig.Settings.tickMultiplier

        if self.Values.radians >= self.Constants.FULL_REVOLUTION then self.Values.sign = -1
        elseif self.Values.radians <= 0 then self.Values.sign = 1 end

        return self.Values.radians
    end,

    getOffsetData = function(self, delta: number)
        if not (States.crouchIdle or States.idle) then
            self.Values.x = self.Values.sign * math.cos((self:customTick(delta) + self.Constants.HALF_REVOLUTION) * ViewBobbingConfig.Settings.horizontalSpeed) * ViewBobbingConfig.Settings.maxHorizontal
            self.Values.y = math.abs(math.sin(self:customTick(delta) * ViewBobbingConfig.Settings.verticalSpeed)) * ViewBobbingConfig.Settings.maxVertical
        else
            self.Values.radians = 0
            self.Values.x = expSmoothing(self.Values.x, 0, ViewBobbingConfig.Settings.offsetSmoothingTime, delta)
            self.Values.y = expSmoothing(self.Values.y, 0, ViewBobbingConfig.Settings.offsetSmoothingTime, delta)
        end

        return Vector3.new(self.Values.x, self.Values.y, 0)
    end,

    getRotateData = function(self)
        return math.sin(tick() * ViewBobbingConfig.Settings.rotationFrequency) / ViewBobbingConfig.Settings.invRotationMagnitude
    end
}

local DynamicFOV = {
    Objects = {
        FOVOffset = Instance.new("NumberValue"),
        Info = TweenInfo.new(
            DynamicFOVConfig.Settings.smoothingTime,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        NormalTween = nil,
        SprintTween = nil
    },

    initialize = function(self)
        self.Objects.FOVOffset.Value = DynamicFOVConfig.Settings.defaultFOV
        
        self.Objects.NormalTween = TweenService:Create(
            self.Objects.FOVOffset, 
            self.Objects.Info, 
            {Value = DynamicFOVConfig.Settings.defaultFOV}
        )

        self.Objects.SprintTween = TweenService:Create(
            self.Objects.FOVOffset, 
            self.Objects.Info, 
            {Value = DynamicFOVConfig.Settings.sprintFOV})
    end,

    getFOVData = function(self)
        if States.sprint then self.Objects.SprintTween:Play() else self.Objects.NormalTween:Play() end
        return self.Objects.FOVOffset.value
    end
}

local CrouchOffset = {
    Objects = {
        Info = TweenInfo.new(
            CrouchOffsetConfig.Settings.smoothingTime,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        Offset = Instance.new("NumberValue"),
        CrouchTween = nil,
        NormalTween = nil
    },

    initialize = function(self)
        self.Objects.CrouchTween = TweenService:Create(
            self.Objects.Offset, 
            self.Objects.Info, 
            {Value = CrouchOffsetConfig.Settings.crouchHeight}
        )

        self.Objects.NormalTween = TweenService:Create(
            self.Objects.Offset, 
            self.Objects.Info, 
            {Value = 0}
        )
    end,

    getOffsetData = function(self)
        if States.crouchIdle or States.crouchWalk then self.Objects.CrouchTween:Play() else self.Objects.NormalTween:Play() end

        return Vector3.new(0, self.Objects.Offset.Value, 0)
    end
}

function sum(tableData, init)
    local result = init

    for _, value in pairs(tableData) do
        result += value
    end

    return result
end

--Add table to initialize
for _, value in pairs({DynamicFOV, CrouchOffset}) do
    value:initialize()
end

RunService.RenderStepped:Connect(function(delta) 
    Humanoid.CameraOffset = sum({ViewBobbing:getOffsetData(delta), CrouchOffset:getOffsetData()}, Vector3.zero)
    Camera.CFrame *= CFrame.Angles(0, 0, ViewBobbing:getRotateData())
    Camera.FieldOfView = DynamicFOV:getFOVData()
end)

