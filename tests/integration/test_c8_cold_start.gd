extends SceneTree
const Hub = preload("res://scripts/c8/hub_stage.gd")
const Game = preload("res://scripts/c8/game_stage.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var failures := 0
func _initialize() -> void:
    call_deferred("_run")
func check(ok: bool, note: String) -> void:
    if not ok:
        failures += 1
        push_error("C8 COLD FAIL: " + note)
func _run() -> void:
    var path := "user://c8_cold_wallet.json"
    for extension in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + extension))
    get_root().get_node("KubeSession").configure(Store.new(path))
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    check(hub.collection_label != null and hub.daily_label != null,
        "fresh hub shows discovery and daily challenge")
    hub.queue_free()
    await process_frame
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.journal != null and game.contract_label != null,
        "journal/autoload present even before editor import")
    check(game.hand.get_active_texture() != null,
        "original PNG cursor still works")
    check(game.director.waves.size() == 5 and game.card_widgets.size() == 3,
        "real cube gameplay and skills still initialize")
    game.queue_free()
    await process_frame
    for extension in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + extension))
    print("KubRogue C8 cold boot: %d failures" % failures)
    quit(0 if failures == 0 else 1)
