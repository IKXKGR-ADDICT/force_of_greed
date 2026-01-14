local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Services = ReplicatedStorage:WaitForChild("Services")
local ItemService = Services:WaitForChild("ItemService")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local InventoryUpdate = Remotes:WaitForChild("InventoryUpdate")
local RequestDrop = Remotes:WaitForChild("RequestDrop")
local RequestEquip = Remotes:WaitForChild("RequestEquip")
local RequestUse = Remotes:WaitForChild("RequestUse")

local ItemDefs = require(ItemService:WaitForChild("ItemDefined"))

local gui = playerGui:WaitForChild("Services"):WaitForChild("InventoryService"):WaitForChild("Inventory")

local invFrame = gui:WaitForChild("Inventory")
local slot1 = invFrame:WaitForChild("Slot1")
local slot2 = invFrame:WaitForChild("Slot2")

local icon1 = slot1:WaitForChild("Icon1")
local icon2 = slot2:WaitForChild("Icon2")

local selectedSlot = 0
local slots = { nil, nil }

local LINGER_SECONDS = 8
local hideToken = 0

local function toAssetId(iconValue)
	if typeof(iconValue) ~= "string" then
		return ""
	end
	if iconValue == "" then
		return ""
	end
	if iconValue:find("rbxassetid://", 1, true) then
		return iconValue
	end
	return "rbxassetid://" .. iconValue
end

local function getIconForType(itemType: string)
	local def = ItemDefs[itemType]
	if type(def) ~= "table" then
		return ""
	end
	return toAssetId(def.icon or "")
end

local function inventoryEmpty()
	return slots[1] == nil and slots[2] == nil
end

local function getBigItemSlot()
	for i = 1, 2 do
		if slots[i] and tonumber(slots[i].size) == 2 then
			return i
		end
	end
	return nil
end

local function scheduleHideIfStillIdle()
	hideToken += 1
	local my = hideToken
	task.delay(LINGER_SECONDS, function()
		if hideToken ~= my then
			return
		end
		if inventoryEmpty() or selectedSlot == 0 then
			gui.Enabled = false
		end
	end)
end

local function setSlotVisual(slotFrame, iconLabel, slotIndex, isVisible)
	slotFrame.Visible = isVisible
	if not isVisible then
		iconLabel.Visible = false
		return
	end

	local s = slots[slotIndex]
	iconLabel.Image = (s and s.icon) or ""
	iconLabel.Visible = (s and s.icon and s.icon ~= "") or false

	slotFrame.BackgroundTransparency = (selectedSlot == slotIndex) and 0 or 0.25
end

local function render()
	if inventoryEmpty() then
		gui.Enabled = true
		setSlotVisual(slot1, icon1, 1, false)
		setSlotVisual(slot2, icon2, 2, false)
		scheduleHideIfStillIdle()
		return
	end

	gui.Enabled = true

	local bigSlot = getBigItemSlot()
	local show1, show2

	if bigSlot then
		show1 = (bigSlot == 1)
		show2 = (bigSlot == 2)
	else
		show1 = (slots[1] ~= nil)
		show2 = (slots[2] ~= nil)
	end

	setSlotVisual(slot1, icon1, 1, show1)
	setSlotVisual(slot2, icon2, 2, show2)

	if selectedSlot == 0 then
		scheduleHideIfStillIdle()
	else
		hideToken += 1
	end
end

local function setSelected(i)
	i = (i == 2) and 2 or 1

	-- Toggle off if same pressed again
	if selectedSlot == i then
		selectedSlot = 0
		RequestEquip:FireServer(0)
		render()
		return
	end

	local bigSlot = getBigItemSlot()
	if bigSlot and i ~= bigSlot then
		return
	end

	if not slots[i] then
		return
	end

	selectedSlot = i
	RequestEquip:FireServer(selectedSlot)
	render()
end

InventoryUpdate.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" or typeof(payload.slots) ~= "table" then
		return
	end

	for i = 1, 2 do
		local s = payload.slots[i]
		if s and typeof(s.type) == "string" then
			slots[i] = {
				type = s.type,
				size = s.size,
				icon = getIconForType(s.type),
			}
		else
			slots[i] = nil
		end
	end

	-- If selection became invalid, deselect + server unequip
	local bigSlot = getBigItemSlot()
	if selectedSlot ~= 0 then
		if not slots[selectedSlot] then
			selectedSlot = 0
			RequestEquip:FireServer(0)
		elseif bigSlot and selectedSlot ~= bigSlot then
			selectedSlot = 0
			RequestEquip:FireServer(0)
		end
	end

	render()
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.One then
		setSelected(1)
	elseif input.KeyCode == Enum.KeyCode.Two then
		setSelected(2)
	elseif input.KeyCode == Enum.KeyCode.Q then
		if selectedSlot ~= 0 then
			RequestDrop:FireServer(selectedSlot)
		end
	elseif input.KeyCode == Enum.KeyCode.F then
		if selectedSlot ~= 0 and slots[selectedSlot] then
			RequestUse:FireServer(selectedSlot)
		end
	end
end)

gui.Enabled = false
render()
