extends Node
class_name KubRogueProgress
## Single source of persistent truth for C4. No online service, ads or accounts.
signal progress_changed
const Store = preload("res://scripts/c4/save_store.gd")
const SCHEMA := 1
const MAX_COINS := 1000000000
const PRICES := {
    "hand_training": [200, 500, 1200],
    "cubist_pocket": [250, 650, 1300],
    "stable_field": [300, 800, 1600]
}
const UPGRADE_NAMES := {
    "hand_training": "Treino da mão",
    "cubist_pocket": "Bolso do cubista",
    "stable_field": "Arena estável"
}
const UPGRADE_DESCRIPTIONS := {
    "hand_training": "Reduz o intervalo entre giros em 4% por nível",
    "cubist_pocket": "Aumenta as moedas por cubo em 5% por nível",
    "stable_field": "Aumenta estabilidade inicial e máxima em 5 por nível"
}
const DEFAULT_SETTINGS := {
    "music_volume": 0.80,
    "effects_volume": 0.85,
    "reduced_particles": false,
    "screen_shake": false
}
var store: Store
var data: Dictionary = {}
var last_error := ""

func _ready() -> void:
    if store == null:
        configure(Store.new())

func configure(custom_store: Store) -> void:
    store = custom_store
    data = _defaults()
    var loaded: Dictionary = store.read_json()
    if not loaded.is_empty():
        data = _sanitize(loaded)
    last_error = ""
    progress_changed.emit()

func _defaults() -> Dictionary:
    return {
        "schema_version": SCHEMA,
        "coins": 0,
        "meta": {"hand_training": 0, "cubist_pocket": 0, "stable_field": 0},
        "records": {"best_wave": 0, "best_solved": 0, "best_combo": 0},
        "settings": DEFAULT_SETTINGS.duplicate(true),
        "tutorial_completed": false,
        "run_number": 0,
        "paid_ids": []
    }

func _safe_int(value: Variant, lower: int, upper: int, fallback: int) -> int:
    if not (value is int or value is float):
        return fallback
    var n := int(value)
    if n < lower or n > upper:
        return fallback
    return n

func _sanitize(raw: Dictionary) -> Dictionary:
    var normalized := _defaults()
    if _safe_int(raw.get("schema_version"), 0, 1000, -1) != SCHEMA:
        last_error = "Save incompatível: mantendo progresso padrão nesta sessão."
        return normalized
    normalized["coins"] = _safe_int(raw.get("coins"), 0, MAX_COINS, 0)
    var meta: Dictionary = raw.get("meta", {}) if raw.get("meta", {}) is Dictionary else {}
    for key in PRICES:
        normalized["meta"][key] = _safe_int(meta.get(key), 0, 3, 0)
    var records: Dictionary = raw.get("records", {}) if raw.get("records", {}) is Dictionary else {}
    for key in normalized["records"]:
        normalized["records"][key] = _safe_int(records.get(key), 0, 1000000, 0)
    var settings: Dictionary = raw.get("settings", {}) if raw.get("settings", {}) is Dictionary else {}
    for key in ["music_volume", "effects_volume"]:
        var amount: Variant = settings.get(key, DEFAULT_SETTINGS[key])
        normalized["settings"][key] = clampf(float(amount), 0.0, 1.0) if (amount is int or amount is float) else DEFAULT_SETTINGS[key]
    for key in ["reduced_particles", "screen_shake"]:
        var flag: Variant = settings.get(key, DEFAULT_SETTINGS[key])
        normalized["settings"][key] = flag if flag is bool else DEFAULT_SETTINGS[key]
    normalized["tutorial_completed"] = raw.get("tutorial_completed", false) == true
    normalized["run_number"] = _safe_int(raw.get("run_number"), 0, MAX_COINS, 0)
    var paid: Variant = raw.get("paid_ids", [])
    if paid is Array:
        for item in paid:
            if item is int and item > 0 and item < 10000 and normalized["paid_ids"].size() < 1000:
                if not normalized["paid_ids"].has(item):
                    normalized["paid_ids"].append(item)
    return normalized

func _commit(next_data: Dictionary) -> bool:
    if store == null or not store.write_json(next_data):
        last_error = "Não foi possível salvar no disco; nenhuma compra ou moeda nova foi confirmada."
        return false
    data = next_data
    last_error = ""
    progress_changed.emit()
    return true

func balance() -> int:
    return int(data.get("coins", 0))

func meta_level(id: String) -> int:
    if not PRICES.has(id):
        return 0
    return int(data.get("meta", {}).get(id, 0))

func next_cost(id: String) -> int:
    if not PRICES.has(id):
        return -1
    var level := meta_level(id)
    if level >= 3:
        return -1
    return int(PRICES[id][level])

func purchase(id: String) -> bool:
    var price := next_cost(id)
    if price < 0 or balance() < price:
        return false
    var candidate := data.duplicate(true)
    candidate["coins"] = balance() - price
    candidate["meta"][id] = meta_level(id) + 1
    return _commit(candidate)

func begin_run() -> bool:
    var candidate := data.duplicate(true)
    candidate["run_number"] = int(candidate["run_number"]) + 1
    candidate["paid_ids"] = []
    return _commit(candidate)

func credit_cube(cube_id: int, coins: int) -> bool:
    if cube_id <= 0 or coins <= 0 or coins > 100000 or data["paid_ids"].has(cube_id):
        return false
    if balance() + coins > MAX_COINS or data["paid_ids"].size() >= 1000:
        return false
    var candidate := data.duplicate(true)
    candidate["paid_ids"].append(cube_id)
    candidate["coins"] = balance() + coins
    return _commit(candidate)

func update_record(best_wave: int, resolved: int, combo: int) -> bool:
    var next_data := data.duplicate(true)
    for entry in [{"key":"best_wave","value":best_wave},
                  {"key":"best_solved","value":resolved},
                  {"key":"best_combo","value":combo}]:
        var key: String = entry["key"]
        next_data["records"][key] = maxi(int(next_data["records"][key]), maxi(0, int(entry["value"])))
    if next_data["records"] == data["records"]:
        return true
    return _commit(next_data)

func finish_tutorial() -> bool:
    if data.get("tutorial_completed", false):
        return true
    var next_data := data.duplicate(true)
    next_data["tutorial_completed"] = true
    return _commit(next_data)

func set_setting(id: String, value: Variant) -> bool:
    if not DEFAULT_SETTINGS.has(id):
        return false
    var normalized: Variant = value
    if id == "music_volume" or id == "effects_volume":
        if not (value is float or value is int):
            return false
        normalized = clampf(float(value), 0.0, 1.0)
    elif not (value is bool):
        return false
    var next_data := data.duplicate(true)
    next_data["settings"][id] = normalized
    return _commit(next_data)

func stability_max() -> int:
    return 100 + meta_level("stable_field") * 5

func cooldown_reduction() -> float:
    return 0.04 * meta_level("hand_training")

func coin_bonus() -> float:
    return 0.05 * meta_level("cubist_pocket")
