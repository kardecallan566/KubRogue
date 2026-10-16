extends SceneTree
const Hub = preload("res://scripts/c13/hub_stage.gd")
const Stats = preload("res://scripts/c13/career_stats.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, msg: String) -> void:
    if not ok:
        failures += 1
        push_error("C13 COLD FAIL: " + msg)

func _run() -> void:
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    hub._show_history()
    check(hub.dialog_box.find_child("CareerDashboard", true, false) != null,
        "C13 loads before Godot creates class cache")
    check(Stats.summarize([])["win_rate"] == 0,
        "read-only aggregates work without any saved runs")
    hub.queue_free()
    await process_frame
    print("KubRogue C13 cold boot: %d failures" % failures)
    quit(0 if failures == 0 else 1)
