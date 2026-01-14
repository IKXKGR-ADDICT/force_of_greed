-- ReplicatedStorage/Shared/ItemDefined (ModuleScript)
-- HOW TO ADD ITEMS:
-- 1) Add a new entry with a UNIQUE key name (this key must match the Tool's ItemType attribute)
-- 2) displayName: what shows on the prompt / UI
-- 3) size: 1 or 2 (capacity cost). Size 2 still stores into ONE slot, but blocks picking up another item.
-- 4) icon: you can use either "1234567890" OR "rbxassetid://1234567890"
-- 5) heal: how much health is restored when used (F)
return {
	Bandage = {
		displayName = "Bandage",
		size = 1,
		icon = "rbxassetid://10315308789",
		heal = 25,
	},

	Medkit = {
		displayName = "Medkit",
		size = 2,
		icon = "rbxassetid://10315308789",
		heal = 75,
	},
}
