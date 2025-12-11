local roblox = require("@lune/roblox")
local fs = require("@lune/fs")

local function serializeChildrenAsModelFile(path, parent)
    -- Create a container folder
    local container = roblox.Instance.new("Folder")
    container.Name = parent.Name

    -- Move children into container
    for _, child in ipairs(parent:GetChildren()) do
        if child.ClassName ~= "Terrain" then
            local clone = child:Clone()
            clone.Parent = container
        end
    end

    -- Serialize the container as the one allowed top-level instance
    local bytes = roblox.serializeModel({container})
    fs.writeFile(path, bytes)
end

local function modSerializeChildrenAsModelFile(path, parent)
    -- Create a container folder
    local container = roblox.Instance.new("Folder")
    container.Name = parent.Name

    -- Move children into container
    for _, child in ipairs(parent:GetChildren()) do
        child.Parent = container
    end

    -- Serialize the container as the one allowed top-level instance
    local bytes = roblox.serializeModel({container})
    fs.writeFile(path, bytes)
end

local content = fs.readFile("build.rbxl")
local game = roblox.deserializePlace(content)

serializeChildrenAsModelFile("./src/assets/workspace/Workspace.rbxm", game.Workspace)
serializeChildrenAsModelFile("./src/assets/lighting/Lighting.rbxm", game.Lighting)
modSerializeChildrenAsModelFile("./src/assets/workspace/Terrain.rbxm", game.Workspace.Terrain)