extends SceneTree
const Routes = preload("res://scripts/c9/route_service.gd")
const Director = preload("res://scripts/c7/special_director.gd")
var fails := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    if not ok:
        fails += 1
        push_error("C9 UNIT FAIL: " + label)

func _run() -> void:
    var a: Routes = Routes.new()
    var b: Routes = Routes.new()
    a.begin_run(20770102)
    b.begin_run(20770102)
    for wave in range(4):
        var p: Array[String] = a.prepare(wave)
        var q: Array[String] = b.prepare(wave)
        check(p == q and p.size() == 2 and p[0] != p[1],
            "daily same seed gets two distinct reproducible routes")
        check(a.prepare(wave) == p, "offer doesn't reroll while summary stays open")
        check(not a.choose("invalid"), "unknown route cannot be selected")
        check(a.choose(p[0]), "first offered route accepted")
        check(not a.choose(p[1]), "choice cannot be replaced")
        check(b.choose(q[0]), "mirrored decision accepted")
        a.clear_after_wave()
        b.clear_after_wave()
    check(a.prepare(4).is_empty(), "no routes after wave five")
    a.begin_run(4004)
    a.prepare(0)
    check(a.skip() and a.decided and not a.skip(),"skip is safe and one-time")
    var d: Director = Director.new()
    d.start_run()
    check(d.wave_index == 0 and d.phase == Director.Phase.RUNNING,\
        "first wave automatically starts on reset")
    for id in ["blitz","refuge","gilded","clock"]:
        var rt: Routes = Routes.new()
        rt.begin_run(88)
        rt.prepare(0)
        rt.available = [id,"blitz" if id != "blitz" else "clock"]
        check(rt.choose(id),"valid event chosen")
        var spawned: Dictionary = d.waves[1].duplicate(true)
        check(rt.apply_next(d),"route applied once before next wave")
        check(not rt.apply_next(d),"can't apply twice")
        check(rt.active_effect(1)==id and rt.active_effect(2).is_empty(),
            "one-wave-only effect")
        match id:
            "blitz":
                check(rt.time_delta(1)==-10.0 and rt.coin_bonus(1)==0.25,
                    "blitz makes a timed premium encounter")
            "refuge":
                check(rt.time_delta(1)==-8.0 and rt.stability_delta(1)==18,
                    "refuge recovery has time cost")
            "gilded":
                var before: Array = spawned["types"]
                var after: Array = d.waves[1]["types"]
                check(after.size()==before.size(),"gilded doesn't create extra actors")
                check(after.count("golden")==before.count("golden")+1,
                    "gilded creates exactly one extra real golden cube")
                d.waves[1] = spawned
            "clock":
                check(rt.time_delta(1)==12.0 and rt.stability_delta(1)==-12,
                    "time tower trades stability for time")
        rt.clear_after_wave()
        check(rt.coin_bonus(1)==0.0 and rt.active_effect(1).is_empty(),
            "no active bonuses bleed into next wave")
    print("KubRogue C9 deterministic routes unit: %d failures" % fails)
    quit(0 if fails == 0 else 1)
