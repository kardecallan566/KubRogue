extends SceneTree
const Store = preload("res://scripts/c4/save_store.gd")
const Progress = preload("res://scripts/c4/progress_service.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    if not ok:
        failures += 1
        push_error("AUDIT SCHEMA FAIL: " + label)

func _clean(path: String) -> void:
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))

func _run() -> void:
    var path := "user://audit_schema_guard.json"
    _clean(path)
    var adapter := Store.new(path)
    var future: Dictionary = {
        "schema_version": 99, "coins": 987654, "meta": {"new_unknown_upgrade":7},
        "records": {"best_wave":5}, "additional_field":"preserve-me"
    }
    check(adapter.write_json(future),"unknown future-save fixture is persisted")
    var original: String = FileAccess.get_file_as_string(path)
    var wallet: Progress = Progress.new()
    wallet.configure(Store.new(path))
    check(not wallet.save_writable, "unknown save schema enters read-only safety mode")
    check(wallet.last_error.contains("incompatível"), "visible warning is not discarded")
    check(not wallet.begin_run(), "new run cannot overwrite unknown future save")
    check(not wallet.credit_cube(1,10), "wallet cannot overwrite unknown schema")
    check(not wallet.set_setting("music_volume",0.4),"settings cannot overwrite unknown schema")
    check(not wallet.finish_tutorial(),"tutorial cannot overwrite unknown schema")
    check(FileAccess.get_file_as_string(path)==original,
        "unknown future format remains byte-for-byte unchanged")
    check(adapter.read_json().get("coins",-1)==987654,
        "existing future coins stay on disk")
    check(not FileAccess.file_exists(path+".bak"),
        "blocked operation never creates backup of invalid migration")
    _clean(path)
    var classic: Dictionary = {
        "schema_version":1,"coins":123,"paid_ids":[],"run_number":5
    }
    check(adapter.write_json(classic),"legacy C4 save fixture is valid")
    wallet.configure(Store.new(path))
    check(wallet.save_writable and wallet.last_error.is_empty(),
        "original schema remains writable")
    check(wallet.balance()==123 and wallet.begin_run(),
        "real C4 saves are not blocked")
    check(wallet.credit_cube(1,10) and wallet.balance()==133,
        "original C4 credits continue to work")
    wallet.free()
    _clean(path)
    print("KubRogue audit schema/data guard: %d failures" % failures)
    quit(0 if failures==0 else 1)
