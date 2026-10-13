extends SceneTree
const Stage = preload("res://scripts/c3/roguelite_stage.gd")
const Director = preload("res://scripts/c3/roguelite_director.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, detail: String) -> void:
    if not ok:
        failures += 1
        push_error("C3 STAGE FAIL: " + detail)

func _run() -> void:
    var stage: Stage = Stage.new()
    get_root().add_child(stage)
    check(stage.hand is Control, "preserves 2D cursor")
    check(stage.camera != null and stage.camera.projection == Camera3D.PROJECTION_ORTHOGONAL, "preserves fixed camera")
    check(stage.director.waves.size() == 5, "five wave sequence")
    check(stage.actors.size() == 1, "first 2x2 spawned")
    var first_id: int = int(stage.actors.keys()[0])
    check(stage.actors[first_id]["cube"].cubies.size() == 8, "real compact 2x2 in stage")

    # XP milestone opens an actionable 1/3 card modal without advancing world time.
    stage.build.register_xp(5)
    stage._show_cards()
    check(stage.offers_open and stage.card_buttons.size() == 3, "offer opens with three cards")
    var clock_before := stage.director.time_left
    var spawn_before := stage.director.spawn_clock
    stage._process(3.0)
    check(is_equal_approx(stage.director.time_left, clock_before), "clock freezes on offer")
    check(is_equal_approx(stage.director.spawn_clock, spawn_before), "spawns freeze on offer")
    stage._choose_card(0)
    check(not stage.offers_open and stage.build.offers_taken == 1, "card choice resumes run")

    # Boss display really contains a 3x3 with 26 cubies and 54 stickers.
    stage._clear_actors()
    stage.director.phase = Director.Phase.BETWEEN
    stage.director.wave_index = 3
    check(stage.director.begin_next_wave(), "enter fifth wave")
    stage.director.tick(20.0)
    stage._spawn_one_if_possible()
    var elite_id := -1
    for id in stage.actors:
        if stage.actors[id]["kind"] == "elite":
            elite_id = int(id)
    check(elite_id > 0, "boss is introduced in final wave")
    if elite_id > 0:
        var elite_cube = stage.actors[elite_id]["cube"]
        check(elite_cube.cubies.size() == 26, "real 3x3: 26 cubies")
        check(elite_cube.sticker_nodes.size() == 54, "real 3x3: 54 stickers")
        var guard := 0
        while stage.actors.has(elite_id) and guard < 16:
            await stage.solve_actor_move(elite_id)
            guard += 1
        check(not stage.actors.has(elite_id), "elite resolved through legal 3D rotations")
        check(stage.director.elite_resolved, "elite logical completion registered")
        check(stage.director.wallet.coins >= 80, "elite rewarded only once")
    stage.queue_free()
    print("KubRogue C3 integration tests: %d failures" % failures)
    quit(0 if failures == 0 else 1)
