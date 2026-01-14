local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Services = ReplicatedStorage:WaitForChild("Services")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local RequestEquip = Remotes:WaitForChild("RequestEquip")
local RequestDrop = Remotes:WaitForChild("RequestDrop")
local RequestUse = Remotes:WaitForChild("RequestUse")
local InventoryUpdate = Remotes:WaitForChild("InventoryUpdate")

local ItemDefs = require(Services:WaitForChild("ItemService"):WaitForChild("ItemDefined"))
-- CONFIG
local CAPACITY = 2
local MAX_PICKUP_DISTANCE = 10
local PICKUP_HOLD_DURATION = 0.5
local USE_DURATION = 2 -- seconds

-- inv = { slots = { [1]=record or nil, [2]=record or nil }, tools = { [1]=Tool or nil, [2]=Tool or nil } }
local Inventories = {}
local Using = {} -- Using[player] = true while using

local function newInventory()
	return { slots = { nil, nil }, tools = { nil, nil } }
end

local function getRootPart(character)
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function withinDistance(player, part)
	local char = player.Character
	local hrp = getRootPart(char)
	if not hrp or not part then
		return false
	end
	return (hrp.Position - part.Position).Magnitude <= MAX_PICKUP_DISTANCE
end

local function getHandle(tool)
	local h = tool:FindFirstChild("Handle")
	if h and h:IsA("BasePart") then
		return h
	end
	return nil
end

local function stripTouchPickup(handle)
	local ti = handle and handle:FindFirstChild("TouchInterest")
	if ti then
		ti:Destroy()
	end
end

local function ensurePrompt(tool)
	local handle = getHandle(tool)
	if not handle then
		return nil
	end

	stripTouchPickup(handle)

	local prompt = handle:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.Parent = handle
	end

	prompt.Enabled = true
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = PICKUP_HOLD_DURATION
	prompt.MaxActivationDistance = MAX_PICKUP_DISTANCE
	prompt.RequiresLineOfSight = false
	prompt.ActionText = "Pick up"

	return prompt, handle
end

local function destroyPrompt(tool)
	local handle = getHandle(tool)
	if not handle then
		return
	end
	local prompt = handle:FindFirstChildOfClass("ProximityPrompt")
	if prompt then
		prompt:Destroy()
	end
end

local function usedCapacity(inv)
	local used = 0
	for i = 1, 2 do
		local it = inv.slots[i]
		if it then
			used += (it.size or 1)
		end
	end
	return used
end

local function canAdd(inv, size)
	return usedCapacity(inv) + size <= CAPACITY
end

local function clearInventory(inv)
	inv.slots[1], inv.slots[2] = nil, nil
	inv.tools[1], inv.tools[2] = nil, nil
end

local function compactInventory(inv)
	-- If slot1 empty but slot2 has size-1 item, move it to slot1
	if inv.slots[1] == nil and inv.slots[2] ~= nil then
		-- only compact if slot2 is size 1 (size 2 should never exist only in slot2)
		if tonumber(inv.slots[2].size) == 1 then
			inv.slots[1] = inv.slots[2]
			inv.tools[1] = inv.tools[2]
			inv.slots[2] = nil
			inv.tools[2] = nil
		end
	end
end

local function sendInventory(player)
	local inv = Inventories[player]
	if not inv then
		return
	end

	InventoryUpdate:FireClient(player, {
		slots = {
			inv.slots[1] and { type = inv.slots[1].type, size = inv.slots[1].size } or nil,
			inv.slots[2] and { type = inv.slots[2].type, size = inv.slots[2].size } or nil,
		},
	})
end

-- Returns filled slots table or nil
local function addItem(inv, itemType, tool)
	local def = ItemDefs[itemType]
	if not def then
		return nil
	end

	local size = tonumber(def.size) or 1
	if not canAdd(inv, size) then
		return nil
	end

	-- Size 2 consumes the whole inventory (mirror slot2 for UI logic)
	if size == 2 then
		if inv.slots[1] or inv.slots[2] then
			return nil
		end
		inv.slots[1] = { type = itemType, size = 2 }
		inv.slots[2] = { type = itemType, size = 2 }
		inv.tools[1] = tool
		inv.tools[2] = tool
		return { 1, 2 }
	end

	-- Size 1 fills first empty slot
	if not inv.slots[1] then
		inv.slots[1] = { type = itemType, size = 1 }
		inv.tools[1] = tool
		return { 1 }
	elseif not inv.slots[2] then
		inv.slots[2] = { type = itemType, size = 1 }
		inv.tools[2] = tool
		return { 2 }
	end

	return nil
end

local function removeFromSlot(inv, slotIndex)
	local it = inv.slots[slotIndex]
	local tool = inv.tools[slotIndex]
	if not it then
		return nil, nil
	end

	-- Size 2 item clears both slots
	if tonumber(it.size) == 2 then
		local removedItem = inv.slots[1]
		local removedTool = inv.tools[1]
		clearInventory(inv)
		return removedItem, removedTool
	end

	inv.slots[slotIndex] = nil
	inv.tools[slotIndex] = nil
	compactInventory(inv)
	return it, tool
end

