extends RefCounted
## C8.2: run-only upgrades purchased between waves.
## Spend only coins earned during THIS run; debit uses C4 transactional save.
## Does not replace or migrate older saved upgrades.
const CATALOG := [
    {"id":"tempo", "name":"Relógio Extra", "detail":"+10 s na próxima e nas ondas seguintes", "icon":"⏱", "price":30, "max":2},
    {"id":"escudo", "name":"Coração do Jardim", "detail":"+12 estabilidade imediata (até o máximo)", "icon":"♥", "price":25, "max":3},
    {"id":"lucro", "name":"Cubo da Fortuna", "detail":"+10% moedas por cubo até o fim da run", "icon":"✦", "price":45, "max":2},
    {"id":"agilidade", "name":"Mão Veloz", "detail":"Giros 6% mais rápidos nesta run", "icon":"⚡", "price":40, "max":2}
]
var levels: Dictionary = {}
var spent := 0
var purchases := 0
var last_error := ""

func _init() -> void:
    begin_run()

func begin_run() -> void:
    levels.clear()
    for item in CATALOG:
        levels[String(item["id"])] = 0
    spent = 0
    purchases = 0
    last_error = ""

func definition(id: String) -> Dictionary:
    for item in CATALOG:
        if item["id"] == id:
            return item
    return {}

func rank(id: String) -> int:
    return int(levels.get(id, 0))

func price(id: String) -> int:
    var item := definition(id)
    if item.is_empty() or rank(id) >= int(item["max"]):
        return -1
    return int(item["price"]) * (rank(id) + 1)

func available(run_earned: int, balance: int) -> int:
    return mini(maxi(0,run_earned - spent),maxi(0,balance))

func buy(id: String, progress: Node, run_earned: int) -> bool:
    var cost := price(id)
    if cost < 0:
        last_error = "Esta melhoria chegou ao nível máximo."
        return false
    if available(run_earned,progress.balance()) < cost:
        last_error = "Ganhe mais moedas nesta partida para comprar."
        return false
    if not progress.spend_coins(cost):
        last_error = progress.last_error
        return false
    spent += cost
    purchases += 1
    levels[id] = rank(id) + 1
    last_error = ""
    return true

func next_wave_time() -> float:
    return float(rank("tempo")) * 10.0

func coin_bonus() -> float:
    return 0.10 * float(rank("lucro"))

func cooldown_reduction() -> float:
    return 0.06 * float(rank("agilidade"))

func heal_amount() -> int:
    return 12
