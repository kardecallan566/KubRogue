extends SceneTree
const Game = preload("res://scripts/c7/game_stage.gd")
const Hub = preload("res://scripts/c7/hub_stage.gd")
const Store = preload("res://scripts/c4/save_store.gd")
const SpecialDirector = preload("res://scripts/c7/special_director.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, why: String) -> void:
    if not ok:
        failures += 1
        push_error("C7 STAGE FAIL: " + why)

func _clean(path: String) -> void:
    for suffix in ["", ".tmp", ".bak"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))

func _next_wave(game: Game) -> void:
    game._clear_actors()
    game.director.phase = SpecialDirector.Phase.BETWEEN
    check(game.director.begin_next_wave(), "advancing to test wave")
    game._spawn_one_if_possible()

func _spawn_next(game: Game) -> void:
    game.director.tick(game.director.SPAWN_INTERVAL)
    game._spawn_one_if_possible()

func _first_kind(game: Game, kind: String) -> int:
    for id in game.actors:
        if String(game.actors[id]["kind"]) == kind:
            return int(id)
    return -1

func _run() -> void:
    var money_path := "user://c7_stage_wallet.json"
    var daily_path := "user://c7_stage_daily.json"
    _clean(money_path)
    _clean(daily_path)
    var progress = get_root().get_node("KubeSession")
    var challenge = get_root().get_node("KubeChallenge")
    progress.configure(Store.new(money_path))
    challenge.configure(Store.new(daily_path))
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    check(hub.feedback_label.text.contains("DOURADO"), "new hub advertises special cubes")
    check(hub.daily_label != null, "C6 daily access remains")
    hub.queue_free()
    await process_frame

    challenge.select_mode("daily", "2026-10-13")
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.save_ready and game.director.waves.size() == 5, "five-wave gameplay ready")
    check(game.hand.get_active_texture() != null, "approved 2D cursor still loads")
    check(game.card_widgets.size() == 3 and game.reroll_button != null, "C5/C6 skills intact")
    var initial_seed := game.run_seed
    check(initial_seed == challenge.daily_seed("2026-10-13"), "daily seed unchanged")

    _next_wave(game) # Wave 2
    _spawn_next(game) # Golden
    var gold_id := _first_kind(game, "golden")
    check(gold_id >= 0, "gold target spawns in wave 2")
    if gold_id >= 0:
        var gold: Dictionary = game.actors[gold_id]
        check(is_instance_valid(gold["accent"]), "gold has special visuals")
        check(gold["cube"].moves_remaining() >= 3, "gold requires actual rotations")
        var moves := 0
        while game.actors.has(gold_id) and moves < 12:
            await game.solve_actor_move(gold_id)
            moves += 1
        check(not game.actors.has(gold_id), "gold is solvable with actual cube rotations")
        check(progress.balance() == 32, "gold earned and saved exactly 32 coins")
        check(game.pending_credits.is_empty(), "no failed payments")
        await game.solve_actor_move(gold_id)
        check(progress.balance() == 32, "can't credit solved cube again")

    _next_wave(game) # Wave 3
    _spawn_next(game)
    _spawn_next(game) # Armored
    var armored_id := _first_kind(game, "armored")
    check(armored_id >= 0, "armored target spawns in wave 3")
    if armored_id >= 0:
        var armored: Dictionary = game.actors[armored_id]
        check(is_instance_valid(armored["accent"]), "armor has own visual styling")
        check(armored["cube"].moves_remaining() >= 8, "armor requires extra cube moves")
        var moves := 0
        while game.actors.has(armored_id) and moves < 16:
            await game.solve_actor_move(armored_id)
            moves += 1
        check(not game.actors.has(armored_id), "armored real 2x2 can be solved")
        check(progress.balance() >= 62, "gold + armor both credited durably")

    check(game.director.waves[4]["types"].size() == 9,
        "elite wave retains original reserve and required victory")
    game.queue_free()
    await process_frame
    check(Store.new(money_path).read_json()["coins"] == progress.balance(),
        "persistent wallet saved with special payments")
    _clean(money_path)
    _clean(daily_path)
    print("KubRogue C7 special cubes integration: %d failures" % failures)
    quit(0 if failures == 0 else 1)
