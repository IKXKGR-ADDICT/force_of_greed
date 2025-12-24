local TweenService = game:GetService("TweenService")
local Player: Player = game:GetService("Players").LocalPlayer
local Humanoid: Humanoid = Player.Character:WaitForChild("Humanoid")
local GUI: CanvasGroup = Player:WaitForChild("PlayerGui").Services.HealthService.GUI.HealthBar.UIGroup
local HealthBar: Frame = GUI.TransparentBackground.OuterFrame.BarFrame.Bar

local TransparencyFaders = {
    Objects = {
        InfoIn = TweenInfo.new(
            0.15,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        InfoOut = TweenInfo.new(
            1,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out
        ),
        TweenFadeIn = nil,
        TweenFadeOut = nil
    },

    initialize = function(self)
        self.Objects.TweenFadeIn = TweenService:Create(
            GUI, 
            self.Objects.InfoIn, 
            {GroupTransparency = 0})

        self.Objects.TweenFadeOut = TweenService:Create(
            GUI, 
            self.Objects.InfoOut, 
            {GroupTransparency = 1})
    end,

    playTweens = function(self)
        self.Objects.TweenFadeIn:Play()
        task.wait(3)
        self.Objects.TweenFadeOut:Play()
    end
}

function updateHealth()
    local size = math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1)
    HealthBar.Size = UDim2.fromScale(size, 1)

    TransparencyFaders:playTweens()
end

TransparencyFaders:initialize()

Humanoid:GetPropertyChangedSignal("Health"):Connect(updateHealth)
