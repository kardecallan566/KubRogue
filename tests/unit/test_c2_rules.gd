extends SceneTree
const Director = preload("res://scripts/c2/wave_director.gd")
const Wallet = preload("res://scripts/c2/run_wallet.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, detail: String) -> void:
    if not ok:
        failures += 1
        push_error("C2 UNIT FAIL: " + detail)

func _run() -> void:
    var money := Wallet.new()
    check(money.award(10, "apprentice") == {"coins": 10, "xp": 1}, "first reward")
    check(money.award(10, "reinforced").is_empty(), "idempotent across kinds")
    check(money.coins == 10 and money.xp == 1 and money.solved == 1, "one reward only")
    check(money.award(11, "reinforced") == {"coins": 18, "xp": 2}, "reinforced reward")
    check(money.award(12, "invalid").is_empty(), "unknown variant no reward")
    check(money.award(-1, "apprentice").is_empty(), "negative ID no reward")
    check(money.coins == 28 and money.xp == 3, "wallet totals")
    money.reset()
    check(money.coins == 0 and money.awarded_ids.is_empty(), "reset clears paid set")

    var rules := Director.new()
    rules.start_run()
    check(rules.phase == Director.Phase.RUNNING, "wave starts")
    check(rules.wave_index == 0 and rules.total_expected() == 6, "first wave definition")
    var first: Dictionary = rules.spawn_next()
    check(int(first.get("id", -1)) == 1 and first.get("kind", "") == "apprentice", "first actual spawn")
    check(not rules.can_spawn(), "spawn timer works")
    check(rules.spawn_next().is_empty(), "no illegal rapid spawn")
    var paid := rules.resolve_cube(int(first["id"]))
    check(paid == {"coins": 10, "xp": 1}, "actual spawned cube rewards")
    check(rules.resolve_cube(int(first["id"])).is_empty(), "no duplicated payment")
    check(rules.wallet.coins == 10 and rules.wave_resolved == 1, "credits and stats")
    check(rules.finish_wave().is_empty(), "cannot finish early with pending spawns")
    rules.tick(Director.SPAWN_INTERVAL)
    var second: Dictionary = rules.spawn_next()
    rules.tick(Director.SPAWN_INTERVAL)
    var third: Dictionary = rules.spawn_next()
    check(second.get("kind", "") == "apprentice", "normal second")
    check(third.get("kind", "") == "reinforced", "reinforced third")
    check(rules.resolve_cube(int(third["id"])) == {"coins": 18, "xp": 2}, "reinforced credit")
    check(rules.wallet.coins == 28 and rules.wallet.xp == 3, "money is run-scoped")

    # One actor is still present. Three unshown items MUST NOT penalize.
    rules.tick(100.0)
    var summary: Dictionary = rules.finish_wave()
    check(int(summary.get("unresolved", -1)) == 1, "only 1 visible actor unresolved")
    check(int(summary.get("unseen", -1)) == 3, "3 queued spawns were never shown")
    check(int(summary.get("penalty", -1)) == 25, "only spawned cube penalizes")
    check(rules.stability == 75, "stability is 75")
    check(rules.phase == Director.Phase.BETWEEN, "inter-wave summary")
    check(rules.begin_next_wave(), "second wave starts")
    check(rules.total_expected() == 8, "second wave content")

    # Unshown queued spawns don't count as mistakes even at final wave timeout.
    rules.tick(100.0)
    var last: Dictionary = rules.finish_wave()
    check(last["unresolved"] == 0 and last["unseen"] == 8, "unseen bookkeeping")
    check(rules.stability == 75, "no phantom damage")
    check(rules.phase == Director.Phase.VICTORY, "C2 survival preview completed")
    check(not rules.begin_next_wave(), "cannot start an extra wave")

    rules.start_run()
    for idx in range(4):
        if idx > 0:
            rules.tick(Director.SPAWN_INTERVAL)
        check(not rules.spawn_next().is_empty(), "spawn %d" % idx)
    check(rules.active.size() == Director.MAX_ACTIVE, "four active limit")
    rules.tick(Director.SPAWN_INTERVAL)
    check(not rules.can_spawn() and rules.spawn_next().is_empty(), "no fifth actor until slot open")
    rules.tick(100)
    var defeat: Dictionary = rules.finish_wave()
    check(defeat["unresolved"] == 4 and defeat["unseen"] == 2, "four visible two unseen")
    check(rules.stability == 0 and rules.phase == Director.Phase.DEFEAT, "failure at zero")
    check(not rules.begin_next_wave(), "defeat blocks continuation")
    rules.start_run()
    check(rules.wallet.coins == 0 and rules.stability == 100 and rules.next_actor_id == 1,
        "restarting run resets money, stability and actor IDs")
    print("KubRogue C2 unit tests: %d failures" % failures)
    quit(0 if failures == 0 else 1)
