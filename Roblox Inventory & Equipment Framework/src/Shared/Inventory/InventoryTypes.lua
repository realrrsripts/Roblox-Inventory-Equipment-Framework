export type ItemType = "Weapon" | "Consumable" | "Material" | "Armor" | "Accessory"

export type ItemDefinition = {
    Id: string,
    Name: string,
    Type: ItemType,
    MaxStack: number,
    EquipSlot: string?,
    Stats: {[string]: number}?
}

export type InventoryItem = {
    InstanceId: string,
    ItemId: string,
    Amount: number
}

export type InventoryState = {
    MaxCapacity: number,
    Items: {[string]: InventoryItem},
    Equipment: {[string]: string}
}

return {}
