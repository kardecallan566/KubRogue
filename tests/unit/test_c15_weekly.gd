extends SceneTree
const Calendar = preload("res://scripts/c15/weekly_calendar.gd")
const Weekly = preload("res://scripts/c15/challenge_service.gd")
const History = preload("res://scripts/c15/history_service.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error("C15 WEEK FAIL: " + message)

func clean(path: String) -> void:
    for s in ["",".bak",".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path+s))

func _run() -> void:
    var daily_path := "user://c15_unit_daily.json"
    var weekly_path := "user://c15_unit_weekly.json"
    var history_path := "user://c15_unit_history.json"
    for p in [daily_path,weekly_path,history_path]:
        clean(p)
    check(Calendar.week_key("2026-10-12")=="2026-10-12"
        and Calendar.week_key("2026-10-16")=="2026-10-12"
        and Calendar.week_key("2026-10-18")=="2026-10-12",
        "Monday through Sunday share the same key")
    check(Calendar.week_key("2026-10-19")=="2026-10-19"
        and Calendar.week_key("2027-01-01")=="2026-12-28",
        "week rollover and year rollover are UTC deterministic")
    check(Calendar.week_key("2026-02-29")=="" and Calendar.week_key("2028-02-29")=="2028-02-28",
        "reject impossible dates and honor leap year")
    check(Calendar.week_key("2026-13-01").is_empty()
        and Calendar.weekly_seed("2026-10-13")==0,
        "invalid week keys cannot produce a seed")
    var service: Weekly = Weekly.new()
    service.configure(Store.new(daily_path))
    service.configure_weekly(Store.new(weekly_path))
    check(service.select_mode("weekly","2026-10-16"),"select weekly on a Friday")
    check(service.active_date=="2026-10-12"
        and service.active_mode=="weekly","week captures Monday at mode selection")
    var seed := service.begin_run()
    check(seed>0 and seed==Calendar.weekly_seed("2026-10-12")
        and service.current_label().contains("SEMANAL"),"weekly seed and HUD label")
    check(service.record_result(3,13,false),"first weekly attempt")
    check(not service.record_result(5,20,true),"cannot double-record same run")
    check(service.record_for_week("2026-10-12")["attempts"]==1,
        "idempotent persisted weekly attempts")
    check(service.begin_run()==seed and service.record_result(5,25,true),
        "new run, same week, identical seed")
    var rec: Dictionary = service.record_for_week("2026-10-12")
    check(rec["attempts"]==2 and rec["wins"]==1
        and rec["best_wave"]==5 and rec["best_cubes"]==25,
        "best records and victory count")
    check(not FileAccess.file_exists(daily_path),
        "weekly mode never writes the daily v1 save")
    var restored: Weekly = Weekly.new()
    restored.configure(Store.new(daily_path))
    restored.configure_weekly(Store.new(weekly_path))
    check(restored.record_for_week("2026-10-12")["attempts"]==2,
        "weekly records survive reboot")
    check(restored.select_mode("daily","2026-10-16"),"original daily still works")
    check(restored.begin_run()==restored.daily_seed("2026-10-16"),
        "C6 daily seed was not changed")
    check(restored.record_result(2,4,false),"daily record saves separately")
    check(Store.new(daily_path).read_json()["days"].has("2026-10-16"),
        "daily schema and file unchanged")
    var day_bytes := FileAccess.get_file_as_string(daily_path)
    var weekly_bytes := FileAccess.get_file_as_string(weekly_path)
    var snapshot := {
        "run_id":1,"result":"victory","mode":"weekly",
        "date":"2026-10-12","wave":5,"seed":seed,
        "stability":75,"contracts":2,"combo":5,"coins":10
    }
    var history: History = History.new()
    history.configure(Store.new(history_path))
    check(history.record_finish(snapshot),"v1 history accepts valid weekly result")
    check(history.latest()["mode"]=="weekly" and history.latest()["date"]=="2026-10-12"
        and history.latest()["medal"]=="gold",
        "weekly mode/date preserved with same medal rules")
    check(not history.record_finish({
        "run_id":2,"result":"victory","mode":"weekly","date":"2026-10-13"
    }),"history rejects a non-Monday weekly date")
    var reload: History = History.new()
    reload.configure(Store.new(history_path))
    check(reload.latest()["mode"]=="weekly" and reload.runs.size()==1,
        "old history schema reloads weekly mode without migration")
    check(FileAccess.get_file_as_string(daily_path)==day_bytes
        and FileAccess.get_file_as_string(weekly_path)==weekly_bytes,
        "history never mutates daily or weekly records")
    clean(weekly_path)
    var unknown := {"version":98,"weeks":{"2026-10-12":{"attempts":500}}}
    check(Store.new(weekly_path).write_json(unknown),"future fixture")
    var future_bytes := FileAccess.get_file_as_string(weekly_path)
    restored.configure_weekly(Store.new(weekly_path))
    check(not restored.weekly_writable and not restored.weekly_error.is_empty(),
        "future weekly version stays write-protected")
    check(restored.select_mode("weekly","2026-10-16"),"select mode while locked")
    restored.begin_run()
    check(not restored.record_result(5,20,true)
        and FileAccess.get_file_as_string(weekly_path)==future_bytes,
        "protected file never overwritten")
    service.free()
    restored.free()
    history.free()
    reload.free()
    for p in [daily_path,weekly_path,history_path]:
        clean(p)
    print("KubRogue C15 weekly mode unit: %d failures" % failures)
    quit(0 if failures==0 else 1)
