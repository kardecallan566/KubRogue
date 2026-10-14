extends SceneTree
const Challenge = preload("res://scripts/c6/challenge_service.gd")
const Build = preload("res://scripts/c6/run_build.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, detail: String) -> void:
    if not ok:
        failures += 1
        push_error("C6 UNIT FAIL: " + detail)

func _clean(path: String) -> void:
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))

func _run() -> void:
    var path := "user://c6_daily_unit.json"
    _clean(path)
    var service: Challenge = Challenge.new()
    service.configure(Store.new(path))
    check(service.daily_seed("2026-10-13") == service.daily_seed("2026-10-13"),
        "daily seed stable")
    check(service.daily_seed("2026-10-14") != service.daily_seed("2026-10-13"),
        "different days have different seeds")
    check(not service.valid_day("2026-13-13") and not service.valid_day("xxxx-xx-xx"),
        "reject malformed day")
    check(service.select_mode("daily", "2026-10-13"), "daily mode selected")
    var seed := service.begin_run()
    check(seed == service.daily_seed("2026-10-13"), "daily run gets fixed seed")
    check(service.record_result(3, 13, false), "record first daily attempt")
    check(not service.record_result(5, 50, true), "same run cannot submit twice")
    check(service.record_for("2026-10-13")["attempts"] == 1, "single attempt")
    check(service.begin_run() == seed, "new daily attempt gets same seed")
    check(service.record_result(5, 26, true), "record improved victory")
    var record := service.record_for("2026-10-13")
    check(record["wins"] == 1 and record["attempts"] == 2, "accurate win and attempts")
    check(record["best_wave"] == 5 and record["best_cubes"] == 26, "best results kept")
    check(service.begin_run() == seed, "another attempt uses same daily seed")
    check(service.record_result(2, 5, false), "weaker attempt recorded")
    record = service.record_for("2026-10-13")
    check(record["best_wave"] == 5 and record["best_cubes"] == 26, "weaker attempt doesn't downgrade best")
    var restored: Challenge = Challenge.new()
    restored.configure(Store.new(path))
    check(restored.record_for("2026-10-13")["attempts"] == 3, "reload preserves attempts")
    check(restored.record_for("2026-10-13")["wins"] == 1, "reload preserves victories")
    check(restored.select_mode("daily", "2026-10-13"), "same challenge after reload")
    check(restored.begin_run() == seed, "same seed after restart")
    check(restored.select_mode("normal"), "normal mode still available")
    check(restored.active_mode == "normal" and restored.active_date.is_empty(), "mode isolation")
    check(not restored.select_mode("bad-mode"), "invalid modes rejected")

    var first: Build = Build.new()
    var second: Build = Build.new()
    first.reset(seed)
    second.reset(seed)
    first.register_xp(5)
    second.register_xp(5)
    var initial: Array[String] = first.roll_offer()
    check(initial == second.roll_offer() and initial.size() == 3, "deterministic card choices")
    check(first.reroll_offer() and second.reroll_offer(), "both rerolls succeed")
    check(first.current_offer == second.current_offer, "rerolls deterministic under same seed")
    for id in initial:
        check(not first.current_offer.has(id), "fresh card choices exclude previous when possible")
    check(first.pending == 1 and first.offers_taken == 0, "reroll doesn't spend XP or a choice")
    check(first.rerolls_remaining == 0 and not first.reroll_offer(), "only one reroll per run")
    check(first.select_card(first.current_offer[0]) and first.pending == 0, "card selection after reroll")
    first.reset(seed)
    check(first.rerolls_remaining == 1, "new run refreshes reroll")
    service.free()
    restored.free()
    _clean(path)
    print("KubRogue C6 daily/reroll unit tests: %d failures" % failures)
    quit(0 if failures == 0 else 1)
