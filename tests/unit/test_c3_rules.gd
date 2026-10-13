extends SceneTree
const Build = preload("res://scripts/c3/run_build.gd")
const Director = preload("res://scripts/c3/roguelite_director.gd")
const Wallet = preload("res://scripts/c2/run_wallet.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, detail: String) -> void:
    if not ok:
        failures += 1
        push_error("C3 UNIT FAIL: " + detail)

func _run() -> void:
    var build: Build = Build.new()
    build.reset(77)
    check(build.xp_level == 1 and build.pending == 0, "initial progress")
    build.register_xp(5)
    check(build.xp_level == 2 and build.pending == 1, "5 XP -> level 2")
    var choices: Array[String] = build.roll_offer()
    check(choices.size() == 3 and choices[0] != choices[1] and choices[1] != choices[2], "three distinct skills")
    check(not build.select_card("fake_skill"), "reject unavailable card")
    var selected := choices[0]
    check(build.select_card(selected), "select one offered card")
    check(build.rank(selected) == 1 and build.pending == 0, "card applied once")
    check(not build.select_card(selected), "no duplicate card selection")
    build.register_xp(45)
    check(build.xp_level == 6 and build.pending == 4, "five cumulative XP thresholds")
    build.register_xp(999)
    check(build.pending == 4, "no extra card after level 6")

    build.reset(77)
    build.ranks["pulso_agil"] = 3
    build.ranks["luva_magnetica"] = 2
    build.ranks["bolsa_encantada"] = 2
    build.ranks["ritmo_mestre"] = 3
    build.ranks["folego_extra"] = 2
    build.ranks["olhar_cubista"] = 2
    build.ranks["mao_paciente"] = 2
    build.ranks["dedo_certeiro"] = 3
    check(is_equal_approx(build.cooldown(), 0.34 * 0.76), "speed skill modifies cooldown")
    check(is_equal_approx(build.reach(), 0.95 * 1.24), "selection reach")
    check(is_equal_approx(build.money_bonus(3), 0.50), "money plus combo additive")
    check(is_equal_approx(build.time_bonus(), 12.0), "future wave time bonus")
    check(build.reinforced_reduction() == 2 and build.stability_heal() == 8, "difficulty and stability")
    for i in range(4):
        check(not build.record_action_bonus_move(), "bonus not due yet")
    check(build.record_action_bonus_move(), "fifth action triggers extra valid rotation")

    var wallet := Wallet.new()
    check(wallet.award(1, "elite") == {"coins":80, "xp":6}, "elite reward")
    check(wallet.award(2, "apprentice", 0.15) == {"coins":11, "xp":1}, "money bonus and XP independence")
    check(wallet.award(2, "elite").is_empty(), "ID still cannot pay twice")
    check(wallet.award(3, "reinforced", 4.0)["coins"] == 45, "bonus capped at +150%")

    build.reset()
    var director: Director = Director.new(build)
    director.start_run()
    check(director.waves.size() == 5 and director.total_expected() == 5, "five waves and first quota")
    var expected := [5, 8, 9, 11, 10]
    for wave_number in range(5):
        check(director.wave_index == wave_number, "wave index %d" % wave_number)
        check(director.total_expected() == expected[wave_number], "wave quota %d" % wave_number)
        if wave_number == 4:
            break
        # A wave can end by time without awarding phantom coins.
        director.tick(1000.0)
        director.finish_wave()
        check(director.phase == Director.Phase.BETWEEN, "inter-wave status %d" % wave_number)
        check(director.begin_next_wave(), "advance to next wave")

    # Before elite, three common cubes may occupy the field but never a fourth.
    var spawned: Array = []
    for idx in range(3):
        director.tick(Director.SPAWN_INTERVAL)
        var ticket: Dictionary = director.spawn_next()
        check(ticket["kind"] != "elite", "normal pre-elite spawn")
        spawned.append(ticket["id"])
    director.tick(Director.SPAWN_INTERVAL)
    check(not director.can_spawn(), "fourth common slot reserved for elite")
    director.tick(20.0)
    check(director.can_spawn(), "elite due before 20 seconds")
    var boss: Dictionary = director.spawn_next()
    check(boss["kind"] == "elite" and director.active.size() == 4, "boss spawns with three common cubes")
    check(director.pending_count() == 6, "remaining normal queue after boss")
    check(director.spawn_next().is_empty(), "fifth cube blocked")
    # Incomplete elite must prohibit final victory even if stability remains.
    director.active.erase(spawned[0])
    director.active.erase(spawned[1])
    director.active.erase(spawned[2])
    director.tick(200.0)
    var loss: Dictionary = director.finish_wave()
    check(director.phase == Director.Phase.DEFEAT, "unsolved boss enforces defeat")
    check(loss["unseen"] >= 1, "invisible queued cubes are separate")

    director.start_run()
    director.phase = Director.Phase.BETWEEN
    director.wave_index = 3
    check(director.begin_next_wave(), "enter boss wave for win scenario")
    director.tick(20.0)
    var elite: Dictionary = director.spawn_next()
    check(elite.get("kind") == "elite", "boss is available without normal spawns")
    var award: Dictionary = director.resolve_cube(int(elite["id"]))
    check(award == {"coins":80,"xp":6} and director.elite_resolved, "boss reward and flag")
    check(director.resolve_cube(int(elite["id"])).is_empty(), "boss ID once only")
    director.tick(200.0)
    director.finish_wave()
    check(director.phase == Director.Phase.VICTORY, "solved elite allows final victory")
    print("KubRogue C3 unit tests: %d failures" % failures)
    quit(0 if failures == 0 else 1)
