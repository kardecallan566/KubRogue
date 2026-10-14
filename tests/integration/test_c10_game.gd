extends SceneTree
const Game = preload("res://scripts/c10/game_stage.gd")
const Hub = preload("res://scripts/c10/hub_stage.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var fails := 0
func _initialize() -> void:
    call_deferred("_run")
func check(ok: bool,reason: String) -> void:
    if not ok:
        fails += 1
        push_error("C10 STAGE FAIL: "+reason)
func _clean(path: String) -> void:
    for part in ["",".tmp",".bak"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path+part))
func _run() -> void:
    var money := "user://c10_money_test.json"
    var journal_path := "user://c10_journal_test.json"
    var daily := "user://c10_daily_test.json"
    for p in [money,journal_path,daily]:
        _clean(p)
    var progress = get_root().get_node("KubeSession")
    var challenge = get_root().get_node("KubeChallenge")
    var journal = get_root().get_node("KubeJournal")
    progress.configure(Store.new(money))
    challenge.configure(Store.new(daily))
    journal.configure(Store.new(journal_path))
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    hub._show_play_modes()
    check(hub.dialog_box.find_children("Mode_*","PanelContainer",true,false).size()==2,
        "C8 selection remains visually intact")
    hub.queue_free()
    await process_frame
    challenge.select_mode("normal")
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.save_ready and game.fever!=null,"new game initializes fever")
    check(game.fever_frame!=null and game.fever_bar!=null,
        "gold arcade fever HUD is built")
    check(game.hand.get_active_texture()!=null and game.card_widgets.size()==3,
        "open/grip cursor and skill card choices still work")
    check(game.journal.run_active and game.workshop!=null and game.routes!=null,
        "journal, workshop and C9 routes still initialize")
    check(game.fever_label.text.contains("COMBO x0"),"meter begins uncharged")
    for n in range(4):
        if game.actors.is_empty():
            game.director.spawn_clock = game.director.SPAWN_INTERVAL
            game._spawn_one_if_possible()
        check(not game.actors.is_empty(),"new real 2x2 spawned")
        if game.actors.is_empty():
            break
        var id: int = int(game.actors.keys()[0])
        var attempts := 0
        while game.actors.has(id) and attempts<7:
            await game.solve_actor_move(id)
            attempts += 1
        check(not game.actors.has(id),"real puzzle solved with legal turns")
    check(game.fever.active() and game.fever.streak==4,
        "four legal solutions activate Fever")
    check(game.fever.wave_time_given==1.0,
        "Fever restores one second after activation")
    check(game.fever_label.text.contains("FEVER") and game.fever_hint.text.contains("+20%"),
        "HUD shows fever remaining and bonus")
    check(progress.balance()==62,"40 base + 2 Fever + 20 contract exactly")
    check(game.pending_credits.is_empty(),"Fever payment uses existing atomic wallet")
    check(journal.solved_count("apprentice")==4 and journal.run_solved==4,
        "bestiary and contracts still receive exactly four solutions")
    check(game.best_combo_in_run==4,"best combo record preserved")
    var frozen: float = game.fever.seconds_left()
    game.build.register_xp(5)
    game._show_cards()
    check(game.offers_open,"skill card pause opens")
    for i in range(4):
        await process_frame
    check(absf(game.fever.seconds_left()-frozen)<0.00001,
        "Fever never counts down during XP card modal")
    game._choose_card(0)
    check(not game.offers_open and game.skill_slots.get_child_count()==1,
        "skill icons continue to work after modal")
    game.restart_run()
    check(not game.fever.active() and game.fever.best_streak==0,
        "Fever does not survive a restarted run")
    check(progress.balance()==62,"earned coins stay durably saved across restart")
    game.queue_free()
    await process_frame
    for p in [money,journal_path,daily]:
        _clean(p)
    print("KubRogue C10 real 2x2 and combo Fever integration: %d failures" % fails)
    quit(0 if fails==0 else 1)
