extends SceneTree
const Hub = preload("res://scripts/c12/hub_stage.gd")
const Game = preload("res://scripts/c12/game_stage.gd")
const Medal = preload("res://scripts/c12/medal_service.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var errors := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool,why: String) -> void:
    if not ok:
        errors += 1
        push_error("C12 COLD FAIL: "+why)

func _run() -> void:
    var path := "user://c12_cold.json"
    for suffix in ["",".tmp",".bak"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path+suffix))
    get_root().get_node("KubeSession").configure(Store.new(path))
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    check(hub.collection_label != null and hub.medals_label != null,
        "new medal UI parses without an editor class cache")
    check(hub.medals.trophy_count(
        get_root().get_node("KubeJournal"),get_root().get_node("KubeSession"))>=0,
        "retroactive medals use existing C4 and C8 stores")
    hub.queue_free()
    await process_frame
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.save_ready and game.medals != null,
        "medals initialize in live C12 game")
    check(game.hand.get_active_texture()!=null,
        "raw PNG cursor remains usable before imported textures")
    game.queue_free()
    await process_frame
    for suffix in ["",".tmp",".bak"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path+suffix))
    print("KubRogue C12 no-import cold boot: %d failures" % errors)
    quit(0 if errors==0 else 1)
