local roblox = require("@lune/roblox")
local fs = require("@lune/fs")

local content = fs.readFile("baseplate.rbxl")
local game = roblox.deserializePlace(content)


--fs.writeFile("./src/workspace/Terrain.rbxm", roblox.serializeModel({game.Workspace.Terrain}))
fs.writeFile("./src/workspace/Assets/SpawnLocation.rbxm", roblox.serializeModel({game.Workspace.SpawnLocation}))
fs.writeFile("./src/workspace/Assets/Baseplate.rbxm", roblox.serializeModel({game.Workspace.Baseplate}))

fs.writeFile("./src/lighting/Atmosphere.rbxm", roblox.serializeModel({game.Lighting.Atmosphere}))
fs.writeFile("./src/lighting/Sky.rbxm", roblox.serializeModel({game.Lighting.Sky}))
fs.writeFile("./src/lighting/Bloom.rbxm", roblox.serializeModel({game.Lighting.Bloom}))
fs.writeFile("./src/lighting/DepthOfField.rbxm", roblox.serializeModel({game.Lighting.DepthOfField}))
fs.writeFile("./src/lighting/SunRays.rbxm", roblox.serializeModel({game.Lighting.SunRays}))