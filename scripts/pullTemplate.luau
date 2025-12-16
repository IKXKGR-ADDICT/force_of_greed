local roblox = require("@lune/roblox")
local fs = require("@lune/fs")

local content = fs.readFile("build.rbxl")
local game = roblox.deserializePlace(content)

--fs.writeFile("./src/workspace/Terrain.rbxm", roblox.serializeModel({game.Workspace.Terrain}))
fs.writeFile("./src/starter_gui/Health.rbxm", roblox.serializeModel({ game.StarterGui.Health }))
fs.writeFile("./src/starter_gui/Inventory.rbxm", roblox.serializeModel({ game.StarterGui.Inventory }))
