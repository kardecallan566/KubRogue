extends SceneTree
const Progress = preload("res://scripts/c4/progress_service.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, detail: String) -> void:
    if not ok:
        failures += 1
        push_error("C4 UNIT FAIL: " + detail)

func _clean(path: String) -> void:
    for suffix in ["", ".tmp", ".bak"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))

func _run() -> void:
    var path := "user://c4_unit_test_progress.json"
    _clean(path)
    var service: Progress = Progress.new()
    service.configure(Store.new(path))
    check(service.balance() == 0 and service.meta_level("hand_training") == 0, "default state")
    check(not service.purchase("invalid") and not service.purchase("hand_training"), "reject invalid and unaffordable")
    check(service.next_cost("hand_training") == 200 and service.next_cost("stable_field") == 300, "prices")
    check(service.begin_run(), "begin run persists")
    check(service.credit_cube(1, 10), "first solution credits")
    check(not service.credit_cube(1, 1000), "same actor cannot pay twice")
    check(service.credit_cube(2, 18) and service.balance() == 28, "second reward")
    check(not service.credit_cube(-1, 99) and not service.credit_cube(3, -1), "reject invalid amounts")
    check(service.credit_cube(3, 300), "additional earned funds for unit test")
    check(service.purchase("hand_training"), "buy training level 1")
    check(service.meta_level("hand_training") == 1, "training rank")
    check(service.balance() == 128, "single debit, no double purchase")
    check(not service.purchase("hand_training"), "cannot buy level 2 without balance")
    check(service.credit_cube(4, 1200), "earn more test funds")
    check(service.purchase("cubist_pocket") and service.purchase("stable_field"), "other lines")
    check(service.coin_bonus() == 0.05 and service.stability_max() == 105, "meta effects")
    check(is_equal_approx(service.cooldown_reduction(), 0.04), "speed meta effect")
    check(service.update_record(3, 12, 4), "record saved")
    check(service.update_record(2, 8, 1), "weaker run does not reduce records")
    check(service.finish_tutorial() and bool(service.data["tutorial_completed"]), "tutorial flag persisted")
    check(service.set_setting("music_volume", 0.35), "music preference")
    check(service.set_setting("reduced_particles", true), "accessibility preference")
    check(not service.set_setting("coins", 3), "unknown setting rejected")
    var expected_balance := service.balance()
    var loaded: Progress = Progress.new()
    loaded.configure(Store.new(path))
    check(loaded.balance() == expected_balance, "restart retains coins")
    check(loaded.meta_level("stable_field") == 1, "restart retains meta ranks")
    check(loaded.data["records"]["best_wave"] == 3, "restart retains best wave")
    check(loaded.data["settings"]["reduced_particles"] == true, "restart retains setting")
    check(loaded.data["tutorial_completed"] == true, "restart retains tutorial")
    check(not loaded.credit_cube(1, 900), "same run cannot replay paid ID after restart")
    check(loaded.begin_run(), "new run obtains new ID scope")
    check(loaded.credit_cube(1, 10), "same actor ID valid in new run")
    check(loaded.balance() == expected_balance + 10, "new run increases bank exactly once")

    # Deliberately corrupt primary: the backup contains the previous good save.
    var f := FileAccess.open(path, FileAccess.WRITE)
    check(f != null, "write corrupt fixture")
    if f != null:
        f.store_string("{invalid json")
        f.close()
    var recovered: Progress = Progress.new()
    recovered.configure(Store.new(path))
    check(recovered.balance() == expected_balance, "backup recovers last confirmed state")
    check(recovered.meta_level("stable_field") == 1, "backup preserves upgrades")
    _clean(path)
    print("KubRogue C4 progress tests: %d failures" % failures)
    quit(0 if failures == 0 else 1)
