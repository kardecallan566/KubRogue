extends Node
## C6 mode/session and isolated personal daily records.
## Does not mutate or migrate C4 wallets/upgrades. All daily dates are UTC.
signal records_changed
const Store = preload("res://scripts/c4/save_store.gd")
const SAVE_SCHEMA := 1
const MAX_DAYS := 120
var store: Store
var records: Dictionary = {}
var active_mode := "normal"
var active_date := ""
var run_seed := 2026
var serial := 0
var recorded_serial := -1
var run_started := false
var last_error := ""
var record_writable := true

func _ready() -> void:
    if store == null:
        configure(Store.new("user://kubrogue_daily_v1.json"))

func configure(adapter: Store) -> void:
    store = adapter
    records.clear()
    last_error = ""
    record_writable = true
    var raw: Dictionary = store.read_json()
    if raw.is_empty() and (FileAccess.file_exists(store.path) or FileAccess.file_exists(store.path + ".bak")):
        record_writable = false
        last_error = "Recordes diários ilegíveis: arquivo original preservado."
    elif not raw.is_empty() and int(raw.get("version", 0)) != SAVE_SCHEMA:
        record_writable = false
        last_error = "Recordes diários de uma versão incompatível: arquivo preservado."
    var entries: Variant = raw.get("days", {})
    if entries is Dictionary and int(raw.get("version", 0)) == SAVE_SCHEMA:
        var keys: Array = entries.keys()
        keys.sort()
        for k in keys.slice(-MAX_DAYS):
            var key := String(k)
            var value: Variant = entries[k]
            if not valid_day(key) or not (value is Dictionary):
                continue
            records[key] = {
                "attempts": _clamp_count(value.get("attempts", 0), 1000000),
                "wins": _clamp_count(value.get("wins", 0), 1000000),
                "best_wave": _clamp_count(value.get("best_wave", 0), 5),
                "best_cubes": _clamp_count(value.get("best_cubes", 0), 1000000)
            }
    active_mode = "normal"
    active_date = ""
    run_seed = 2026
    run_started = false
    recorded_serial = -1
    records_changed.emit()

func _clamp_count(v: Variant, top: int) -> int:
    if not (v is float or v is int):
        return 0
    return clampi(int(v), 0, top)

func valid_day(value: String) -> bool:
    if value.length() != 10 or value.substr(4, 1) != "-" or value.substr(7, 1) != "-":
        return false
    var compact := value.replace("-", "")
    if not compact.is_valid_int():
        return false
    var year := int(value.substr(0, 4))
    var month := int(value.substr(5, 2))
    var day := int(value.substr(8, 2))
    if year < 2025 or year > 9999 or month < 1 or month > 12:
        return false
    var days_in_month := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    var max_days: int = days_in_month[month - 1]
    var leap_year := year % 4 == 0 and (year % 100 != 0 or year % 400 == 0)
    if month == 2 and leap_year:
        max_days = 29
    return day >= 1 and day <= max_days

func utc_day() -> String:
    return Time.get_date_string_from_system(true)

func daily_seed(date_text: String) -> int:
    if not valid_day(date_text):
        return 0
    # Pure arithmetic, stable between Windows/Linux and across restarts.
    var digits := int(date_text.replace("-", ""))
    return (digits * 97 + 607) % 2147483647

func select_mode(mode: String, date_override: String = "") -> bool:
    if mode != "normal" and mode != "daily":
        return false
    var date_text := date_override if not date_override.is_empty() else utc_day()
    if mode == "daily" and not valid_day(date_text):
        return false
    active_mode = mode
    active_date = date_text if mode == "daily" else ""
    run_started = false
    return true

func begin_run() -> int:
    # The daily identity is captured at the hub, not recalculated at midnight.
    serial += 1
    recorded_serial = -1
    run_started = true
    run_seed = daily_seed(active_date) if active_mode == "daily" else randi_range(1, 2147483000)
    return run_seed

func record_result(wave: int, cubes: int, victory: bool) -> bool:
    if not run_started or recorded_serial == serial:
        return false
    if active_mode != "daily":
        recorded_serial = serial
        return true
    if not record_writable:
        return false
    var current: Dictionary = records.get(active_date, {
        "attempts":0, "wins":0, "best_wave":0, "best_cubes":0
    }).duplicate(true)
    current["attempts"] = mini(1000000, int(current["attempts"]) + 1)
    current["wins"] = mini(1000000, int(current["wins"]) + (1 if victory else 0))
    current["best_wave"] = maxi(int(current["best_wave"]), clampi(wave, 0, 5))
    current["best_cubes"] = maxi(int(current["best_cubes"]), clampi(cubes, 0, 1000000))
    var next := records.duplicate(true)
    next[active_date] = current
    var ordered: Array = next.keys()
    ordered.sort()
    while ordered.size() > MAX_DAYS:
        next.erase(ordered.pop_front())
    if store == null or not store.write_json({"version": SAVE_SCHEMA, "days": next}):
        last_error = "Não foi possível salvar seu recorde diário."
        return false
    records = next
    recorded_serial = serial
    last_error = ""
    records_changed.emit()
    return true

func record_for(day_text: String) -> Dictionary:
    return records.get(day_text, {
        "attempts":0, "wins":0, "best_wave":0, "best_cubes":0
    }).duplicate(true)

func current_label() -> String:
    if active_mode == "daily":
        return "DESAFIO %s  ·  SEED %d" % [active_date, run_seed]
    return "MODO NORMAL  ·  SEED %d" % run_seed
