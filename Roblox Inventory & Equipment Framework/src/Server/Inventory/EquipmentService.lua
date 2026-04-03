local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedInv
if ReplicatedStorage:FindFirstChild("Shared") then
    SharedInv = ReplicatedStorage.Shared.Inventory
else
    SharedInv = script.Parent.Parent.Parent.Shared.Inventory
end

local ItemDefinitions = require(SharedInv.ItemDefinitions)
local InventoryService = require(script.Parent.InventoryService)
local InventoryValidator = require(script.Parent.InventoryValidator)

local EquipmentService = {}

local EquipmentEvent
if not ReplicatedStorage:FindFirstChild("EquipmentRequest") then
    EquipmentEvent = Instance.new("RemoteFunction")
    EquipmentEvent.Name = "EquipmentRequest"
    EquipmentEvent.Parent = ReplicatedStorage
else
    EquipmentEvent = ReplicatedStorage:FindFirstChild("EquipmentRequest")
end

function EquipmentService.EquipItem(player, instanceId)
    local state = InventoryService.GetInventory(player)
    if not state then return false, "Inventory not loaded" end
    
    local canEquip, reason = InventoryValidator.CanEquipItem(state, instanceId)
    if not canEquip then return false, reason end
    
    local item = state.Items[instanceId]
    local itemDef = ItemDefinitions.GetItem(item.ItemId)
    local slot = itemDef.EquipSlot
    
    if state.Equipment[slot] then
        EquipmentService.UnequipSlot(player, slot, false)
    end
    
    state.Equipment[slot] = instanceId
    
    InventoryService.SyncToClient(player)
    return true
end

function EquipmentService.UnequipSlot(player, slot, skipSync)
    local state = InventoryService.GetInventory(player)
    if not state then return false, "Inventory not loaded" end
    
    local canUnequip, reason = InventoryValidator.CanUnequipSlot(state, slot)
    if not canUnequip then return true end

    state.Equipment[slot] = nil
    
    if not skipSync then
        InventoryService.SyncToClient(player)
    end
    
    return true
end

EquipmentEvent.OnServerInvoke = function(player, action, arg)
    if action == "Equip" then
        return EquipmentService.EquipItem(player, arg)
    elseif action == "Unequip" then
        return EquipmentService.UnequipSlot(player, arg)
    end
    return false, "Invalid action"
end

return EquipmentService
