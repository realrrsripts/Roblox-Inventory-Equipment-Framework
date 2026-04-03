local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SharedInv
if ReplicatedStorage:FindFirstChild("Shared") then
    SharedInv = ReplicatedStorage.Shared.Inventory
else
    SharedInv = script.Parent.Parent.Parent.Shared.Inventory
end

local ItemDefinitions = require(SharedInv.ItemDefinitions)
local InventoryUtils = require(SharedInv.InventoryUtils)
local InventoryValidator = require(script.Parent.InventoryValidator)

local InventoryService = {}
local playerStates = {}

local InventoryUpdateEvent
if not ReplicatedStorage:FindFirstChild("InventoryUpdate") then
    InventoryUpdateEvent = Instance.new("RemoteEvent")
    InventoryUpdateEvent.Name = "InventoryUpdate"
    InventoryUpdateEvent.Parent = ReplicatedStorage
else
    InventoryUpdateEvent = ReplicatedStorage:FindFirstChild("InventoryUpdate")
end

function InventoryService.InitializePlayer(player)
    playerStates[player] = {
        MaxCapacity = 30,
        Items = {},
        Equipment = {}
    }
    InventoryService.SyncToClient(player)
end

function InventoryService.CleanupPlayer(player)
    playerStates[player] = nil
end

function InventoryService.GetInventory(player)
    return playerStates[player]
end

function InventoryService.SyncToClient(player)
    local state = playerStates[player]
    if state then
        InventoryUpdateEvent:FireClient(player, state)
    end
end

function InventoryService.AddItem(player, itemId, amount)
    amount = amount or 1
    local state = playerStates[player]
    if not state then return false, "inventory_missing" end
    
    local canAdd, reason = InventoryValidator.CanAddItem(state, itemId, amount)
    if not canAdd then 
        warn("Failed to add Item:", reason)
        return false, reason 
    end
    
    local itemDef = ItemDefinitions.GetItem(itemId)
    local remaining = amount
    
    if itemDef.MaxStack > 1 then
        for _, item in pairs(state.Items) do
            if item.ItemId == itemId and item.Amount < itemDef.MaxStack then
                local space = itemDef.MaxStack - item.Amount
                local toAdd = math.min(space, remaining)
                item.Amount += toAdd
                remaining -= toAdd
                
                if remaining <= 0 then break end
            end
        end
    end
    
    while remaining > 0 do
        local toAdd = math.min(remaining, itemDef.MaxStack)
        local newInstanceId = InventoryUtils.GenerateInstanceId()
        state.Items[newInstanceId] = {
            InstanceId = newInstanceId,
            ItemId = itemId,
            Amount = toAdd
        }
        remaining -= toAdd
    end
    
    InventoryService.SyncToClient(player)
    return true
end

function InventoryService.RemoveItemByInstance(player, instanceId, amount)
    amount = amount or 1
    local state = playerStates[player]
    if not state then return false, "inventory_missing" end
    
    local canRemove, reason = InventoryValidator.CanRemoveItem(state, instanceId, amount)
    if not canRemove then return false, reason end
    
    local item = state.Items[instanceId]
    item.Amount -= amount
    
    if item.Amount <= 0 then
        for slot, equippedId in pairs(state.Equipment) do
            if equippedId == instanceId then
                state.Equipment[slot] = nil
            end
        end
        state.Items[instanceId] = nil
    end
    
    InventoryService.SyncToClient(player)
    return true
end

Players.PlayerAdded:Connect(InventoryService.InitializePlayer)
Players.PlayerRemoving:Connect(InventoryService.CleanupPlayer)

return InventoryService
