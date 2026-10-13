extends SceneTree
const Stage = preload("res://scripts/c2/wave_stage.gd")
const Director = preload("res://scripts/c2/wave_director.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, detail: String) -> void:
    if not ok:
        failures += 1
        push_error("C2 STAGE FAIL: " + detail)

func _run() -> void:
    var stage: Stage = Stage.new()
    get_root().add_child(stage)
    check(stage.camera != null and stage.camera.projection == Camera3D.PROJECTION_ORTHOGONAL,
        "retains fixed orthographic field")
    check(stage.hand is Control and stage.hand.get_parent() is CanvasLayer,
        "retains 2D hand")
    check(stage.hand.mouse_filter == Control.MOUSE_FILTER_IGNORE,
        "hand never blocks clicking")
    check(stage.actors.size() == 1, "first cubie is spawned on entry")
    check(stage.director.wave_index == 0, "starts wave one")
    var id: int = int(stage.actors.keys()[0])
    var item: Dictionary = stage.actors[id]
    check(item["cube"].cubies.size() == 8 and item["cube"].sticker_nodes.size() == 24,
        "each spawned actor is a real compact 2x2")

    var guard := 0
    while stage.actors.has(id) and guard < 10:
        await stage.solve_actor_move(id)
        guard += 1
    check(not stage.actors.has(id), "first actor was actually solved and removed")
    check(stage.director.wallet.coins == 10 and stage.director.wallet.xp == 1,
        "credits only after solved")
    await stage.solve_actor_move(id)
    check(stage.director.wallet.coins == 10, "old actor ID never pays twice")

    # A stronger type can be spawned and solved through real animations.
    stage.director.tick(Director.SPAWN_INTERVAL)
    stage._spawn_one_if_possible()
    stage.director.tick(Director.SPAWN_INTERVAL)
    stage._spawn_one_if_possible()
    check(stage.actors.size() == 2, "two simultaneous actors")
    var reinforced_id := -1
    for actor_id in stage.actors:
        var other: Dictionary = stage.actors[actor_id]
        if other["kind"] == "reinforced":
            reinforced_id = int(actor_id)
    check(reinforced_id > 0, "reinforced type spawns")
    if reinforced_id > 0:
        var limit := 0
        while stage.actors.has(reinforced_id) and limit < 12:
            await stage.solve_actor_move(reinforced_id)
            limit += 1
        check(stage.director.wallet.coins == 28, "reinforced paid +18 only once")
        check(stage.director.wallet.xp == 3, "normal XP 1 plus strong XP 2")

    # Force timeout, and ensure only visible/unresolved actors lower stability.
    stage.director.tick(100.0)
    if not stage.action_locked:
        stage._finish_wave()
    check(stage.director.phase == Director.Phase.BETWEEN, "wave finishes into summary")
    check(stage.director.stability == 75, "one visible actor penalized 25")
    check(stage.summary_panel.visible and stage.summary_button.text == "Próxima onda",
        "summary shows actionable next wave")
    stage._continue_from_summary()
    check(stage.director.wave_index == 1 and stage.director.phase == Director.Phase.RUNNING,
        "continue starts next wave")

    # Paused play must freeze timer, spawn progression AND decorative actor motion.
    var pause_id: int = int(stage.actors.keys()[0])
    var pause_actor: Node3D = stage.actors[pause_id]["root"]
    var pause_position: Vector3 = pause_actor.position
    var pause_time: float = stage.director.time_left
    var pause_spawn: float = stage.director.spawn_clock
    stage._toggle_pause()
    check(stage.paused, "pause activated")
    stage._process(1.5)
    check(is_equal_approx(stage.director.time_left, pause_time), "timer frozen during pause")
    check(is_equal_approx(stage.director.spawn_clock, pause_spawn), "spawn clock frozen")
    check(pause_actor.position.distance_to(pause_position) < 0.0001, "actor motion frozen")
    stage._toggle_pause()
    check(not stage.paused, "resume activated")

    stage.restart_run()
    check(stage.director.wallet.coins == 0 and stage.director.stability == 100,
        "restart creates clean run")
    check(stage.actors.size() == 1, "restart spawns starter actor")

    # Explicit loss path through actual scene state.
    stage.director.tick(Director.SPAWN_INTERVAL)
    stage._spawn_one_if_possible()
    stage.director.tick(Director.SPAWN_INTERVAL)
    stage._spawn_one_if_possible()
    stage.director.tick(Director.SPAWN_INTERVAL)
    stage._spawn_one_if_possible()
    check(stage.actors.size() == 4, "maximum four visual actors")
    stage.director.tick(100.0)
    stage._finish_wave()
    check(stage.director.phase == Director.Phase.DEFEAT, "loss at four unresolved")
    check(stage.director.wallet.coins == 0, "no free coins for failure")

    stage.queue_free()
    print("KubRogue C2 integration tests: %d failures" % failures)
    quit(0 if failures == 0 else 1)
