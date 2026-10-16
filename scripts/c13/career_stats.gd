extends RefCounted
## C13: read-only aggregates of the last twelve C12 results.
## This does not touch KubeSession, the wallet, or the history JSON.

static func summarize(entries: Array[Dictionary], mode: String = "all") -> Dictionary:
    var result := {
        "games": 0, "wins": 0, "losses": 0, "win_rate": 0,
        "gold": 0, "silver": 0, "bronze": 0,
        "coins": 0, "cubes": 0, "xp": 0, "fevers": 0,
        "best_combo": 0, "best_wave": 0,
        "best_streak": 0, "current_streak": 0
    }
    var streak := 0
    if mode not in ["all", "normal", "daily"]:
        return result
    # C12 stores finished runs oldest-to-newest. Filtering preserves that order.
    for item in entries:
        if mode != "all" and String(item.get("mode", "normal")) != mode:
            continue
        result["games"] += 1
        var won: bool = String(item.get("result", "")) == "victory"
        if won:
            result["wins"] += 1
            streak += 1
            var medal: String = String(item.get("medal", ""))
            if medal in ["gold", "silver", "bronze"]:
                result[medal] += 1
        else:
            result["losses"] += 1
            streak = 0
        result["best_streak"] = maxi(int(result["best_streak"]), streak)
        for key in ["coins", "cubes", "xp", "fevers"]:
            result[key] += maxi(0, int(item.get(key, 0)))
        result["best_combo"] = maxi(int(result["best_combo"]), int(item.get("combo", 0)))
        result["best_wave"] = maxi(int(result["best_wave"]), int(item.get("wave", 0)))
    result["current_streak"] = streak
    if int(result["games"]) > 0:
        result["win_rate"] = roundi(100.0 * float(result["wins"]) / float(result["games"]))
    return result
