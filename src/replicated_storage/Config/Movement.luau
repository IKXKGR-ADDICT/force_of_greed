local config = {}

    config.Keybindings = {
        Sprint = Enum.KeyCode.LeftShift,
        Crouch = Enum.KeyCode.C
    }

    config.Settings = {
        CrouchSpeed = 10,
        SprintSpeed = 25,
        DefaultSpeed = 16,
        CrouchFOV = 55,
        SprintFOV = 85,
        DefaultFOV = 70,
        FOVSmoothing = 10,
        crouchOffset = Vector3.new(0, -2, 0),
        standOffset = Vector3.new(0, 0, 0),
        CrouchOffSetSmoothing = 0.25
    }

return config