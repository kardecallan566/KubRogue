extends SceneTree
const Hub = preload("res://scripts/c15/hub_stage.gd")
const Game = preload("res://scripts/c15/game_stage.gd")
const Rules = preload("res://scripts/c7/special_director.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error("C15 GAME FAIL: " + message)

func clean(path: String) -> void:
    for s in ["",".bak",".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path+s))

func _run() -> void:
    var money := "user://c15_stage_money.json"
    var daily := "user://c15_stage_daily.json"
    var weekly := "user://c15_stage_weekly.json"
    var journal := "user://c15_stage_journal.json"
    var history := "user://c15_stage_history.json"
    for p in [money,daily,weekly,journal,history]:
        clean(p)
    var session = get_root().get_node("KubeSession")
    var challenge = get_root().get_node("KubeChallenge")
    var medals = get_root().get_node("KubeJournal")
    var run_history = get_root().get_node("KubeHistory")
    session.configure(Store.new(money))
    challenge.configure(Store.new(daily))
    challenge.configure_weekly(Store.new(weekly))
    medals.configure(Store.new(journal))
    run_history.configure(Store.new(history))
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    check(hub.find_child("PrimaryActions",true,false).get_child_count()==4,
        "main hub keeps four actions")
    hub._show_play_modes()
    var choices := hub.dialog_box.find_child("ModeCards",true,false)
    check(choices!=null and choices.get_child_count()==3,
        "normal, daily and weekly cards share one modal")
    check(hub.dialog_box.find_child("PlayWeekly",true,false)!=null,
        "weekly choice has a real play action")
    hub._start_weekly()
    check(challenge.active_mode=="weekly" and challenge.active_date==challenge.current_week(),
        "weekly mode chosen in hub, UTC week captured")
    hub._show_bestiary()
    check(hub.dialog_box.find_child("GardenTabs",true,false)!=null
        and hub.dialog_box.find_child("OpenHistory",true,false)!=null,
        "C14 bestiary tabs and C12 medal hall retained")
    hub.queue_free()
    await process_frame
    check(challenge.select_mode("weekly","2026-10-16"),"fixed UTC test week selected")
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.save_ready and game.run_seed==challenge.weekly_seed("2026-10-12"),
        "real arena uses same weekly seed across the week")
    check(game.mode_label.text.contains("SEMANAL"),"HUD identifies weekly mode")
    check(game.fever!=null and game.workshop!=null and game.routes!=null,
        "Fever, Workshop and Garden Routes remain functional")
    game.director.wave_index = 4
    game.director.phase = Rules.Phase.RUNNING
    game.director.time_left = 0.0
    game.director.active.clear()
    game.director.next_spawn_index = game.director.waves[4]["types"].size()
    game.director.elite_spawned = true
    game.director.elite_resolved = true
    game.director.stability = 75
    game.director.wallet.coins = 130
    game.director.wallet.solved = 14
    game.best_combo_in_run = 5
    var coins_before := session.balance()
    game._finish_wave()
    check(game.director.phase==Rules.Phase.VICTORY,
        "real wave director reaches victory")
    check(run_history.runs.size()==1 and run_history.latest()["mode"]=="weekly"
        and run_history.latest()["date"]=="2026-10-12",
        "history saves weekly result without converting to Normal")
    check(challenge.record_for_week("2026-10-12")["wins"]==1
        and challenge.record_for_week("2026-10-12")["attempts"]==1,
        "weekly results saved exactly once")
    game._record_challenge_if_needed()
    check(challenge.record_for_week("2026-10-12")["attempts"]==1,
        "no duplicated attempt in the postgame")
    check(session.balance()==coins_before and not FileAccess.file_exists(daily),
        "weekly medal grants no additional currency and writes no daily record")
    game.queue_free()
    await process_frame
    var gallery: Hub = Hub.new()
    get_root().add_child(gallery)
    gallery._show_history()
    check(gallery.dialog_box.find_child("HistoryFilterWeekly",true,false)!=null,
        "C13 career filters now include the weekly tab")
    gallery._set_history_mode("weekly")
    check(gallery.career_metrics.text.contains("1 partidas")
        and gallery.career_gallery.get_child_count()==1,
        "weekly history filter shows correct data")
    var item = gallery.career_gallery.get_child(0)
    var fields := item.get_child(0)
    check(fields.get_child(1).text.contains("DESAFIO SEMANAL"),
        "weekly card has accurate label")
    gallery._set_history_mode("daily")
    check(gallery.career_gallery.get_child_count()==1
        and gallery.career_gallery.get_child(0).name=="CareerEmpty",
        "existing daily tab doesn't count weekly records")
    gallery.queue_free()
    await process_frame
    for p in [money,daily,weekly,journal,history]:
        clean(p)
    print("KubRogue C15 weekly integration: %d failures" % failures)
    quit(0 if failures==0 else 1)
