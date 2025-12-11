local roblox = require("@lune/roblox")
local fs = require("@lune/fs")

local content = fs.readFile("build.rbxl")
local game = roblox.deserializePlace(content)

fs.writeFile("./src/assets/workspace/Assets.rbxm", roblox.serializeModel({game.Workspace.Assets}))
fs.writeFile("./src/assets/lighting/Bloom.rbxm", roblox.serializeModel({game.Lighting.Bloom}))
fs.writeFile("./src/assets/lighting/ColorGrading.rbxm", roblox.serializeModel({game.Lighting.ColorGrading}))
fs.writeFile("./src/assets/workspace/Terrain.rbxm", roblox.serializeModel({game.Workspace.Terrain}))