extends "res://scripts/c6/challenge_service.gd"
## A third offline session mode. C6 daily records are left byte-for-byte alone.
const Calendar = preload("res://scripts/c15/weekly_calendar.gd")
const WeeklyStore = preload("res://scripts/c4/save_store.gd")
const WEEK_VERSION := 1
const MAX_WEEKS := 52
var weekly_store: WeeklyStore
var weekly_records: Dictionary = {}
var weekly_writable := true
var weekly_error := ""

func _ready() -> void:
    super._ready()
    if weekly_store == null:
        configure_weekly(WeeklyStore.new("user://kubrogue_weekly_v1.json"))

func configure_weekly(adapter: WeeklyStore) -> void:
    weekly_store = adapter
    weekly_records.clear()
    weekly_writable = true
    weekly_error = ""
    var raw: Dictionary = weekly_store.read_json()
    if raw.is_empty() and (FileAccess.file_exists(weekly_store.path)
            or FileAccess.file_exists(weekly_store.path+".bak")):
        weekly_writable = false
        weekly_error = "Recordes semanais ilegíveis. Arquivo original protegido."
    elif not raw.is_empty() and int(raw.get("version",0)) != WEEK_VERSION:
        weekly_writable = false
        weekly_error = "Recordes semanais de outra versão. Arquivo preservado."
    elif not raw.is_empty():
        var entries: Variant = raw.get("weeks",{})
        if entries is Dictionary:
            var keys: Array = entries.keys()
            keys.sort()
            for value in keys.slice(-MAX_WEEKS):
                var key := String(value)
                var rec: Variant = entries[value]
                if Calendar.week_key(key) != key or not (rec is Dictionary):
                    continue
                weekly_records[key] = {
                    "attempts":_clamp_count(rec.get("attempts",0),1000000),
                    "wins":_clamp_count(rec.get("wins",0),1000000),
                    "best_wave":_clamp_count(rec.get("best_wave",0),5),
                    "best_cubes":_clamp_count(rec.get("best_cubes",0),1000000)
                }
    records_changed.emit()

func current_week() -> String:
    return Calendar.week_key(utc_day())

func weekly_seed(monday: String) -> int:
    return Calendar.weekly_seed(monday)

func select_mode(mode: String, date_override: String = "") -> bool:
    if mode != "weekly":
        return super.select_mode(mode,date_override)
    var selected := date_override if not date_override.is_empty() else utc_day()
    var monday := Calendar.week_key(selected)
    if monday.is_empty():
        return false
    active_mode = "weekly"
    active_date = monday
    run_started = false
    return true

func begin_run() -> int:
    if active_mode != "weekly":
        return super.begin_run()
    serial += 1
    recorded_serial = -1
    run_started = true
    run_seed = Calendar.weekly_seed(active_date)
    return run_seed

func record_result(wave: int, cubes: int, victory: bool) -> bool:
    if active_mode != "weekly":
        return super.record_result(wave,cubes,victory)
    if not run_started or recorded_serial == serial or not weekly_writable or weekly_store == null:
        return false
    var current: Dictionary = record_for_week(active_date)
    current["attempts"] = mini(1000000,int(current["attempts"])+1)
    current["wins"] = mini(1000000,int(current["wins"])+(1 if victory else 0))
    current["best_wave"] = maxi(int(current["best_wave"]),clampi(wave,0,5))
    current["best_cubes"] = maxi(int(current["best_cubes"]),clampi(cubes,0,1000000))
    var next: Dictionary = weekly_records.duplicate(true)
    next[active_date] = current
    var keys: Array = next.keys()
    keys.sort()
    while keys.size() > MAX_WEEKS:
        next.erase(keys.pop_front())
    if not weekly_store.write_json({"version":WEEK_VERSION,"weeks":next}):
        weekly_error = "Não foi possível salvar o desafio semanal."
        return false
    weekly_records = next
    weekly_error = ""
    recorded_serial = serial
    records_changed.emit()
    return true

func record_for_week(monday: String) -> Dictionary:
    return weekly_records.get(monday,{
        "attempts":0,"wins":0,"best_wave":0,"best_cubes":0
    }).duplicate(true)

func current_label() -> String:
    if active_mode == "weekly":
        return "DESAFIO SEMANAL %s  ·  SEED %d" % [active_date,run_seed]
    return super.current_label()
