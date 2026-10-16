extends SceneTree
const Stats = preload("res://scripts/c13/career_stats.gd")
const History = preload("res://scripts/c12/history_service.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, msg: String) -> void:
    if not ok:
        failures += 1
        push_error("C13 STATS FAIL: " + msg)

func _sample(id: int, mode: String, won: bool, medal: String,
        coins: int, combo: int) -> Dictionary:
    return {
        "run_id": id, "mode": mode, "result": "victory" if won else "defeat",
        "medal": medal, "coins": coins, "cubes": 3, "xp": 5,
        "fevers": 1, "combo": combo, "wave": 5 if won else 3
    }

func _run() -> void:
    var empty: Array[Dictionary] = []
    var blank: Dictionary = Stats.summarize(empty)
    check(blank["games"] == 0 and blank["win_rate"] == 0
        and blank["best_streak"] == 0, "empty career has zero-safe KPIs")
    var entries: Array[Dictionary] = [
        _sample(1, "normal", true, "gold", 100, 5),
        _sample(2, "daily", false, "none", 50, 2),
        _sample(3, "normal", true, "silver", 75, 4),
        _sample(4, "daily", true, "bronze", 25, 3)
    ]
    var original: Array[Dictionary] = entries.duplicate(true)
    var all_stats: Dictionary = Stats.summarize(entries)
    check(all_stats["games"] == 4 and all_stats["wins"] == 3
        and all_stats["losses"] == 1 and all_stats["win_rate"] == 75,
        "wins, losses and percentage computed on bounded sample")
    check(all_stats["gold"] == 1 and all_stats["silver"] == 1
        and all_stats["bronze"] == 1, "medals counted correctly")
    check(all_stats["best_streak"] == 2 and all_stats["current_streak"] == 2,
        "streak resets after defeats")
    check(all_stats["coins"] == 250 and all_stats["cubes"] == 12
        and all_stats["xp"] == 20 and all_stats["fevers"] == 4
        and all_stats["best_combo"] == 5, "only existing run fields summed")
    var normal: Dictionary = Stats.summarize(entries, "normal")
    var daily: Dictionary = Stats.summarize(entries, "daily")
    check(normal["games"] == 2 and normal["win_rate"] == 100
        and normal["best_streak"] == 2 and normal["coins"] == 175,
        "normal filter uses only normal games in original order")
    check(daily["games"] == 2 and daily["win_rate"] == 50
        and daily["best_streak"] == 1 and daily["coins"] == 75,
        "daily filter separates daily records")
    check(Stats.summarize(entries, "unknown")["games"] == 0,
        "invalid filter does not expose unrelated stats")
    check(entries == original, "statistics never mutate history data")
    # Only twelve entries are in the C12 history; this calculator does not claim
    # lifetime totals or change the persisted history schema.
    check(History.MAX_RUNS == 12 and History.VERSION == 1,
        "C13 preserves the C12 storage contract")
    print("KubRogue C13 career stats: %d failures" % failures)
    quit(0 if failures == 0 else 1)
