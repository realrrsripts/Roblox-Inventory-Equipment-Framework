local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryController = {}
local currentInventoryState = nil
local StateChangedBindable = Instance.new("BindableEvent")

InventoryController.OnStateChanged = StateChangedBindable.Event

local InventoryUpdateEvent = ReplicatedStorage:WaitForChild("InventoryUpdate", 5)
local ItemUseEvent = ReplicatedStorage:WaitForChild("ItemUseRequest", 5)
local EquipmentEvent = ReplicatedStorage:WaitForChild("EquipmentRequest", 5)

function InventoryController.Initialize()
    if InventoryUpdateEvent then
        InventoryUpdateEvent.OnClientEvent:Connect(function(newState)
            currentInventoryState = newState
            StateChangedBindable:Fire(newState)
        end)
    else
        warn("InventoryUpdateEvent missing from ReplicatedStorage.")
    end
end

function InventoryController.GetState()
    return currentInventoryState
end

function InventoryController.RequestUseItem(instanceId)
    if not ItemUseEvent then return false, "Network not ready" end
    return ItemUseEvent:InvokeServer(instanceId)
end

function InventoryController.RequestEquipItem(instanceId)
    if not EquipmentEvent then return false, "Network not ready" end
    return EquipmentEvent:InvokeServer("Equip", instanceId)
end

function InventoryController.RequestUnequipSlot(slot)
    if not EquipmentEvent then return false, "Network not ready" end
    return EquipmentEvent:InvokeServer("Unequip", slot)
end

return InventoryController
