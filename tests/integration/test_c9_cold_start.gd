extends SceneTree
const Game = preload("res://scripts/c9/game_stage.gd")
const Hub = preload("res://scripts/c9/hub_stage.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var errors := 0
func _initialize() -> void:
    call_deferred("_run")
func check(ok: bool,why: String) -> void:
    if not ok:
        errors += 1
        push_error("C9 COLD FAIL: "+why)
func _run() -> void:
    var p := "user://c9_cold_wallet.json"
    for x in ["",".bak",".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(p+x))
    get_root().get_node("KubeSession").configure(Store.new(p))
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    check(hub.collection_label != null and hub.daily_label != null,
        "cold hub still contains C8 bestiary and daily selection")
    hub.queue_free()
    await process_frame
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.save_ready and game.routes != null,"routes initialized before run reset")
    check(game.route_cards != null and game.route_center != null,
        "route overlay compiled before editor import")
    check(game.hand.get_active_texture() != null,"sprite hand still decodes")
    game.queue_free()
    await process_frame
    for x in ["",".bak",".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(p+x))
    print("KubRogue C9 clean boot: %d failures" % errors)
    quit(0 if errors==0 else 1)
