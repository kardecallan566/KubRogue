extends SceneTree
const Hub = preload("res://scripts/c15/hub_stage.gd")
const Game = preload("res://scripts/c15/game_stage.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error("C15 COLD FAIL: " + message)

func _run() -> void:
    var challenge = get_root().get_node("KubeChallenge")
    check(challenge.weekly_seed("2026-10-12")>0 and challenge.current_week()!="",
        "weekly service is available without editor import cache")
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    hub._show_play_modes()
    check(hub.dialog_box.find_child("Mode_Weekly",true,false)!=null,
        "third option builds before imports")
    hub.queue_free()
    await process_frame
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.save_ready and game.history!=null and game.medal_notice!=null,
        "C14 gameplay, C12 history and medal feedback still boot")
    game.queue_free()
    await process_frame
    print("KubRogue C15 cold boot: %d failures" % failures)
    quit(0 if failures==0 else 1)
