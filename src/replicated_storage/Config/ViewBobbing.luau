local config = {}

    config.Settings = {
        Frequency = 6,
        XRange = 4,
        YRange = 1.7,
        RotateFrequency = 1.5,
        MaxRotate = 150,
        IdleDecay = 0.75,
        Smoothing = 0.75
    }

    config.Variables = {
        tickMultiplier = 1,
        upperBound = 2 * math.pi,
        lowerBound = -(2* math.pi)
    }

return table.freeze(config)