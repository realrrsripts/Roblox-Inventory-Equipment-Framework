local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedInv
if ReplicatedStorage:FindFirstChild("Shared") then
    SharedInv = ReplicatedStorage.Shared.Inventory
else
    SharedInv = script.Parent.Parent.Parent.Shared.Inventory
end
local ItemDefinitions = require(SharedInv.ItemDefinitions)
local InventoryUtils = require(SharedInv.InventoryUtils)

local InventoryValidator = {}

function InventoryValidator.CanAddItem(inventoryState, itemId, amount)
    if type(amount) ~= "number" or amount <= 0 then return false, "Invalid amount" end
    if not ItemDefinitions.IsValidItem(itemId) then return false, "Invalid item ID" end
    
    local itemDef = ItemDefinitions.GetItem(itemId)
    
    if itemDef.MaxStack > 1 then
        local space = 0
        for _, item in pairs(inventoryState.Items) do
            if item.ItemId == itemId then
                space += (itemDef.MaxStack - item.Amount)
            end
        end
        if amount <= space then
            return true
        end
        
        local remaining = amount - space
        local newStacksNeeded = math.ceil(remaining / itemDef.MaxStack)
        
        local freeSlots = inventoryState.MaxCapacity - InventoryUtils.GetOccupiedSlots(inventoryState)
        if freeSlots >= newStacksNeeded then
            return true
        else
            return false, "Inventory full"
        end
    else
        local freeSlots = inventoryState.MaxCapacity - InventoryUtils.GetOccupiedSlots(inventoryState)
        if freeSlots >= amount then
            return true
        else
            return false, "Inventory full"
        end
    end
end

function InventoryValidator.CanRemoveItem(inventoryState, instanceId, amount)
    if type(amount) ~= "number" or amount <= 0 then return false, "Invalid amount" end
    local item = inventoryState.Items[instanceId]
    if not item then return false, "Item instance not found in inventory" end
    
    if item.Amount >= amount then
        return true
    else
        return false, "Not enough items instack"
    end
end

function InventoryValidator.CanEquipItem(inventoryState, instanceId)
    local item = inventoryState.Items[instanceId]
    if not item then return false, "Item instance not found in inventory" end
    
    local itemDef = ItemDefinitions.GetItem(item.ItemId)
    if not itemDef.EquipSlot then return false, "Item lacks an active EquipSlot" end
    
    return true
end

function InventoryValidator.CanUnequipSlot(inventoryState, equipSlot)
    if not inventoryState.Equipment[equipSlot] then return false, "Slot is already empty" end
    return true
end

return InventoryValidator
