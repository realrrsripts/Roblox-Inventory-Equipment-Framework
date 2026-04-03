local InventoryController = require(script.Parent.InventoryController)

local UIController = {}

local function getOccupiedSlots(items)
    local count = 0
    for _ in pairs(items or {}) do count += 1 end
    return count
end

function UIController.Initialize(guiContainer)
    UIController.Container = guiContainer
    
    InventoryController.OnStateChanged:Connect(function(newState)
        UIController.Render(newState)
    end)
end

function UIController.Render(state)
    print("[UI UPDATE - Syncing with Server Reality]")
    print(string.format("Storage Space: %d/%d slots occupied", getOccupiedSlots(state.Items), state.MaxCapacity))
    
    print("--- INVENTORY ITEMS ---")
    for instanceId, item in pairs(state.Items) do
        print(string.format(" * [%s]: %s (x%d)", instanceId, item.ItemId, item.Amount))
    end
    
    print("--- EQUIPPED ITEMS ---")
    local equippedCount = 0
    for slot, instanceId in pairs(state.Equipment) do
        print(string.format(" > %s: %s", slot, instanceId))
        equippedCount += 1
    end
    
    if equippedCount == 0 then
        print(" > (No equipment worn)")
    end
    print("-----------------------------------------")
end

return UIController
