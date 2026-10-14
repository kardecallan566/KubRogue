extends SceneTree
const Fever = preload("res://scripts/c10/fever_engine.gd")
var fails := 0
func _initialize() -> void:
    call_deferred("_run")
func check(ok: bool,why: String) -> void:
    if not ok:
        fails += 1
        push_error("C10 UNIT FAIL: "+why)
func _run() -> void:
    var f: Fever = Fever.new()
    f.begin_run()
    check(f.streak==0 and not f.active() and f.coin_bonus()==0.0,
        "fresh run starts without free bonus")
    for id in range(1,4):
        var info: Dictionary = f.on_solve(id)
        check(not info["started"] and info["bonus"]==0.0,
            "first three solutions only charge combo meter")
    check(f.progress_to_fever()==3 and f.best_streak==3,
        "3 of 4 progress and record")
    check(f.on_solve(3).is_empty() and f.streak==3,
        "the same cube never advances combo twice")
    var trigger: Dictionary = f.on_solve(4)
    check(trigger["started"] and trigger["seconds"]==1.0,
        "fourth successful solve starts fever and adds one second")
    check(f.active() and f.activations==1 and f.coin_bonus()==0.20,
        "fever delivers a real 20 percent coin bonus")
    check(f.seconds_left()==9.0,"fever duration nine seconds")
    check(f.tick(2.5)==false and f.seconds_left()==6.5,
        "in-run time advances countdown")
    var remaining: float = f.seconds_left()
    # In game, pauses never call tick(). No OS clock or Timer is used.
    check(f.seconds_left()==remaining,"menu pause never consumes FEVER")
    for id in range(5,9):
        var info: Dictionary = f.on_solve(id)
        check(f.streak == id,"combo keeps growing")
        if id == 8:
            check(info["refreshed"] and f.seconds_left()<=12.0,
                "eight-streak extends existing fever without stacking")
    check(f.wave_time_given<=6.0,"extra seconds capped at six per wave")
    check(f.tick(12.1) and not f.active() and f.streak==0,
        "fever and combo expire after idle")
    var restarted: Dictionary = f.on_solve(19)
    check(restarted["combo"]==1 and not restarted["started"],
        "new streak starts clean")
    f.reset_wave()
    check(f.streak==0 and f.wave_time_given==0.0 and not f.active(),
        "new wave clears temporary fever but not all-run record")
    check(f.best_streak==8,"best streak remains until end of run")
    f.begin_run()
    check(f.best_streak==0 and f.activations==0,"new run clears records")
    print("KubRogue C10 Fever state unit: %d failures" % fails)
    quit(0 if fails==0 else 1)
