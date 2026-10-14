extends SceneTree
const Hub = preload("res://scripts/c12/hub_stage.gd")
const Game = preload("res://scripts/c12/game_stage.gd")
const Store = preload("res://scripts/c4/save_store.gd")
const Rules = preload("res://scripts/c7/special_director.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, reason: String) -> void:
    if not ok:
        failures += 1
        push_error("C12 STAGE FAIL: "+reason)

func _clean(path: String) -> void:
    for s in ["",".bak",".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path+s))

func _run() -> void:
    var wallet_path := "user://c12_stage_money.json"
    var journal_path := "user://c12_stage_journal.json"
    var daily_path := "user://c12_stage_daily.json"
    var history_path := "user://c12_stage_history.json"
    for p in [wallet_path,journal_path,daily_path,history_path]:
        _clean(p)
    var progress = get_root().get_node("KubeSession")
    var daily = get_root().get_node("KubeChallenge")
    var journal = get_root().get_node("KubeJournal")
    var history = get_root().get_node("KubeHistory")
    progress.configure(Store.new(wallet_path))
    daily.configure(Store.new(daily_path))
    journal.configure(Store.new(journal_path))
    history.configure(Store.new(history_path))
    check(daily.select_mode("daily","2026-10-14"),"daily mode selected")
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.save_ready and game.history==history,"game history linked to real autoload")
    check(game.fever_frame!=null and game.skill_slots!=null,
        "C10 Fever HUD and C8 skill icons remain")
    check(game.routes!=null and game.workshop!=null,
        "C9 routes and C8 workshop remain")
    check(not game.medal_panel.visible,"medals hidden during live wave")
    var identity: int = int(progress.data["run_number"])
    game.director.wave_index=4
    game.director.phase=Rules.Phase.RUNNING
    game.director.time_left=0.0
    game.director.active.clear()
    game.director.next_spawn_index=game.director.waves[4]["types"].size()
    game.director.elite_spawned=true
    game.director.elite_resolved=true
    game.director.stability=78
    game.director.wallet.coins=305
    game.director.wallet.xp=25
    game.director.wallet.solved=20
    game.best_combo_in_run=6
    game.fever.activations=3
    for id in range(1,5):
        journal.register_solve("apprentice",id)
    journal.register_solve("golden",5)
    journal.register_solve("armored",6)
    check(journal.completed_contracts()==2,"contract progression simulated")
    game._finish_wave()
    check(game.director.phase==Rules.Phase.VICTORY and game.medal_panel.visible,
        "legitimate last-wave win shows result medal")
    check(game.medal_label.text.contains("OURO"),"gold medal criteria displayed")
    check(game.summary_button.text.contains("hub"),"return navigation kept")
    check(history.runs.size()==1 and history.latest()["medal"]=="gold",
        "one finished result saved")
    check(history.latest()["fevers"]==3 and history.latest()["contracts"]==2,
        "real C10 and C8 metrics snapshotted")
    check(history.latest()["run_id"]==identity and history.latest()["mode"]=="daily",
        "run identity and daily mode included")
    check(history.record_finish(history.latest()) and history.runs.size()==1,
        "replayed save cannot duplicate history")
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    check(hub.find_child("PrimaryActions",true,false).get_child_count()==4,
        "main menu remains four actions")
    hub._show_bestiary()
    check(hub.dialog_box.find_child("OpenHistory",true,false)!=null,
        "history accessible through bestiary, not extra main button")
    hub._show_history()
    var cards := hub.dialog_box.find_children("Run_*","PanelContainer",true,false)
    check(cards.size()==1 and hub.dialog_box.find_child("HistoryGallery",true,false)!=null,
        "one earned gold medal is displayed in history")
    hub.queue_free()
    game.queue_free()
    await process_frame
    var reload = preload("res://scripts/c12/history_service.gd").new()
    reload.configure(Store.new(history_path))
    check(reload.runs.size()==1 and reload.latest()["medal"]=="gold",
        "saved medal survives restart")
    reload.free()
    for p in [wallet_path,journal_path,daily_path,history_path]:
        _clean(p)
    print("KubRogue C12 victory, history and menu integration: %d failures" % failures)
    quit(0 if failures==0 else 1)
