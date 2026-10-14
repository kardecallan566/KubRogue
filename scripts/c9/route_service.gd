extends RefCounted
## Checkpoint C9. Reproducible run route decisions between waves.
## No currency mutations and no changes to daily records.
const OPTIONS := [
    {"id":"blitz","title":"CORRIDA RELÂMPAGO","glyph":"⚡",
        "benefit":"+25% moedas nos cubos da próxima onda",
        "risk":"-10 segundos no próximo cronômetro"},
    {"id":"refuge","title":"REFÚGIO DAS FOLHAS","glyph":"♥",
        "benefit":"Recupera 18 pontos de estabilidade",
        "risk":"-8 segundos na próxima onda"},
    {"id":"gilded","title":"TRILHA DOURADA","glyph":"✦",
        "benefit":"Um cubo Aprendiz vira Dourado, pagando mais",
        "risk":"O alvo especial exige mais giros"},
    {"id":"clock","title":"TORRE DO TEMPO","glyph":"◷",
        "benefit":"+12 segundos na próxima onda",
        "risk":"-12 pontos de estabilidade (mínimo 1)"}
]
const LAST_TRANSITION := 3
var seed_value := 0
var offer_wave := -1
var available: Array[String] = []
var choice := ""
var decided := false
var applied := false
var active_id := ""
var active_wave := -1
var last_error := ""

func begin_run(seed: int) -> void:
    seed_value = maxi(1, seed)
    offer_wave = -1
    available.clear()
    choice = ""
    decided = false
    applied = false
    active_id = ""
    active_wave = -1
    last_error = ""

func definition(id: String) -> Dictionary:
    for data in OPTIONS:
        if String(data["id"]) == id:
            return data.duplicate(true)
    return {}

func prepare(completed_wave: int) -> Array[String]:
    if completed_wave < 0 or completed_wave > LAST_TRANSITION:
        return []
    if completed_wave == offer_wave:
        return available.duplicate()
    var random := RandomNumberGenerator.new()
    random.seed = int(seed_value) + int(completed_wave + 1) * 87011
    var ids: Array[String] = []
    for data in OPTIONS:
        ids.append(String(data["id"]))
    for i in range(ids.size()-1,0,-1):
        var j := random.randi_range(0,i)
        var tmp: String = ids[i]
        ids[i] = ids[j]
        ids[j] = tmp
    offer_wave = completed_wave
    available = [ids[0],ids[1]]
    choice = ""
    decided = false
    applied = false
    active_id = ""
    active_wave = -1
    return available.duplicate()

func choose(id: String) -> bool:
    if decided or not available.has(id) or definition(id).is_empty():
        return false
    choice = id
    decided = true
    return true

func skip() -> bool:
    if decided or offer_wave < 0:
        return false
    choice = ""
    decided = true
    return true

func is_pending() -> bool:
    return offer_wave >= 0 and not decided

func apply_next(director) -> bool:
    if not decided or applied or offer_wave < 0 or director.wave_index != offer_wave:
        return false
    applied = true
    active_id = choice
    active_wave = offer_wave + 1
    if choice == "gilded":
        var next_wave: Dictionary = director.waves[active_wave]
        var types: Array = next_wave["types"]
        var found := false
        for i in range(types.size()):
            if String(types[i]) == "apprentice":
                types[i] = "golden"
                found = true
                break
        if not found:
            last_error = "Não há um Aprendiz nesta onda para ser transformado."
    return true

func active_effect(for_wave: int) -> String:
    return active_id if for_wave == active_wave else ""

func time_delta(for_wave: int) -> float:
    match active_effect(for_wave):
        "blitz": return -10.0
        "refuge": return -8.0
        "clock": return 12.0
    return 0.0

func stability_delta(for_wave: int) -> int:
    match active_effect(for_wave):
        "refuge": return 18
        "clock": return -12
    return 0

func coin_bonus(for_wave: int) -> float:
    return 0.25 if active_effect(for_wave) == "blitz" else 0.0

func name_of_active(for_wave: int) -> String:
    var d: Dictionary = definition(active_effect(for_wave))
    return String(d.get("title",""))

func clear_after_wave() -> void:
    active_id = ""
    active_wave = -1
