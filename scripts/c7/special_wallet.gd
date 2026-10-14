extends "res://scripts/c2/run_wallet.gd"
## C7: two new payout tiers without changing the established C2/C3 values.
const EXTRA_REWARDS := {
    "golden": {"coins": 32, "xp": 2},
    "armored": {"coins": 30, "xp": 3}
}

func award(cube_id: int, kind: String, bonus_fraction: float = 0.0) -> Dictionary:
    if not EXTRA_REWARDS.has(kind):
        return super.award(cube_id, kind, bonus_fraction)
    if cube_id < 0 or awarded_ids.has(cube_id):
        return {}
    var item: Dictionary = EXTRA_REWARDS[kind]
    var total_coins := int(floor(float(item["coins"]) * (1.0 + clampf(bonus_fraction, 0.0, 1.5))))
    awarded_ids[cube_id] = true
    coins += total_coins
    xp += int(item["xp"])
    solved += 1
    return {"coins": total_coins, "xp": int(item["xp"])}
