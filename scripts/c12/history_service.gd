extends Node
## C12: local, independent history for completed runs only.
## No leaderboard, wallet mutation or telemetry. SaveStore protects .bak.
signal history_changed
const Store = preload("res://scripts/c4/save_store.gd")
const VERSION := 1
const MAX_RUNS := 12
var store: Store
var runs: Array[Dictionary] = []
var writable := true
var last_error := ""
var pending_finish: Dictionary = {}

func _ready() -> void:
    if store == null:
        configure(Store.new("user://kubrogue_history_v1.json"))

func configure(adapter: Store) -> void:
    store = adapter
    runs.clear()
    pending_finish.clear()
    writable = true
    last_error = ""
    var raw: Dictionary = store.read_json()
    if raw.is_empty() and (FileAccess.file_exists(store.path) or FileAccess.file_exists(store.path + ".bak")):
        writable = false
        last_error = "Histórico ilegível. Arquivo original protegido contra sobrescrita."
    elif not raw.is_empty() and int(raw.get("version",0)) != VERSION:
        writable = false
        last_error = "Histórico de outra versão. Arquivo original preservado."
    elif not raw.is_empty():
        var saved: Variant = raw.get("runs",[])
        if saved is Array:
            for item in saved:
                if item is Dictionary:
                    var clean: Dictionary = _normalize(item)
                    if not clean.is_empty() and not _contains_id(int(clean["run_id"])):
                        runs.append(clean)
        while runs.size() > MAX_RUNS:
            runs.pop_front()
    history_changed.emit()

func _number(value: Variant, maximum: int) -> int:
    if not (value is int or value is float):
        return 0
    return clampi(int(value),0,maximum)

func _normalize(entry: Dictionary) -> Dictionary:
    var id := _number(entry.get("run_id",0),1000000000)
    var result := String(entry.get("result",""))
    if id <= 0 or result not in ["victory","defeat"]:
        return {}
    var mode := String(entry.get("mode","normal"))
    if mode not in ["normal","daily"]:
        mode = "normal"
    var date := String(entry.get("date","")).substr(0,10)
    var stamp := String(entry.get("finished_at","")).substr(0,25)
    var normalized := {
        "run_id":id, "result":result, "mode":mode,
        "date":date if mode == "daily" else "",
        "seed":_number(entry.get("seed",0),2147483647),
        "finished_at":stamp,
        "wave":_number(entry.get("wave",0),5),
        "cubes":_number(entry.get("cubes",0),1000),
        "coins":_number(entry.get("coins",0),10000000),
        "xp":_number(entry.get("xp",0),1000000),
        "combo":_number(entry.get("combo",0),1000),
        "contracts":_number(entry.get("contracts",0),3),
        "fevers":_number(entry.get("fevers",0),1000),
        "skills":_number(entry.get("skills",0),100),
        "stability":_number(entry.get("stability",0),1000)
    }
    normalized["medal"] = medal_for(normalized)
    return normalized

static func medal_for(run: Dictionary) -> String:
    if String(run.get("result","")) != "victory":
        return "none"
    var stability := int(run.get("stability",0))
    var contracts := int(run.get("contracts",0))
    var combo := int(run.get("combo",0))
    if stability >= 70 and contracts >= 2 and combo >= 4:
        return "gold"
    if stability >= 35:
        return "silver"
    return "bronze"

static func medal_title(key: String) -> String:
    match key:
        "gold": return "OURO  ·  MESTRE DO JARDIM"
        "silver": return "PRATA  ·  CUBISTA EXPERIENTE"
        "bronze": return "BRONZE  ·  CONQUISTADOR"
    return "SEM MEDALHA  ·  NOVA TENTATIVA"

func _contains_id(id: int) -> bool:
    for entry in runs:
        if int(entry["run_id"]) == id:
            return true
    return false

func record_finish(raw: Dictionary) -> bool:
    var item: Dictionary = _normalize(raw)
    if item.is_empty():
        last_error = "Resultado inválido: a partida não foi registrada."
        return false
    if _contains_id(int(item["run_id"])):
        return true
    if not writable:
        return false
    pending_finish = item.duplicate(true)
    return retry_pending()

func retry_pending() -> bool:
    if pending_finish.is_empty():
        return true
    if not writable or store == null:
        return false
    if _contains_id(int(pending_finish["run_id"])):
        pending_finish.clear()
        return true
    var next: Array[Dictionary] = runs.duplicate(true)
    next.append(pending_finish.duplicate(true))
    while next.size() > MAX_RUNS:
        next.pop_front()
    if not store.write_json({"version":VERSION,"runs":next}):
        last_error = "Não foi possível salvar o histórico; tente novamente na hub."
        return false
    runs = next
    pending_finish.clear()
    last_error = ""
    history_changed.emit()
    return true

func latest() -> Dictionary:
    return runs.back().duplicate(true) if not runs.is_empty() else {}

func recent() -> Array[Dictionary]:
    var result: Array[Dictionary] = runs.duplicate(true)
    result.reverse()
    return result

func victories() -> int:
    var count := 0
    for item in runs:
        if String(item["result"]) == "victory":
            count += 1
    return count

func best_by(field: String) -> int:
    if field not in ["wave","cubes","coins","xp","combo","contracts","fevers"]:
        return 0
    var best := 0
    for item in runs:
        best = maxi(best,int(item[field]))
    return best
