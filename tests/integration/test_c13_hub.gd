extends SceneTree
const Hub = preload("res://scripts/c13/hub_stage.gd")
const History = preload("res://scripts/c12/history_service.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, msg: String) -> void:
    if not ok:
        failures += 1
        push_error("C13 UI FAIL: " + msg)

func _sample(id: int, mode: String, victory: bool) -> Dictionary:
    return {
        "run_id": id, "result": "victory" if victory else "defeat",
        "mode": mode, "date": "2026-10-15", "seed": 123,
        "finished_at": "2026-10-15T14:00:00",
        "wave": 5 if victory else 2,
        "cubes": 10, "coins": 60, "xp": 12, "combo": 5,
        "contracts": 2, "fevers": 1, "skills": 3, "stability": 76
    }

func _clean(path: String) -> void:
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))

func _run() -> void:
    var path := "user://c13_history_ui_test.json"
    var money_path := "user://c13_history_ui_money.json"
    _clean(path)
    _clean(money_path)
    get_root().get_node("KubeSession").configure(Store.new(money_path))
    var history: History = get_root().get_node("KubeHistory") as History
    history.configure(Store.new(path))
    check(history.record_finish(_sample(1, "normal", true)), "first record saved")
    check(history.record_finish(_sample(2, "daily", false)), "second record saved")
    check(history.record_finish(_sample(3, "daily", true)), "third record saved")
    var disk_before := FileAccess.get_file_as_string(path)
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    check(hub.find_child("PrimaryActions", true, false).get_child_count() == 4,
        "main menu retains exactly four actions")
    hub._show_bestiary()
    check(hub.dialog_box.find_child("OpenHistory", true, false) != null,
        "bestiary remains the only entrance to career stats")
    hub._show_history()
    check(hub.dialog_box.find_child("CareerDashboard", true, false) != null
        and hub.dialog_box.find_child("HistoryFilterDaily", true, false) != null,
        "career overview and filters appear inside the old history modal")
    var gallery := hub.dialog_box.find_child("HistoryGallery", true, false)
    check(gallery.get_child_count() == 3, "all runs visible by default")
    hub._set_history_mode("daily")
    check(gallery.get_child_count() == 2 and hub.career_metrics.text.contains("2 partidas"),
        "daily filter changes cards and denominators")
    hub._set_history_mode("normal")
    check(gallery.get_child_count() == 1 and hub.career_metrics.text.contains("100%"),
        "normal filter shows only its own results")
    hub._set_history_mode("all")
    check(gallery.get_child_count() == 3, "all tab restores original cards")
    check(FileAccess.get_file_as_string(path) == disk_before,
        "viewing and filtering do not alter JSON save")
    hub.queue_free()
    await process_frame
    var loaded: History = History.new()
    loaded.configure(Store.new(path))
    check(loaded.runs.size() == 3, "history still reloads in original C12 format")
    loaded.free()
    _clean(path)
    _clean(money_path)
    print("KubRogue C13 hub career filters: %d failures" % failures)
    quit(0 if failures == 0 else 1)
