extends Node
## C8: standalone discovery journal + atomic per-cube run contracts.
## The journal never owns currency. Contract bonuses are included in the SAME
## C4 credit_cube transaction as the resolved cube; no extra payout endpoint.
signal journal_changed
const Store = preload("res://scripts/c4/save_store.gd")
const VERSION := 1
const MAX_EVENTS := 512
const CATALOG := [
    {"id":"apprentice", "name":"Aprendiz 2×2", "dimension":2, "coins":10, "detail":"Primeiros giros no Jardim", "rarity":"COMUM"},
    {"id":"reinforced", "name":"Reforçado 2×2", "dimension":2, "coins":18, "detail":"Exige mais movimentos", "rarity":"INCOMUM"},
    {"id":"golden", "name":"Dourado 2×2", "dimension":2, "coins":32, "detail":"Recompensa valiosa", "rarity":"RARO"},
    {"id":"armored", "name":"Blindado 2×2", "dimension":2, "coins":30, "detail":"Resistente a giros rápidos", "rarity":"RARO"},
    {"id":"elite", "name":"Elite 3×3", "dimension":3, "coins":80, "detail":"Chefe da quinta onda", "rarity":"ÉPICO"},
    {"id":"master4", "name":"Mestre 4×4", "dimension":4, "coins":68, "detail":"Camadas internas desafiadoras", "rarity":"ÉPICO"},
    {"id":"master5", "name":"Titã 5×5", "dimension":5, "coins":110, "detail":"O maior desafio do Jardim", "rarity":"LENDÁRIO"}
]
const CONTRACTS := [
    {"id":"solvers", "title":"Primeiros passos", "detail":"Resolva 4 cubos", "goal":4, "reward":20},
    {"id":"specialist", "title":"Caçador de raros", "detail":"Resolva 2 cubos especiais", "goal":2, "reward":35},
    {"id":"architect", "title":"Mestre das camadas", "detail":"Resolva um 4×4 ou 5×5", "goal":1, "reward":60}
]
var store: Store
var counts: Dictionary = {}
var seen: Array[String] = []
var pending_observations: Dictionary = {}
var last_error := ""
var run_id := 0
var run_active := false
var run_solved := 0
var run_special := 0
var run_large := 0
var run_claimed: Dictionary = {}
var run_events: Dictionary = {}
var run_bonus_total := 0
var last_completions: Array[String] = []

func _ready() -> void:
    if store == null:
        configure(Store.new("user://kubrogue_journal_v1.json"))

func known(kind: String) -> bool:
    for item in CATALOG:
        if String(item["id"]) == kind:
            return true
    return false

func configure(adapter: Store) -> void:
    store = adapter
    counts.clear()
    seen.clear()
    pending_observations.clear()
    last_error = ""
    for item in CATALOG:
        counts[String(item["id"])] = 0
    var raw: Dictionary = store.read_json()
    if int(raw.get("version", 0)) == VERSION:
        var saved: Variant = raw.get("counts", {})
        if saved is Dictionary:
            for key in counts:
                var value: Variant = saved.get(key, 0)
                if value is int or value is float:
                    counts[key] = clampi(int(value), 0, 1000000)
        var recent: Variant = raw.get("seen", [])
        if recent is Array:
            for token in recent:
                if token is String and token.length() <= 40 and not seen.has(token):
                    seen.append(token)
                    if seen.size() > MAX_EVENTS:
                        seen.pop_front()
    reset_run()
    journal_changed.emit()

func reset_run() -> void:
    run_active = false
    run_id = 0
    run_solved = 0
    run_special = 0
    run_large = 0
    run_claimed.clear()
    run_events.clear()
    run_bonus_total = 0
    last_completions.clear()

func begin_run(identity: int) -> void:
    reset_run()
    run_id = identity
    run_active = identity > 0

func _is_special(kind: String) -> bool:
    return kind in ["golden", "armored", "master4", "master5", "elite"]

func _is_large(kind: String) -> bool:
    return kind == "master4" or kind == "master5"

func contract_status() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for contract in CONTRACTS:
        var id: String = contract["id"]
        var value := run_solved if id == "solvers" else (
            run_special if id == "specialist" else run_large)
        result.append({
            "id": id, "title": String(contract["title"]),
            "detail": String(contract["detail"]),
            "progress": mini(value, int(contract["goal"])),
            "goal": int(contract["goal"]), "reward": int(contract["reward"]),
            "complete": run_claimed.has(id)
        })
    return result

func completed_contracts() -> int:
    return run_claimed.size()

func register_solve(kind: String, cube_id: int) -> Dictionary:
    # Called only after director.resolve_cube succeeds; wallet pays base+bonus
    # together. There is no independent contract claim to double-credit.
    if not run_active or not known(kind) or cube_id <= 0 or run_events.has(cube_id):
        return {"bonus": 0, "completed": []}
    run_events[cube_id] = kind
    run_solved += 1
    if _is_special(kind):
        run_special += 1
    if _is_large(kind):
        run_large += 1
    var total := 0
    var finished: Array[String] = []
    for contract in contract_status():
        var id: String = contract["id"]
        if not run_claimed.has(id) and int(contract["progress"]) >= int(contract["goal"]):
            run_claimed[id] = true
            total += int(contract["reward"])
            finished.append(String(contract["title"]))
    run_bonus_total += total
    last_completions = finished
    return {"bonus": total, "completed": finished}

func solved_count(kind: String) -> int:
    return int(counts.get(kind, 0))

func discovery_total() -> int:
    var result := 0
    for kind in counts:
        if int(counts[kind]) > 0:
            result += 1
    return result

func record_cube(kind: String, identity: int, cube_id: int) -> bool:
    if not known(kind) or identity <= 0 or cube_id <= 0:
        return false
    var token := "%d:%d" % [identity, cube_id]
    if seen.has(token):
        return true
    pending_observations[token] = kind
    return flush_observations()

func flush_observations() -> bool:
    if pending_observations.is_empty():
        return true
    var proposed_counts := counts.duplicate(true)
    var proposed_seen: Array[String] = seen.duplicate()
    for token in pending_observations:
        if proposed_seen.has(token):
            continue
        var kind: String = pending_observations[token]
        proposed_counts[kind] = mini(1000000, int(proposed_counts.get(kind, 0)) + 1)
        proposed_seen.append(token)
    while proposed_seen.size() > MAX_EVENTS:
        proposed_seen.pop_front()
    if store == null or not store.write_json({
        "version": VERSION, "counts": proposed_counts, "seen": proposed_seen
    }):
        last_error = "Registro do bestiário indisponível; tentaremos salvar na próxima resolução."
        return false
    counts = proposed_counts
    seen = proposed_seen
    pending_observations.clear()
    last_error = ""
    journal_changed.emit()
    return true
