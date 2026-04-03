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

local ItemService = {}

local ItemUseEvent
if not ReplicatedStorage:FindFirstChild("ItemUseRequest") then
    ItemUseEvent = Instance.new("RemoteFunction")
    ItemUseEvent.Name = "ItemUseRequest"
    ItemUseEvent.Parent = ReplicatedStorage
else
    ItemUseEvent = ReplicatedStorage:FindFirstChild("ItemUseRequest")
end

function ItemService.UseItem(player, instanceId)
    local state = InventoryService.GetInventory(player)
    if not state then return false, "Inventory not loaded" end
    
    local item = state.Items[instanceId]
    if not item then return false, "Item not found in inventory" end
    
    local itemDef = ItemDefinitions.GetItem(item.ItemId)
    
    if itemDef.Type == "Consumable" then
        local success, err = InventoryService.RemoveItemByInstance(player, instanceId, 1)
        if success then
            if itemDef.Stats and itemDef.Stats.Heal then
                local character = player.Character
                if character and character:FindFirstChild("Humanoid") then
                    character.Humanoid.Health = math.min(
                        character.Humanoid.Health + itemDef.Stats.Heal, 
                        character.Humanoid.MaxHealth
                    )
                end
            end
            
            return true, "Successfully used " .. itemDef.Name
        else
            return false, err
        end
    end
    
    return false, "Item is not usable"
end

ItemUseEvent.OnServerInvoke = function(player, instanceId)
    local success, result, msg = pcall(function()
        return ItemService.UseItem(player, instanceId)
    end)
    
    if success then
        return result, msg
    else
        warn("ItemUseError:", result)
        return false, "An unexpected error occurred"
    end
end

return ItemService
