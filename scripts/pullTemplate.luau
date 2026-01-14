local roblox = require("@lune/roblox")
local fs = require("@lune/fs")

local content = fs.readFile("24.rbxl")
local game = roblox.deserializePlace(content)

--fs.writeFile("./src/workspace/Terrain.rbxm", roblox.serializeModel({game.Workspace.Terrain}))
fs.writeFile(
	"./src/starter_gui/Services/HealthService.rbxm",
	roblox.serializeModel({ game.StarterGui.Services.HealthService })
)
fs.writeFile(
	"./src/starter_gui/Services/InventoryService.rbxm",
	roblox.serializeModel({ game.StarterGui.Services.InventoryService })
)
fs.writeFile(
	"./src/starter_gui/Services/StaminaService.rbxm",
	roblox.serializeModel({ game.StarterGui.Services.StaminaService })
)

fs.writeFile("./src/replicated_storage/Remotes.rbxm", roblox.serializeModel({ game.ReplicatedStorage.Remotes }))
