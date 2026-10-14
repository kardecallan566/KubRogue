extends SceneTree
const Hub = preload("res://scripts/c6/hub_stage.gd")
const Game = preload("res://scripts/c6/game_stage.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, note: String) -> void:
    if not ok:
        failures += 1
        push_error("C6 STAGE FAIL: " + note)

func _clean(path: String) -> void:
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))

func _run() -> void:
    var wallet_path := "user://c6_stage_wallet.json"
    var daily_path := "user://c6_stage_daily.json"
    _clean(wallet_path)
    _clean(daily_path)
    var progress = get_root().get_node("KubeSession")
    var challenge = get_root().get_node("KubeChallenge")
    progress.configure(Store.new(wallet_path))
    challenge.configure(Store.new(daily_path))
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    check(hub.find_children("*", "Button", true, false).size() >= 6,
        "normal and daily buttons both visible")
    check(hub.daily_label.text.contains("DESAFIO"), "daily status shown on hub")
    hub._start_daily()
    check(challenge.active_mode == "daily" and hub.dialog_center.visible,
        "daily mode selected, tutorial remains available to new player")
    hub.queue_free()
    await process_frame
    challenge.select_mode("daily", "2026-10-13")
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.save_ready, "daily run starts with durable wallet")
    check(game.run_seed == challenge.daily_seed("2026-10-13"), "game uses daily fixed seed")
    check(game.mode_label.text.contains("DESAFIO"), "HUD identifies mode and seed")
    check(game.hand.get_active_texture() != null, "approved open hand still loads")
    check(game.card_widgets.size() == 3, "skill cards remain separate")
    game.build.register_xp(5)
    game._show_cards()
    var previous: Array[String] = game.build.current_offer.duplicate()
    game._reroll_cards()
    check(game.offers_open and game.build.rerolls_remaining == 0, "reroll doesn't close XP choice")
    check(game.build.current_offer != previous, "reroll changes skill selection")
    check(game.reroll_button.disabled, "one-time reroll visibly disabled")
    game._choose_card(0)
    check(not game.offers_open and game.build.offers_taken == 1, "card still selectable")
    var first_id: int = int(game.actors.keys()[0])
    var attempts := 0
    while game.actors.has(first_id) and attempts < 10:
        await game.solve_actor_move(first_id)
        attempts += 1
    check(progress.balance() >= 10 and game.pending_credits.is_empty(), "C4 coins still persist")
    game._record_challenge_if_needed()
    check(challenge.record_for("2026-10-13")["attempts"] == 1, "partial run recorded once")
    game._record_challenge_if_needed()
    check(challenge.record_for("2026-10-13")["attempts"] == 1, "no duplicate daily record")
    game.queue_free()
    await process_frame
    check(Store.new(wallet_path).read_json()["coins"] == progress.balance(),
        "daily mode does not corrupt wallet")
    _clean(wallet_path)
    _clean(daily_path)
    print("KubRogue C6 daily hub/game integration: %d failures" % failures)
    quit(0 if failures == 0 else 1)
