extends RefCounted
class_name KubRogueRunWallet
## In-memory, per-run economy. C4 introduces durable currency via a save service.
## Rewards belong to a confirmed puzzle solution, not to clicks or effects.
const REWARD_TABLE := {
    "apprentice": {"coins": 10, "xp": 1},
    "reinforced": {"coins": 18, "xp": 2}
}
var coins := 0
var xp := 0
var solved := 0
var awarded_ids: Dictionary = {}

func reset() -> void:
    coins = 0
    xp = 0
    solved = 0
    awarded_ids.clear()

func award(cube_id: int, kind: String) -> Dictionary:
    if cube_id < 0 or awarded_ids.has(cube_id) or not REWARD_TABLE.has(kind):
        return {}
    var item: Dictionary = REWARD_TABLE[kind]
    awarded_ids[cube_id] = true
    coins += int(item["coins"])
    xp += int(item["xp"])
    solved += 1
    return {"coins": int(item["coins"]), "xp": int(item["xp"])}
