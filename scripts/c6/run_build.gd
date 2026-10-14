extends "res://scripts/c3/run_build.gd"
## One genuine reroll per run; the XP threshold and skill rules do not change.
var rerolls_remaining := 1

func reset(seed_value: int = 2026) -> void:
    super.reset(seed_value)
    rerolls_remaining = 1

func reroll_offer() -> bool:
    if rerolls_remaining <= 0 or pending <= 0 or current_offer.is_empty():
        return false
    var previous: Array[String] = current_offer.duplicate()
    var fresh: Array[String] = []
    for card in CARDS:
        var id: String = card["id"]
        if rank(id) < MAX_RANK and not previous.has(id):
            fresh.append(id)
    if fresh.is_empty():
        return false
    var shuffled: Array[String] = []
    while shuffled.size() < 3 and not fresh.is_empty():
        var idx := rng.randi_range(0, fresh.size() - 1)
        shuffled.append(fresh[idx])
        fresh.remove_at(idx)
    # At high ranks there may be fewer than 3 *new* skills available.
    # Fill remaining slots from previous offer, without duplicates.
    for id in previous:
        if shuffled.size() >= 3:
            break
        if rank(id) < MAX_RANK and not shuffled.has(id):
            shuffled.append(id)
    current_offer = shuffled
    rerolls_remaining -= 1
    return true
