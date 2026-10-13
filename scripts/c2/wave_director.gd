extends RefCounted
class_name KubRogueWaveDirector
## Small deterministic C2 wave planner, independent from visuals and frame rate.
## The 5-wave roguelite + 3x3 boss will be built in C3.
const Wallet = preload("res://scripts/c2/run_wallet.gd")
const MAX_ACTIVE := 4
const SPAWN_INTERVAL := 2.1
const MISSED_PENALTY := 25
const INITIAL_STABILITY := 100

enum Phase {IDLE, RUNNING, BETWEEN, VICTORY, DEFEAT}
const WAVES := [
    {"duration": 42.0, "types": ["apprentice", "apprentice", "reinforced", "apprentice", "apprentice", "reinforced"]},
    {"duration": 55.0, "types": ["apprentice", "reinforced", "apprentice", "reinforced", "apprentice", "reinforced", "apprentice", "reinforced"]}
]
var waves: Array = WAVES.duplicate(true)
var phase: Phase = Phase.IDLE
var wallet = Wallet.new()
var wave_index := -1
var time_left := 0.0
var spawn_clock := 0.0
var next_spawn_index := 0
var next_actor_id := 1
var active: Dictionary = {}  # id -> kind, only actual spawned actors
var wave_spawned := 0
var wave_resolved := 0
var stability := INITIAL_STABILITY
var last_summary: Dictionary = {}

func start_run() -> void:
    wallet.reset()
    stability = INITIAL_STABILITY
    wave_index = -1
    time_left = 0.0
    next_actor_id = 1
    last_summary = {}
    active.clear()
    phase = Phase.IDLE
    begin_next_wave()

func begin_next_wave() -> bool:
    if phase != Phase.IDLE and phase != Phase.BETWEEN:
        return false
    if wave_index + 1 >= waves.size():
        return false
    wave_index += 1
    var definition: Dictionary = waves[wave_index]
    time_left = float(definition["duration"])
    spawn_clock = SPAWN_INTERVAL   # first spawn can appear immediately
    next_spawn_index = 0
    wave_spawned = 0
    wave_resolved = 0
    active.clear()
    phase = Phase.RUNNING
    return true

func definition() -> Dictionary:
    if wave_index < 0 or wave_index >= waves.size():
        return {}
    return waves[wave_index]

func total_expected() -> int:
    if definition().is_empty():
        return 0
    var types: Array = definition()["types"]
    return types.size()

func pending_count() -> int:
    return maxi(0, total_expected() - next_spawn_index)

func tick(delta: float) -> void:
    if phase != Phase.RUNNING:
        return
    var elapsed := maxf(0.0, delta)
    time_left = maxf(0.0, time_left - elapsed)
    spawn_clock += elapsed

func can_spawn() -> bool:
    return phase == Phase.RUNNING and time_left > 0.0 and spawn_clock >= SPAWN_INTERVAL and active.size() < MAX_ACTIVE and pending_count() > 0

func spawn_next() -> Dictionary:
    if not can_spawn():
        return {}
    var kind: String = definition()["types"][next_spawn_index]
    var id := next_actor_id
    next_actor_id += 1
    next_spawn_index += 1
    spawn_clock = 0.0
    active[id] = kind
    wave_spawned += 1
    return {"id": id, "kind": kind}

func resolve_cube(id: int) -> Dictionary:
    if phase != Phase.RUNNING or not active.has(id):
        return {}
    var kind: String = active[id]
    var reward: Dictionary = wallet.award(id, kind)
    if reward.is_empty():
        return {}
    active.erase(id)
    wave_resolved += 1
    return reward

func ready_to_finish() -> bool:
    return phase == Phase.RUNNING and (
        time_left <= 0.0 or (pending_count() == 0 and active.is_empty())
    )

func finish_wave() -> Dictionary:
    if not ready_to_finish():
        return {}
    # Only cubes that actually appeared can punish the player. Unseen queued
    # spawns are tracked separately; no coins are earned for them.
    var unresolved := active.size()
    var unseen := pending_count()
    stability = maxi(0, stability - unresolved * MISSED_PENALTY)
    last_summary = {
        "wave": wave_index + 1,
        "expected": total_expected(),
        "spawned": wave_spawned,
        "resolved": wave_resolved,
        "unresolved": unresolved,
        "unseen": unseen,
        "penalty": unresolved * MISSED_PENALTY,
        "stability": stability,
        "coins": wallet.coins,
        "xp": wallet.xp
    }
    active.clear()
    if stability <= 0:
        phase = Phase.DEFEAT
    elif wave_index == waves.size() - 1:
        phase = Phase.VICTORY
    else:
        phase = Phase.BETWEEN
    return last_summary.duplicate(true)

func is_finished() -> bool:
    return phase == Phase.DEFEAT or phase == Phase.VICTORY
