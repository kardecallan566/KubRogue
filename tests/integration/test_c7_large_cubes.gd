extends SceneTree
const Game = preload("res://scripts/c7/game_stage.gd")
const Director = preload("res://scripts/c7/special_director.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, reason: String) -> void:
    if not ok:
        failures += 1
        push_error("C7 LARGE FAIL: " + reason)

func _clean(path: String) -> void:
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))

func _seek(game: Game, wave_index: int, slot_index: int, kind: String) -> int:
    game._clear_actors()
    game.director.phase = Director.Phase.BETWEEN
    while game.director.wave_index < wave_index:
        if not game.director.begin_next_wave():
            return -1
        if game.director.wave_index < wave_index:
            game.director.phase = Director.Phase.BETWEEN
    game.director.next_spawn_index = slot_index
    game.director.spawn_clock = game.director.SPAWN_INTERVAL
    game._spawn_one_if_possible()
    for id in game.actors:
        if String(game.actors[id]["kind"]) == kind:
            return int(id)
    return -1

func _run() -> void:
    var path := "user://c7_large_wallet.json"
    _clean(path)
    var progress = get_root().get_node("KubeSession")
    var challenge = get_root().get_node("KubeChallenge")
    progress.configure(Store.new(path))
    challenge.select_mode("daily", "2026-10-13")
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.director.waves.size() == 5, "five waves unchanged")
    check(game.save_ready and game.hand.get_active_texture() != null,
        "approved wallet and hand keep working")

    var id4: int = _seek(game, 3, 10, "master4")
    check(id4 >= 0, "4x4 spawns on wave 4")
    if id4 >= 0:
        var cubie4 = game.actors[id4]["cube"]
        check(cubie4.puzzle.order == 4 and cubie4.puzzle.is_valid(), "real 4x4 state")
        check(cubie4.sticker_nodes.size() == 96, "96 stickers on 4x4")
        var attempts := 0
        while game.actors.has(id4) and attempts < 15:
            await game.solve_actor_move(id4)
            attempts += 1
        check(not game.actors.has(id4), "4x4 can be solved and removed")
        check(progress.balance() == 68, "4x4 granted 68 coins once")
        # The final 4x4 of wave 4 may finish the wave before the card modal
        # appears; XP is then pending while the wave summary is open.
        # Explicitly complete the valid XP card choice before wave 5.
        if game.build.pending > 0 and not game.offers_open:
            game._show_cards()
        if game.offers_open:
            game._choose_card(0)
        check(not game.offers_open and game.build.pending == 0,
            "XP earned from 4x4 is spent before starting 5x5")

    var balance_before_5x5: int = progress.balance()
    var id5: int = _seek(game, 4, 7, "master5")
    check(id5 >= 0, "5x5 spawns on wave 5")
    if id5 >= 0:
        var cubie5 = game.actors[id5]["cube"]
        check(cubie5.puzzle.order == 5 and cubie5.puzzle.is_valid(), "real 5x5 state")
        check(cubie5.sticker_nodes.size() == 150, "150 stickers on 5x5")
        var attempts := 0
        while game.actors.has(id5) and attempts < 18:
            await game.solve_actor_move(id5)
            attempts += 1
        check(not game.actors.has(id5), "5x5 actually solves")
        check(progress.balance() >= balance_before_5x5 + 110,
            "5x5 pays at least base reward; card bonuses may increase it")
        var post_reward_balance: int = progress.balance()
        await game.solve_actor_move(id5)
        check(progress.balance() == post_reward_balance, "5x5 cannot pay twice")

    check(game.director.waves[4]["types"].size() == 9,
        "boss 3x3 reserved slot and wave count maintained")
    game.queue_free()
    await process_frame
    check(Store.new(path).read_json()["coins"] == progress.balance(),
        "persistent 4x4 and 5x5 rewards reloaded")
    _clean(path)
    print("KubRogue C7 playable 4x4/5x5 tests: %d failures" % failures)
    quit(0 if failures == 0 else 1)
