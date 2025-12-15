local roblox = require("@lune/roblox")
local fs = require("@lune/fs")

local content = fs.readFile("baseplate.rbxl")
local game = roblox.deserializePlace(content)


--fs.writeFile("./src/workspace/Terrain.rbxm", roblox.serializeModel({game.Workspace.Terrain}))
