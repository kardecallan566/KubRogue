extends SceneTree
const Game = preload("res://scripts/c10/game_stage.gd")
const Hub = preload("res://scripts/c10/hub_stage.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var errors := 0
func _initialize() -> void:
    call_deferred("_run")
func check(ok: bool,note: String) -> void:
    if not ok:
        errors += 1
        push_error("C10 COLD FAIL: "+note)
func _run() -> void:
    var path := "user://c10_cold.json"
    for suffix in ["",".tmp",".bak"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path+suffix))
    get_root().get_node("KubeSession").configure(Store.new(path))
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    check(hub.collection_label!=null and hub.daily_label!=null,
        "hub modes and gallery cold-load")
    hub.queue_free()
    await process_frame
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.save_ready and game.fever!=null and game.fever_frame!=null,
        "fever theme and engine initialize without editor cache")
    check(game.hand.get_active_texture()!=null,
        "C5 hand PNGs still load")
    check(game.routes!=null and game.workshop!=null and game.journal!=null,
        "C8 and C9 services unaffected")
    game.queue_free()
    await process_frame
    for suffix in ["",".tmp",".bak"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path+suffix))
    print("KubRogue C10 cold boot: %d failures" % errors)
    quit(0 if errors==0 else 1)
