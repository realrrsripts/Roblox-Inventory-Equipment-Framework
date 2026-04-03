local ItemDefinitions = require(script.Parent.ItemDefinitions)

local InventoryUtils = {}

function InventoryUtils.GetTotalItemCount(inventoryState, itemId: string): number
    local total = 0
    for _, item in pairs(inventoryState.Items) do
        if item.ItemId == itemId then
            total += item.Amount
        end
    end
    return total
end

function InventoryUtils.GetOccupiedSlots(inventoryState): number
    local count = 0
    for _ in pairs(inventoryState.Items) do
        count += 1
    end
    return count
end

function InventoryUtils.HasAvailableCapacity(inventoryState): boolean
    return InventoryUtils.GetOccupiedSlots(inventoryState) < inventoryState.MaxCapacity
end

local httpService = game:GetService("HttpService")
function InventoryUtils.GenerateInstanceId(): string
    return httpService:GenerateGUID(false)
end

return InventoryUtils
