extends SceneTree
const Hub = preload("res://scripts/c14/hub_stage.gd")
const Game = preload("res://scripts/c14/game_stage.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, reason: String) -> void:
    if not ok:
        failures += 1
        push_error("C14 COLD FAIL: " + reason)

func _run() -> void:
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    hub._show_bestiary()
    check(hub.dialog_box.find_child("GardenAchievementsGallery",true,false)!=null,
        "new medal gallery loads from a clean Godot project")
    hub.queue_free()
    await process_frame
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.medal_notice!=null and game.history!=null,
        "C14 HUD preserves history autoload on cold startup")
    game.queue_free()
    await process_frame
    print("KubRogue C14 clean boot: %d failures" % failures)
    quit(0 if failures==0 else 1)
