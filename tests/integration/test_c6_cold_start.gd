extends SceneTree
const Game = preload("res://scripts/c6/game_stage.gd")
const Hub = preload("res://scripts/c6/hub_stage.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var fails := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, msg: String) -> void:
    if not ok:
        fails += 1
        push_error("C6 COLD FAIL: " + msg)

func _run() -> void:
    var path := "user://c6_cold_wallet.json"
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
    get_root().get_node("KubeSession").configure(Store.new(path))
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    check(hub.daily_label != null, "fresh launch shows daily status")
    hub.queue_free()
    await process_frame
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.hand.get_active_texture() != null, "sprites decode without PNG editor import")
    check(game.card_widgets.size() == 3 and game.reroll_button != null,
        "fresh launch has new skill cards and reroll")
    check(game.director.waves.size() == 5, "existing gameplay intact")
    game.queue_free()
    await process_frame
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
    print("KubRogue C6 cold start: %d failures" % fails)
    quit(0 if fails == 0 else 1)
