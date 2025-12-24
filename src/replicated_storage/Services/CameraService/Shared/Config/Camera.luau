local Config = {
    ViewBobbing = {
        Settings = {
            horizontalSpeed = 3,
            verticalSpeed = 3,
            offsetSmoothingTime = 0.75,
            tickMultiplier = 1,
            maxHorizontal = 0.25,
            maxVertical = 0.8,
            rotationFrequency = 1.6,
            invRotationMagnitude = 85
        }
    },
    DynamicFOV = {
        Settings = {
            smoothingTime = 0.25,
            defaultFOV = 70,
            sprintFOV = 85
        }
    },
    CrouchOffset = {
        Settings = {
            smoothingTime = 0.25,
            crouchHeight = -1.7
        }
    }

}

return table.freeze(Config)