extends RefCounted
## C12: fully derived, retroactive Garden Medals.
## Reads the independent C4 best-combo and C8 species journal, never writes
## currency, daily saves, or a new achievements file.
const MEDALS := [
    {"id":"first", "name":"PRIMEIRO GIRO", "glyph":"✦",
        "detail":"Resolva seu primeiro cubo", "kind":"total", "goal":1},
    {"id":"twenty", "name":"MÃO TREINADA", "glyph":"◆",
        "detail":"Resolva 20 cubos ao longo das partidas", "kind":"total", "goal":20},
    {"id":"hundred", "name":"LENDÁRIO DO JARDIM", "glyph":"★",
        "detail":"Resolva 100 cubos ao longo das partidas", "kind":"total", "goal":100},
    {"id":"golden", "name":"BRILHO DO OURO", "glyph":"✧",
        "detail":"Resolva um cubo Dourado", "kind":"golden", "goal":1},
    {"id":"armored", "name":"QUEBRA-ARMADURA", "glyph":"⬟",
        "detail":"Resolva um cubo Blindado", "kind":"armored", "goal":1},
    {"id":"master4", "name":"QUATRO CAMADAS", "glyph":"▣",
        "detail":"Resolva um Mestre 4×4", "kind":"master4", "goal":1},
    {"id":"master5", "name":"CINCO CAMADAS", "glyph":"◈",
        "detail":"Resolva um Titã 5×5", "kind":"master5", "goal":1},
    {"id":"elite", "name":"DERROTE A ELITE", "glyph":"♛",
        "detail":"Resolva o chefe Elite 3×3", "kind":"elite", "goal":1},
    {"id":"collector", "name":"COLECIONADOR", "glyph":"❖",
        "detail":"Descubra três espécies do Bestiário", "kind":"species", "goal":3},
    {"id":"complete", "name":"JARDIM COMPLETO", "glyph":"✿",
        "detail":"Descubra as sete espécies do Bestiário", "kind":"species", "goal":7},
    {"id":"combo4", "name":"RITMO DE FEVER", "glyph":"⚡",
        "detail":"Alcance um combo de quatro cubos", "kind":"combo", "goal":4},
    {"id":"combo8", "name":"RITMO IMPARÁVEL", "glyph":"♜",
        "detail":"Alcance um combo de oito cubos", "kind":"combo", "goal":8}
]
const MASTERY_BRONZE := 5
const MASTERY_SILVER := 20
const MASTERY_GOLD := 50
var announced: Dictionary = {}

func _total(journal) -> int:
    var total := 0
    for species in journal.CATALOG:
        total += journal.solved_count(String(species["id"]))
    return total

func progress(medal: Dictionary, journal, progress_store, combo_now: int = 0) -> int:
    var kind: String = String(medal["kind"])
    match kind:
        "total":
            return _total(journal)
        "species":
            return journal.discovery_total()
        "combo":
            var records: Dictionary = progress_store.data.get("records",{})
            return maxi(combo_now,int(records.get("best_combo",0)))
        _:
            return journal.solved_count(kind)

func unlocked(medal: Dictionary, journal, progress_store, combo_now: int = 0) -> bool:
    return progress(medal,journal,progress_store,combo_now) >= int(medal["goal"])

func trophy_count(journal, progress_store, combo_now: int = 0) -> int:
    var unlocked_count := 0
    for medal in MEDALS:
        if unlocked(medal,journal,progress_store,combo_now):
            unlocked_count += 1
    return unlocked_count

func snapshot(journal, progress_store, combo_now: int = 0) -> void:
    announced.clear()
    for medal in MEDALS:
        if unlocked(medal,journal,progress_store,combo_now):
            announced[String(medal["id"])] = true

func newly_unlocked(journal, progress_store, combo_now: int = 0) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for medal in MEDALS:
        var id: String = String(medal["id"])
        if unlocked(medal,journal,progress_store,combo_now) and not announced.has(id):
            announced[id] = true
            result.append(medal.duplicate(true))
    return result

func mastery_level(count: int) -> int:
    if count >= MASTERY_GOLD:
        return 3
    if count >= MASTERY_SILVER:
        return 2
    if count >= MASTERY_BRONZE:
        return 1
    return 0

func mastery_label(count: int) -> String:
    match mastery_level(count):
        3: return "✦ OURO"
        2: return "◆ PRATA"
        1: return "▣ BRONZE"
    return "SEM MAESTRIA"

func next_mastery_target(count: int) -> int:
    if count < MASTERY_BRONZE:
        return MASTERY_BRONZE
    if count < MASTERY_SILVER:
        return MASTERY_SILVER
    if count < MASTERY_GOLD:
        return MASTERY_GOLD
    return MASTERY_GOLD
