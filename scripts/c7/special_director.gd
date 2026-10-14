extends "res://scripts/c3/roguelite_director.gd"
## C7: new cubie variants in waves 2–5, preserving the elite slot in wave 5.
const SpecialWallet = preload("res://scripts/c7/special_wallet.gd")
const SPECIAL_WAVES := {
    1: {1:"golden"},
    2: {2:"armored", 6:"golden"},
    3: {3:"golden", 8:"armored"},
    4: {1:"golden", 5:"armored"}
}
const KIND_INFO := {
    "apprentice": {"label":"Aprendiz", "depth_min":2, "depth_max":4, "coins":10, "xp":1},
    "reinforced": {"label":"Reforçado", "depth_min":5, "depth_max":8, "coins":18, "xp":2},
    "golden": {"label":"Dourado", "depth_min":3, "depth_max":5, "coins":32, "xp":2},
    "armored": {"label":"Blindado", "depth_min":8, "depth_max":11, "coins":30, "xp":3},
    "elite": {"label":"Elite 3×3", "depth_min":6, "depth_max":12, "coins":80, "xp":6}
}

func _init(upgrades = null) -> void:
    super._init(upgrades)
    wallet = SpecialWallet.new()
    waves = C3_WAVES.duplicate(true)
    for wave_id in SPECIAL_WAVES:
        var definition: Dictionary = waves[int(wave_id)]
        var kinds: Array = definition["types"]
        var positions: Dictionary = SPECIAL_WAVES[wave_id]
        for slot in positions:
            kinds[int(slot)] = String(positions[slot])

func variant_info(kind: String) -> Dictionary:
    return KIND_INFO.get(kind, KIND_INFO["apprentice"]).duplicate(true)

func scramble_depth(kind: String, actor_id: int, reduction: int = 0) -> int:
    var info: Dictionary = variant_info(kind)
    var lower: int = int(info["depth_min"])
    var upper: int = int(info["depth_max"])
    var span := upper - lower + 1
    var turns := lower + (actor_id % span)
    if kind == "reinforced" or kind == "armored":
        return maxi(2, turns - reduction)
    return turns
