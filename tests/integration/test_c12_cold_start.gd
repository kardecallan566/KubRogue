extends SceneTree
const Hub = preload("res://scripts/c12/hub_stage.gd")
const Game = preload("res://scripts/c12/game_stage.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, reason: String) -> void:
    if not ok:
        failures += 1
        push_error("C12 COLD FAIL: "+reason)

func _run() -> void:
    var path := "user://c12_cold_money.json"
    for s in ["",".bak",".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path+s))
    get_root().get_node("KubeSession").configure(Store.new(path))
    var history = get_root().get_node("KubeHistory")
    check(history!=null and history.runs.size()<=12,"history autoload exists on clean boot")
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    hub._show_history()
    check(hub.dialog_box.find_child("HistoryGallery",true,false)!=null,"history gallery builds without editor imports")
    hub.queue_free()
    await process_frame
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.save_ready and game.medal_panel!=null,"C12 result banner builds on fresh clone")
    check(game.hand.get_active_texture()!=null,"C5 PNG cursor still available")
    check(game.workshop!=null and game.routes!=null and game.fever!=null,
        "C8-C10 systems still initialize")
    game.queue_free()
    await process_frame
    for s in ["",".bak",".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path+s))
    print("KubRogue C12 cold boot: %d failures" % failures)
    quit(0 if failures==0 else 1)
