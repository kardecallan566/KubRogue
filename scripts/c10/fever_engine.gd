extends RefCounted
## C10: combo pacing is in play-time, never wall-clock. Zero RNG/IO.
## All coins (including fever) still flow through C4 credit_cube once.
const COMBO_WINDOW := 12.0
const START_AT := 4
const FEVER_DURATION := 9.0
const MAX_FEVER_TIME := 12.0
const FEVER_COIN_BONUS := 0.20
const TIME_PER_FEVER_SOLVE := 1.0
const MAX_SECONDS_PER_WAVE := 6.0

var clock := 0.0
var streak := 0
var best_streak := 0
var last_solve_at := -999.0
var fever_remaining := 0.0
var next_milestone := START_AT
var wave_time_given := 0.0
var activations := 0
var solve_events: Dictionary = {}

func begin_run() -> void:
    clock = 0.0
    best_streak = 0
    activations = 0
    reset_wave()

func reset_wave() -> void:
    streak = 0
    last_solve_at = -999.0
    fever_remaining = 0.0
    next_milestone = START_AT
    wave_time_given = 0.0
    solve_events.clear()

func active() -> bool:
    return fever_remaining > 0.001

func tick(delta: float) -> bool:
    if delta <= 0.0:
        return false
    clock += delta
    var was_active := active()
    fever_remaining = maxf(0.0,fever_remaining - delta)
    if streak > 0 and clock - last_solve_at > COMBO_WINDOW:
        streak = 0
        next_milestone = START_AT
    return was_active and not active()

func on_solve(id: int) -> Dictionary:
    if id <= 0 or solve_events.has(id):
        return {}
    solve_events[id] = true
    if streak == 0 or clock - last_solve_at > COMBO_WINDOW:
        streak = 1
        next_milestone = START_AT
    else:
        streak += 1
    last_solve_at = clock
    best_streak = maxi(best_streak,streak)
    var started := false
    var refreshed := false
    if streak >= next_milestone:
        if not active():
            fever_remaining = FEVER_DURATION
            started = true
            activations += 1
        else:
            fever_remaining = minf(MAX_FEVER_TIME,fever_remaining + 3.0)
            refreshed = true
        next_milestone += START_AT
    var seconds := 0.0
    if active() and wave_time_given < MAX_SECONDS_PER_WAVE:
        seconds = minf(TIME_PER_FEVER_SOLVE,MAX_SECONDS_PER_WAVE - wave_time_given)
        wave_time_given += seconds
    return {
        "combo":streak,
        "started":started,
        "refreshed":refreshed,
        "seconds":seconds,
        "bonus":coin_bonus()
    }

func coin_bonus() -> float:
    return FEVER_COIN_BONUS if active() else 0.0

func progress_to_fever() -> int:
    return mini(START_AT,streak % START_AT)

func seconds_left() -> float:
    return fever_remaining
