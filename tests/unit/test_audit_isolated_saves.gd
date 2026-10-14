extends SceneTree
const Store = preload("res://scripts/c4/save_store.gd")
const Challenge = preload("res://scripts/c6/challenge_service.gd")
const Journal = preload("res://scripts/c8/journal_service.gd")
var fails := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    if not ok:
        fails += 1
        push_error("AUDIT ISOLATED SAVE FAIL: " + label)

func _clean(path: String) -> void:
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))

func _bad_file(path: String) -> void:
    var f := FileAccess.open(path, FileAccess.WRITE)
    check(f != null, "fixture writable")
    if f != null:
        f.store_string("{broken")
        f.close()

func _run() -> void:
    var daily_path := "user://audit_daily_lock.json"
    var journal_path := "user://audit_journal_lock.json"
    _clean(daily_path)
    _clean(journal_path)
    var daily: Challenge = Challenge.new()
    var journal: Journal = Journal.new()

    check(Store.new(daily_path).write_json({"version":777,"days":{"2026-10-14":{"wins":14}}}),
        "future daily data saved as fixture")
    var future_daily := FileAccess.get_file_as_string(daily_path)
    daily.configure(Store.new(daily_path))
    check(not daily.record_writable and daily.last_error.contains("incompatível"),
        "unknown daily version blocked with visible warning")
    check(daily.select_mode("daily","2026-10-14"),"user can select a daily label")
    daily.begin_run()
    check(not daily.record_result(5,30,true),"cannot overwrite future daily records")
    check(FileAccess.get_file_as_string(daily_path)==future_daily,
        "future daily data preserved")
    _clean(daily_path)
    _bad_file(daily_path)
    var invalid_daily := FileAccess.get_file_as_string(daily_path)
    daily.configure(Store.new(daily_path))
    check(not daily.record_writable and daily.last_error.contains("ilegíveis"),
        "corrupt daily records block disk writes")
    daily.select_mode("daily","2026-10-14")
    daily.begin_run()
    check(not daily.record_result(1,1,false)
        and FileAccess.get_file_as_string(daily_path)==invalid_daily,
        "invalid daily file not overwritten")
    _clean(daily_path)
    daily.configure(Store.new(daily_path))
    check(daily.record_writable and daily.select_mode("daily","2026-10-14"),
        "brand-new daily save remains writable")
    daily.begin_run()
    check(daily.record_result(2,3,false),"valid daily data still persists")
    check(Store.new(daily_path).read_json()["days"]["2026-10-14"]["attempts"]==1,
        "daily counter persisted exactly once")

    check(Store.new(journal_path).write_json({"version":777,"counts":{"apprentice":1000}}),
        "future bestiary data fixture persisted")
    var future_journal := FileAccess.get_file_as_string(journal_path)
    journal.configure(Store.new(journal_path))
    check(not journal.journal_writable and journal.last_error.contains("incompatível"),
        "future bestiary version protected")
    journal.begin_run(7)
    check(not journal.record_cube("apprentice",7,1),"new discovery cannot overwrite future save")
    check(FileAccess.get_file_as_string(journal_path)==future_journal,
        "future bestiary bytes unchanged")
    _clean(journal_path)
    _bad_file(journal_path)
    var invalid_journal := FileAccess.get_file_as_string(journal_path)
    journal.configure(Store.new(journal_path))
    check(not journal.journal_writable and journal.last_error.contains("ilegível"),
        "corrupted bestiary save blocks disk writes")
    journal.begin_run(8)
    check(not journal.record_cube("apprentice",8,1)
        and FileAccess.get_file_as_string(journal_path)==invalid_journal,
        "unreadable bestiary is not silently wiped")
    _clean(journal_path)
    journal.configure(Store.new(journal_path))
    journal.begin_run(9)
    check(journal.journal_writable and journal.record_cube("golden",9,1),
        "new bestiary can record a real discovery")
    check(journal.solved_count("golden")==1,"new discoveries saved normally")
    daily.free()
    journal.free()
    _clean(daily_path)
    _clean(journal_path)
    print("KubRogue audit isolated saves: %d failures" % fails)
    quit(0 if fails==0 else 1)
