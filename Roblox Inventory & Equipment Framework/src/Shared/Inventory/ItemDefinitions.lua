local ItemDefinitions = {}

local Items = {
    ["IronSword"] = {
        Id = "IronSword",
        Name = "Iron Sword",
        Type = "Weapon",
        MaxStack = 1,
        EquipSlot = "PrimaryWeapon",
        Stats = { Damage = 15 }
    },
    ["SteelShield"] = {
        Id = "SteelShield",
        Name = "Steel Shield",
        Type = "Armor",
        MaxStack = 1,
        EquipSlot = "SecondaryWeapon",
        Stats = { Defense = 10 }
    },
    ["HealthPotion"] = {
        Id = "HealthPotion",
        Name = "Health Potion",
        Type = "Consumable",
        MaxStack = 99,
        Stats = { Heal = 50 }
    },
    ["Wood"] = {
        Id = "Wood",
        Name = "Wood",
        Type = "Material",
        MaxStack = 999,
    }
}

function ItemDefinitions.GetItem(itemId: string)
    return Items[itemId]
end

function ItemDefinitions.GetAllItems()
    return Items
end

function ItemDefinitions.IsValidItem(itemId: string): boolean
    return Items[itemId] ~= nil
end

return ItemDefinitions
