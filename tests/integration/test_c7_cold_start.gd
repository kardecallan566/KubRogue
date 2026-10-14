extends SceneTree
const Game = preload("res://scripts/c7/game_stage.gd")
const Hub = preload("res://scripts/c7/hub_stage.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var fails := 0
func _initialize() -> void:
    call_deferred("_run")
func check(ok: bool, note: String) -> void:
    if not ok:
        fails += 1
        push_error("C7 COLD FAIL: " + note)
func _run() -> void:
    var path := "user://c7_cold_wallet.json"
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
    get_root().get_node("KubeSession").configure(Store.new(path))
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    check(hub.wallet_label != null and hub.daily_label != null, "C7 hub starts without editor import")
    hub.queue_free()
    await process_frame
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.hand.get_active_texture() != null, "open/grip PNGs still load cold")
    check(game.director.waves.size() == 5 and game.card_widgets.size() == 3,
        "C7 running game retains boss and card UI")
    check(game.director.variant_info("golden")["coins"] == 32, "special wallet connected")
    game.queue_free()
    await process_frame
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
    print("KubRogue C7 first-run boot: %d failures" % fails)
    quit(0 if fails == 0 else 1)
