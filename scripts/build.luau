local roblox = require("@lune/roblox")
local fs = require("@lune/fs")
local process = require("@lune/process")

----------------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------------

-- Place you edit in Studio (contains real terrain, map assets, etc.)
local SOURCE_PLACE_PATH = "build.rbxl"

-- Rojo project and build outputs
local ROJO_PROJECT = "default.project.json"
local ROJO_OUTPUT_PLACE = "build.rojo.rbxl"  -- intermediate
local FINAL_BUILD_PLACE = "build.rbxl"       -- final output

-- Asset/model paths used by Rojo
local WORKSPACE_MODEL_PATH = "./src/assets/workspace/Workspace.rbxm"
local LIGHTING_MODEL_PATH  = "./src/assets/lighting/Lighting.rbxm"

-- Terrain snapshot (versioned file in git)
local TERRAIN_PLACE_PATH   = "./src/assets/workspace/Terrain.rbxlx"

----------------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------------

-- Export all non-Terrain children of a parent into a single Folder model
local function serializeChildrenAsModelFile(path, parent)
    local container = roblox.Instance.new("Folder")
    container.Name = parent.Name

    for _, child in ipairs(parent:GetChildren()) do
        -- Skip Terrain so Rojo never sees it as a model
        if child.ClassName ~= "Terrain" then
            local clone = child:Clone()
            clone.Parent = container
        end
    end

    local bytes = roblox.serializeModel({ container })
    fs.writeFile(path, bytes)
end

-- Export Terrain as a tiny place file (Workspace + Terrain only)
local function serializeTerrainPlaceFile(path, game)
    local srcWorkspace = game:GetService("Workspace")
    local srcTerrain = srcWorkspace:FindFirstChildOfClass("Terrain")
    if not srcTerrain then
        -- No terrain present; nothing to export
        return
    end

    -- Minimal DataModel for terrain snapshot
    local terrainGame = roblox.Instance.new("DataModel")

    local ws = roblox.Instance.new("Workspace")
    ws.Name = "Workspace"
    ws.Parent = terrainGame

    local terrainClone = srcTerrain:Clone()
    terrainClone.Parent = ws

    -- XML=true so diffs are textual in git
    local terrainPlaceXml = roblox.serializePlace(terrainGame, true)
    fs.writeFile(path, terrainPlaceXml)
end

-- Inject Terrain from TERRAIN_PLACE_PATH into the built place
local function injectTerrainIntoBuild(buildGame)
    -- If we have no terrain snapshot, do nothing
    if not fs.isFile(TERRAIN_PLACE_PATH) then
        return
    end

    local terrainBytes = fs.readFile(TERRAIN_PLACE_PATH)
    local terrainGame = roblox.deserializePlace(terrainBytes)

    local terrainWorkspace = terrainGame:GetService("Workspace")
    local terrain = terrainWorkspace:FindFirstChildOfClass("Terrain")
    if not terrain then
        return
    end

    local buildWorkspace = buildGame:GetService("Workspace")

    -- Remove any Terrain the Rojo-built place might already have
    local oldTerrain = buildWorkspace:FindFirstChildOfClass("Terrain")
    if oldTerrain then
        oldTerrain:Destroy()
    end

    -- Inject cloned Terrain into the built place
    local terrainClone = terrain:Clone()
    terrainClone.Parent = buildWorkspace
end

----------------------------------------------------------------------
-- MAIN PIPELINE
----------------------------------------------------------------------

-- 1) Read source place and export assets (Workspace, Lighting, Terrain)
do
    local srcBytes = fs.readFile(SOURCE_PLACE_PATH)
    local srcGame = roblox.deserializePlace(srcBytes)

    serializeChildrenAsModelFile(WORKSPACE_MODEL_PATH, srcGame.Workspace)
    serializeChildrenAsModelFile(LIGHTING_MODEL_PATH,  srcGame.Lighting)
    serializeTerrainPlaceFile(TERRAIN_PLACE_PATH,      srcGame)
end

-- 2) Run `rojo build` to assemble the game from code + models
do
    local result = process.exec("rojo", {
        "build",
        ROJO_PROJECT,
        "-o",
        ROJO_OUTPUT_PLACE,
    })

    if not result.ok then
        error("rojo build failed:\n" .. result.stderr)
    end
end

-- 3) Load the Rojo-built place and inject Terrain
local buildBytes = fs.readFile(ROJO_OUTPUT_PLACE)
local buildGame  = roblox.deserializePlace(buildBytes)

injectTerrainIntoBuild(buildGame)

-- 4) Write final build place
local finalBytes = roblox.serializePlace(buildGame)
fs.writeFile(FINAL_BUILD_PLACE, finalBytes)
