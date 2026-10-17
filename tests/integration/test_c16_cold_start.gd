extends SceneTree
const Hub = preload("res://scripts/c16/hub_stage.gd")
const Game = preload("res://scripts/c16/game_stage.gd")
const Laboratory = preload("res://scripts/c16/lab_stage.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, note: String) -> void:
    if not ok:
        failures += 1
        push_error("C16 COLD FAIL: " + note)

func _run() -> void:
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    hub._show_play_modes()
    check(hub.dialog_box.find_child("OpenLaboratory",true,false)!=null,
        "laboratory link loads before editor import")
    hub.queue_free()
    await process_frame
    var lab: Laboratory = Laboratory.new()
    get_root().add_child(lab)
    check(lab.cube != null and lab.cube.sticker_nodes.size()==24,
        "procedural cube preview loads without imported assets")
    check(lab.status_label != null and lab.hint_button != null,
        "training HUD builds without global class cache")
    lab.queue_free()
    await process_frame
    # Weekly, medal and result systems are still available via C15 inheritance.
    check(Game != null and get_root().get_node("KubeChallenge").current_week()!="",
        "C15 weekly gameplay remains loadable")
    print("KubRogue C16 cold-start training: %d failures" % failures)
    quit(0 if failures==0 else 1)
