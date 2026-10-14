extends SceneTree
const Store = preload("res://scripts/c4/save_store.gd")
const Progress = preload("res://scripts/c4/progress_service.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    if not ok:
        failures += 1
        push_error("AUDIT SAVE FAIL: " + label)

func _clean(path: String) -> void:
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))

func _corrupt(path: String, content: String) -> void:
    var file := FileAccess.open(path, FileAccess.WRITE)
    check(file != null, "corrupt fixture writable")
    if file != null:
        file.store_string(content)
        file.close()

func _run() -> void:
    var path := "user://audit_c11_save.json"
    _clean(path)
    var store: Store = Store.new(path)
    check(store.write_json({"coins":100,"origin":"first"}), "original document persisted")
    check(store.write_json({"coins":120,"origin":"second"}), "subsequent document persisted")
    check(Store.new(path).read_json().get("coins",-1) == 120, "current save readable")
    check(Store.new(path+".bak").read_json().get("coins",-1) == 100,
        "last-known-good backup was retained")
    _corrupt(path, "{broken primary")
    check(store.read_json().get("coins",-1) == 100, "backup rescues corrupt primary")
    check(store.write_json({"coins":140,"origin":"after-recovery"}),
        "game can persist a new result after fallback recovery")
    check(Store.new(path+".bak").read_json().get("coins",-1) == 100,
        "writing after recovery does not destroy good backup")
    check(store.read_json().get("coins",-1) == 140,
        "new primary is usable immediately")
    _corrupt(path, "{also broken")
    check(store.read_json().get("coins",-1) == 100,
        "second interruption can still recover good backup")
    check(store.write_json({"coins":160}), "next recovery can resume writing")
    check(Store.new(path+".bak").read_json().get("coins",-1) == 100,
        "repeated recovery never promotes corrupt JSON to backup")
    check(not store.write_json({"too_large":"X".repeat(Store.MAX_BYTES)}),
        "oversized snapshot is rejected before writing")
    check(store.read_json().get("coins",-1) == 160, "failed giant write preserves primary")

    # Exercise a real C4 wallet through recovery followed by an ordinary purchase.
    _clean(path)
    var progress: Progress = Progress.new()
    progress.configure(Store.new(path))
    check(progress.begin_run(), "durable run starts")
    check(progress.credit_cube(1,500), "earned wallet coins")
    check(progress.credit_cube(2,100), "second credit creates wallet backup")
    _corrupt(path, "malformed wallet")
    var restored: Progress = Progress.new()
    restored.configure(Store.new(path))
    check(restored.balance() == 500, "wallet loads previous intact balance")
    check(restored.purchase("hand_training"), "valid old upgrade can be purchased after recovery")
    check(restored.balance() == 300, "purchase debited once")
    _corrupt(path, "still malformed wallet")
    var again: Progress = Progress.new()
    again.configure(Store.new(path))
    check(again.balance() == 500 and again.meta_level("hand_training")==0,
        "prior backup remains usable even after second crash")
    progress.free()
    restored.free()
    again.free()
    _clean(path)
    print("KubRogue audit save recovery: %d failures" % failures)
    quit(0 if failures == 0 else 1)