local function setupWorldPickup(tool)
	local itemType = tool:GetAttribute("ItemType")
	if typeof(itemType) ~= "string" or not ItemDefs[itemType] then
		return
	end

	local prompt, handle = ensurePrompt(tool)
	if not prompt or not handle then
		return
	end

	prompt.ObjectText = ItemDefs[itemType].displayName or itemType

	if prompt:GetAttribute("InventoryHooked") then
		return
	end
	prompt:SetAttribute("InventoryHooked", true)

	prompt.Triggered:Connect(function(player)
		local inv = Inventories[player]
		if not inv then
			return
		end
		if not withinDistance(player, handle) then
			return
		end

		local filled = addItem(inv, itemType, tool)
		if not filled then
			return
		end

		local backpack = player:FindFirstChildOfClass("Backpack")
		if not backpack then
			return
		end

		-- Put tool into real Roblox inventory
		tool.CanBeDropped = false
		destroyPrompt(tool)
		tool.Parent = backpack

		sendInventory(player)
	end)
end

local function scanWorkspaceTools()
	for _, inst in ipairs(workspace:GetDescendants()) do
		if inst:IsA("Tool") then
			local itemType = inst:GetAttribute("ItemType")
			if typeof(itemType) == "string" and ItemDefs[itemType] then
				local ownerPlayer = Players:GetPlayerFromCharacter(inst.Parent)
				if not ownerPlayer then
					setupWorldPickup(inst)
				end
			end
		end
	end
end

workspace.DescendantAdded:Connect(function(inst)
	if not inst:IsA("Tool") then
		return
	end
	task.defer(function()
		local itemType = inst:GetAttribute("ItemType")
		if typeof(itemType) ~= "string" or not ItemDefs[itemType] then
			return
		end
		local ownerPlayer = Players:GetPlayerFromCharacter(inst.Parent)
		if ownerPlayer then
			return
		end
		setupWorldPickup(inst)
	end)
end)

-- EQUIP (slotIndex: 1/2, or 0 to unequip)
RequestEquip.OnServerEvent:Connect(function(player, slotIndex)
	if typeof(slotIndex) ~= "number" then
		return
	end
	if slotIndex ~= 0 and slotIndex ~= 1 and slotIndex ~= 2 then
		return
	end

	local char = player.Character
	if not char then
		return
	end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	if slotIndex == 0 then
		humanoid:UnequipTools()
		return
	end

	local inv = Inventories[player]
	if not inv then
		return
	end

	local tool = inv.tools[slotIndex]
	if not tool or not tool:IsA("Tool") then
		return
	end

	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack and tool.Parent ~= backpack and tool.Parent ~= char then
		tool.Parent = backpack
	end

	humanoid:EquipTool(tool)
end)

-- DROP
RequestDrop.OnServerEvent:Connect(function(player, slotIndex)
	if typeof(slotIndex) ~= "number" then
		return
	end
	if slotIndex ~= 1 and slotIndex ~= 2 then
		return
	end

	local inv = Inventories[player]
	if not inv then
		return
	end

	local removedItem, tool = removeFromSlot(inv, slotIndex)
	if not removedItem or not tool then
		return
	end

	local char = player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = getRootPart(char)
	if humanoid then
		humanoid:UnequipTools()
	end
	if not hrp then
		return
	end

	tool.Parent = workspace
	tool.CanBeDropped = false

	local handle = getHandle(tool)
	if handle then
		handle.CFrame = CFrame.new(hrp.Position + (hrp.CFrame.LookVector * 4) + Vector3.new(0, 1, 0))
	end

	setupWorldPickup(tool)
	sendInventory(player)
end)

-- USE (8 seconds, then heal, then remove item)
RequestUse.OnServerEvent:Connect(function(player, slotIndex)
	if typeof(slotIndex) ~= "number" then
		return
	end
	if slotIndex ~= 1 and slotIndex ~= 2 then
		return
	end
	if Using[player] then
		return
	end

	local inv = Inventories[player]
	if not inv then
		return
	end

	local it = inv.slots[slotIndex]
	local tool = inv.tools[slotIndex]
	if not it or not tool then
		return
	end

	local def = ItemDefs[it.type]
	if type(def) ~= "table" then
		return
	end

	local char = player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	Using[player] = true

	-- Optional: keep equipped while using
	humanoid:EquipTool(tool)

	task.delay(USE_DURATION, function()
		-- player may have left
		if not player.Parent then
			return
		end
		local invNow = Inventories[player]
		if not invNow then
			Using[player] = nil
			return
		end

		-- Validate item still exists in that slot (or slot1 if compacting happened externally)
		local itNow = invNow.slots[slotIndex]
		local toolNow = invNow.tools[slotIndex]
		if not itNow or not toolNow then
			Using[player] = nil
			sendInventory(player)
			return
		end

		local defNow = ItemDefs[itNow.type]
		if type(defNow) == "table" and tonumber(defNow.heal) then
			humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + tonumber(defNow.heal))
		end

		-- Remove from inventory + destroy tool
		removeFromSlot(invNow, slotIndex)
		if toolNow and toolNow.Parent then
			toolNow:Destroy()
		end

		humanoid:UnequipTools()
		Using[player] = nil
		sendInventory(player)
	end)
end)

Players.PlayerAdded:Connect(function(player)
	Inventories[player] = newInventory()
	sendInventory(player)
end)

Players.PlayerRemoving:Connect(function(player)
	Inventories[player] = nil
	Using[player] = nil
end)

scanWorkspaceTools()
