extends SceneTree
const Hub = preload("res://scripts/c9/hub_stage.gd")
const Game = preload("res://scripts/c9/game_stage.gd")
const Director = preload("res://scripts/c7/special_director.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, reason: String) -> void:
    if not ok:
        failures += 1
        push_error("C9 STAGE FAIL: " + reason)

func _clean(p: String) -> void:
    for e in ["",".bak",".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(p+e))

func _run() -> void:
    var money := "user://c9_money_test.json"
    var journal_path := "user://c9_journal_test.json"
    var daily_path := "user://c9_daily_test.json"
    for p in [money,journal_path,daily_path]:
        _clean(p)
    var progress = get_root().get_node("KubeSession")
    var journal = get_root().get_node("KubeJournal")
    var daily = get_root().get_node("KubeChallenge")
    progress.configure(Store.new(money))
    journal.configure(Store.new(journal_path))
    daily.configure(Store.new(daily_path))
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    hub._show_play_modes()
    check(hub.dialog_box.find_children("Mode_*","PanelContainer",true,false).size()==2,
        "C8.2 choice card layout unchanged")
    hub.queue_free()
    await process_frame
    check(daily.select_mode("daily","2026-10-13"),"daily mode accepted")
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.hand.get_active_texture()!=null and game.card_widgets.size()==3,
        "hand and skill icon cards remain")
    check(game.workshop!=null and game.journal!=null and game.routes!=null,
        "workshop, contracts and routes coexist")
    check(game.run_seed==daily.daily_seed("2026-10-13"),
        "daily seed continues to drive every new run")
    game._open_route_offer()
    check(not game.route_open,"cannot access route choice during active combat")
    game._clear_actors()
    game.director.active.clear()
    game.director.phase = Director.Phase.BETWEEN
    var offer: Array[String] = game.routes.prepare(0)
    game._set_summary_visible(true)
    game._continue_from_summary()
    check(game.route_open and game.route_center.visible,"route modal opens between waves")
    check(game.route_cards.get_child_count()==2,"two large route options rendered")
    check(game.route_center.find_children("Choose_*","Button",true,false).size()==2,
        "route cards have selection actions")
    game._select_route(offer[0])
    check(not game.route_open and game.routes.decided,"route selected once")
    check(game.summary_panel.get_parent().visible,"return to wave summary")
    check(not game.routes.choose(offer[1]),"can't switch decisions")
    game._open_workshop()
    check(game.workshop_open and game.workshop_center.visible,
        "workshop remains accessible between rounds")
    game._close_workshop()
    game._start_next_wave()
    check(game.director.wave_index==1,"next wave starts normally")
    check(game.routes.active_effect(1)==offer[0],"chosen route activates")
    var expected: float = float(game.director.definition()["duration"]) \
        + game.build.time_bonus() + game.workshop.next_wave_time() \
        + game.routes.time_delta(1)
    check(is_equal_approx(game.director.time_left,maxf(8.0,expected)),
        "time risk/benefit changes actual wave timer")
    check(game.route_status.visible,"active route visible in gameplay HUD")
    check(game.director.waves[4]["types"].size()==9 and game.director.waves.size()==5,
        "fifth wave and mandatory 3x3 elite still intact")
    # An event may replace a spawn slot; restart must restore the original
    # C7 wave table even if the previous run followed Trilha Dourada.
    var pristine: Array = Director.new().waves[1]["types"].duplicate()
    game.director.waves[1]["types"][0] = "golden"
    game.restart_run()
    check(game.director.waves[1]["types"] == pristine,
        "Golden Route never contaminates the following run")
    check(game.routes.offer_wave == -1 and not game.routes.decided,
        "new run resets event choices")
    check(game.routes.prepare(0) == offer,
        "daily challenge offers same two routes after restart")
    check(game.journal.run_active and game.workshop.spent==0,
        "contracts and run-only workshop still reset")
    game.queue_free()
    await process_frame
    for p in [money,journal_path,daily_path]:
        _clean(p)
    print("KubRogue C9 route UI / real stage integration: %d failures" % failures)
    quit(0 if failures == 0 else 1)
