extends "res://scripts/c2/wave_director.gd"
class_name KubRogueC3Director
## Five-wave arcade roguelite including guaranteed 3x3 elite in wave 5.
## Before the elite, only three common slots may fill; slot four is reserved.
const Build = preload("res://scripts/c3/run_build.gd")
const C3_WAVES := [
    {"duration":45.0, "types":["apprentice","apprentice","apprentice","apprentice","apprentice"]},
    {"duration":55.0, "types":["apprentice","reinforced","apprentice","apprentice","reinforced","apprentice","apprentice","apprentice"]},
    {"duration":65.0, "types":["apprentice","reinforced","apprentice","reinforced","apprentice","reinforced","apprentice","apprentice","apprentice"]},
    {"duration":70.0, "types":["apprentice","reinforced","apprentice","reinforced","apprentice","apprentice","reinforced","apprentice","reinforced","apprentice","reinforced"]},
    {"duration":90.0, "types":["apprentice","reinforced","apprentice","reinforced","apprentice","reinforced","apprentice","reinforced","apprentice"]}
]
const BOSS_WAVE := 4
const ELITE_DUE := 18.0
const ELITE_LATEST := 20.0
var build: Build
var elite_spawned := false
var elite_resolved := false
var boss_actor_id := -1
var wave_start_duration := 0.0

func _init(upgrades = null) -> void:
    waves = C3_WAVES.duplicate(true)
    build = upgrades if upgrades != null else Build.new()
    build.reset()

func start_run() -> void:
    super.start_run()
    elite_spawned = false
    elite_resolved = false
    boss_actor_id = -1

func begin_next_wave() -> bool:
    var result: bool = super.begin_next_wave()
    if result:
        elite_spawned = false
        elite_resolved = false
        boss_actor_id = -1
        # The time card only affects waves that start AFTER selection.
        if wave_index > 0:
            time_left += build.time_bonus()
        wave_start_duration = time_left
    return result

func total_expected() -> int:
    return super.total_expected() + (1 if wave_index == BOSS_WAVE else 0)

func pending_count() -> int:
    var normal_total: int = super.total_expected()
    return maxi(0, normal_total - next_spawn_index) + (
        1 if wave_index == BOSS_WAVE and not elite_spawned else 0
    )

func _boss_due() -> bool:
    if wave_index != BOSS_WAVE or elite_spawned:
        return false
    var elapsed: float = wave_start_duration - time_left
    return elapsed >= ELITE_DUE

func can_spawn() -> bool:
    if phase != Phase.RUNNING or time_left <= 0.0:
        return false
    var elapsed: float = wave_start_duration - time_left if wave_index == BOSS_WAVE else 0.0
    if _boss_due():
        return active.size() < MAX_ACTIVE and (spawn_clock >= SPAWN_INTERVAL or elapsed >= ELITE_LATEST)
    var max_common := 3 if wave_index == BOSS_WAVE and not elite_spawned else MAX_ACTIVE
    return spawn_clock >= SPAWN_INTERVAL and active.size() < max_common and next_spawn_index < super.total_expected()

func spawn_next() -> Dictionary:
    if not can_spawn():
        return {}
    if _boss_due():
        var elite_id := next_actor_id
        next_actor_id += 1
        active[elite_id] = "elite"
        wave_spawned += 1
        spawn_clock = 0.0
        elite_spawned = true
        boss_actor_id = elite_id
        return {"id": elite_id, "kind": "elite"}
    # Parent checks virtual can_spawn, and normal queue ordering remains stable.
    return super.spawn_next()

func resolve_cube(id: int) -> Dictionary:
    if phase != Phase.RUNNING or not active.has(id):
        return {}
    var kind: String = active[id]
    var reward: Dictionary = wallet.award(id, kind, money_modifier)
    if reward.is_empty():
        return {}
    active.erase(id)
    wave_resolved += 1
    if kind == "elite":
        elite_resolved = true
    return reward

var money_modifier := 0.0

func finish_wave() -> Dictionary:
    var result: Dictionary = super.finish_wave()
    if result.is_empty():
        return result
    # Death at stability 0 wins over recovery. Only surviving runs can heal.
    var heal := 0
    if stability > 0:
        heal = mini(INITIAL_STABILITY - stability, build.stability_heal())
        stability += heal
        last_summary["stability"] = stability
        last_summary["healed"] = heal
    if wave_index == BOSS_WAVE and not elite_resolved:
        phase = Phase.DEFEAT
        last_summary["elite_required"] = true
    return last_summary.duplicate(true)
