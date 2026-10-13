extends RefCounted
class_name KubRogueRunBuild
## Eight original run-scoped skills. No monetization or permanent stats in C3.
## Cards are offered immediately after a safe solve, while the world is paused.
const XP_THRESHOLDS := [5, 12, 21, 32, 45]
const MAX_RANK := 3
const CARDS := [
    {"id":"pulso_agil", "name":"Pulso ágil", "tag":"Velocidade", "description":"Menos tempo entre giros", "value":"-8% por nível"},
    {"id":"dedo_certeiro", "name":"Dedo certeiro", "tag":"Precisão", "description":"Uma rotação extra periodicamente", "value":"a cada 7/6/5 ações"},
    {"id":"luva_magnetica", "name":"Luva magnética", "tag":"Alcance", "description":"Amplia o alcance do cursor", "value":"+12% por nível"},
    {"id":"bolsa_encantada", "name":"Bolsa encantada", "tag":"Moedas", "description":"Aumenta o valor de cada solução", "value":"+15% por nível"},
    {"id":"ritmo_mestre", "name":"Ritmo de mestre", "tag":"Combo", "description":"Bônus de moedas após 3 soluções", "value":"+10/15/20%"},
    {"id":"folego_extra", "name":"Fôlego extra", "tag":"Tempo", "description":"Tempo extra em ondas futuras", "value":"+8/12/16 s"},
    {"id":"olhar_cubista", "name":"Olhar de cubista", "tag":"Controle", "description":"Menos giros em reforçados futuros", "value":"-1/2/3 giros"},
    {"id":"mao_paciente", "name":"Mão paciente", "tag":"Defesa", "description":"Recupera estabilidade ao fim da onda", "value":"+5/8/12"}
]
var ranks: Dictionary = {}
var xp_level := 1
var pending := 0
var offers_taken := 0
var move_count := 0
var current_offer: Array[String] = []
var rng := RandomNumberGenerator.new()

func reset(seed_value: int = 2026) -> void:
    ranks.clear()
    for card in CARDS:
        ranks[card["id"]] = 0
    xp_level = 1
    pending = 0
    offers_taken = 0
    move_count = 0
    current_offer.clear()
    rng.seed = seed_value

func rank(id: String) -> int:
    return int(ranks.get(id, 0))

func register_xp(total: int) -> void:
    # Level-ups are cumulative and each threshold produces at most one offer.
    while xp_level <= XP_THRESHOLDS.size() and total >= int(XP_THRESHOLDS[xp_level - 1]):
        xp_level += 1
        pending += 1

func card_data(id: String) -> Dictionary:
    for card in CARDS:
        if String(card["id"]) == id:
            return card
    return {}

func roll_offer() -> Array[String]:
    if pending <= 0:
        return []
    if not current_offer.is_empty():
        return current_offer.duplicate()
    var pool: Array[String] = []
    for card in CARDS:
        var id: String = card["id"]
        if rank(id) < MAX_RANK:
            pool.append(id)
    while current_offer.size() < 3 and not pool.is_empty():
        var idx := rng.randi_range(0, pool.size() - 1)
        current_offer.append(pool[idx])
        pool.remove_at(idx)
    return current_offer.duplicate()

func select_card(id: String) -> bool:
    if pending <= 0 or not current_offer.has(id) or rank(id) >= MAX_RANK:
        return false
    ranks[id] = rank(id) + 1
    pending -= 1
    offers_taken += 1
    current_offer.clear()
    return true

func discard_pending() -> void:
    pending = 0
    current_offer.clear()

func cooldown(base: float = 0.34) -> float:
    return maxf(0.16, base * (1.0 - 0.08 * rank("pulso_agil")))

func reach(base: float = 0.95) -> float:
    return base * (1.0 + 0.12 * rank("luva_magnetica"))

func record_action_bonus_move() -> bool:
    move_count += 1
    var r := rank("dedo_certeiro")
    if r == 0:
        return false
    var each := 8 - r # ranks 1/2/3 -> every 7/6/5 actions
    return move_count % each == 0

func money_bonus(combo: int) -> float:
    var bonus := 0.15 * rank("bolsa_encantada")
    var rhythm := rank("ritmo_mestre")
    if combo >= 3 and rhythm > 0:
        bonus += [0.0, 0.10, 0.15, 0.20][rhythm]
    return minf(bonus, 1.50)

func time_bonus() -> float:
    return float([0, 8, 12, 16][rank("folego_extra")])

func reinforced_reduction() -> int:
    return rank("olhar_cubista")

func stability_heal() -> int:
    return int([0, 5, 8, 12][rank("mao_paciente")])

func active_description() -> String:
    var parts: Array[String] = []
    for card in CARDS:
        var id: String = card["id"]
        if rank(id) > 0:
            parts.append("%s %d" % [String(card["name"]), rank(id)])
    return "  ·  ".join(parts) if not parts.is_empty() else "Sem habilidades"
