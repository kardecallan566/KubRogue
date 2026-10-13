extends SceneTree
const Game = preload("res://scripts/c5/game_stage.gd")
const Hub = preload("res://scripts/c5/hub_stage.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, description: String) -> void:
    if not ok:
        failures += 1
        push_error("C5 STAGE FAIL: " + description)

func _run() -> void:
    var path := "user://c5_stage_test_save.json"
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
    var progress = get_root().get_node("KubeSession")
    progress.configure(Store.new(path))
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    check(hub.wallet_label != null and hub.wallet_label.text.contains("0 MOEDAS"), "C5 hub renders bank")
    check(hub.dialog_box != null and hub.dialog_box.get_parent() is ScrollContainer, "hub modal scrolls")
    var play_buttons := hub.find_children("*", "Button", true, false)
    check(play_buttons.size() >= 5, "cartoon hub offers at least five navigation buttons")
    if play_buttons.size() > 0:
        check(play_buttons[0].get_theme_stylebox("normal") is StyleBoxFlat,
            "hub primary action has layered arcade artwork")
    hub._show_settings()
    check(hub.dialog_center.visible, "settings modal works")
    check(progress.set_setting("reduced_particles", true), "reduced effects setting persists")
    hub.queue_free()
    await process_frame

    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.save_ready, "persistent run begins")
    check(game.hand is Control and game.effects is Control, "cursor and particles both 2D")
    check(game.effects.mouse_filter == Control.MOUSE_FILTER_IGNORE, "VFX do not intercept controls")
    check(game.time_bar is ProgressBar and game.stability_bar is ProgressBar and game.wave_bar is ProgressBar,
        "HUD has separate wave/time/stability bars")
    check(game.pause_button.get_theme_stylebox("normal") is StyleBoxFlat,
        "pause button uses the new illustrated arcade theme")
    check(game.hud_panel.get_theme_stylebox("panel") is StyleBoxFlat,
        "HUD panel is styled rather than native gray")
    check(game.hud_panel.custom_minimum_size.x <= 350, "HUD width is compact")
    check(game.card_widgets.size() == 3, "three skill cards, not stretched single-line buttons")
    check(game.card_grid is GridContainer and game.card_scroll is ScrollContainer,
        "skill modal uses responsive grid and scrolling")
    game.build.register_xp(5)
    game._show_cards()
    check(game.offers_open and game.card_center.visible, "skill selection opens")
    check(game.card_widgets[0].title_label.text.length() > 0
        and game.card_widgets[0].description_label.text.length() > 0,
        "skill cards separate names and explanatory text")
    var paused_clock := game.director.time_left
    game._process(1.0)
    check(is_equal_approx(game.director.time_left, paused_clock),
        "timer stops while choosing a skill")
    game._choose_card(0)
    check(not game.offers_open and game.build.offers_taken == 1,
        "choosing exactly one card closes overlay and improves build")
    check(game.get_node("GrassBatch") is MultiMeshInstance3D, "grass instanced not 66 nodes")
    check(game.get_node("GrassBatch").multimesh.instance_count == 66, "66 decorative patches batched")
    check(game.director.waves.size() == 5, "five roguelite waves preserved")
    check(game.actors.size() == 1, "first cube still spawns")
    var id: int = int(game.actors.keys()[0])
    var attempts := 0
    while game.actors.has(id) and attempts < 10:
        await game.solve_actor_move(id)
        attempts += 1
    check(not game.actors.has(id), "real 2x2 still resolves")
    check(progress.balance() == 10, "single durable 10-coin credit")
    check(game.effects.total_events >= 2, "visual spawn, turn and solve events emitted")
    check(game.pending_credits.is_empty(), "no unsaved reward")
    game.queue_free()
    await process_frame
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
    print("KubRogue C5 hub/game integration: %d failures" % failures)
    quit(0 if failures == 0 else 1)
