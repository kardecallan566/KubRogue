extends SceneTree
const Challenge = preload("res://scripts/c6/challenge_service.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var fails := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    if not ok:
        fails += 1
        push_error("AUDIT CALENDAR FAIL: " + label)

func _clean(p: String) -> void:
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(p + suffix))

func _run() -> void:
    var path := "user://audit_calendar.json"
    _clean(path)
    var d: Challenge = Challenge.new()
    d.configure(Store.new(path))
    for date_text in ["2026-02-28","2028-02-29","2026-04-30",
            "2026-12-31","2400-02-29","2100-02-28"]:
        check(d.valid_day(date_text) and d.daily_seed(date_text)>0,
            "valid Gregorian date " + date_text)
    for bad in ["2026-02-29","2026-02-30","2026-02-31","2026-04-31",
            "2026-06-31","2026-11-31","2100-02-29","2026-13-01",
            "2026-00-12","2026-12-00","2026-12-32","2030-01-abc"]:
        check(not d.valid_day(bad) and d.daily_seed(bad)==0,
            "invalid calendar date rejected " + bad)
        check(not d.select_mode("daily",bad),
            "cannot start a daily challenge on a phantom date " + bad)
    check(d.select_mode("daily","2028-02-29"),"leap-day selection works")
    var seed: int = d.begin_run()
    check(seed==d.daily_seed("2028-02-29"),"existing deterministic seed formula unchanged")
    check(d.record_result(5,20,true),"leap-day record saved")
    var again: Challenge = Challenge.new()
    again.configure(Store.new(path))
    check(again.record_for("2028-02-29")["wins"] == 1,"leap record reloads")
    check(again.select_mode("daily","2028-02-29") and again.begin_run()==seed,
        "same UTC day gives same seed after restart")
    d.free()
    again.free()
    _clean(path)
    print("KubRogue audit Gregorian calendar: %d failures" % fails)
    quit(0 if fails==0 else 1)
