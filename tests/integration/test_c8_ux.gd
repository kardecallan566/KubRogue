extends SceneTree
const Hub = preload("res://scripts/c8/hub_stage.gd")
const Game = preload("res://scripts/c8/game_stage.gd")
const Director = preload("res://scripts/c7/special_director.gd")
const Store = preload("res://scripts/c4/save_store.gd")
const Preview = preload("res://scripts/c8/species_preview.gd")
var failures := 0
func _initialize() -> void:
    call_deferred("_run")
func check(ok: bool, reason: String) -> void:
    if not ok:
        failures += 1
        push_error("C8 UX FAIL: "+reason)
func _clean(p: String) -> void:
    for e in ["",".bak",".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(p+e))
func _run() -> void:
    var wallet_path := "user://c8_ux_wallet.json"
    var journal_path := "user://c8_ux_journal.json"
    var daily_path := "user://c8_ux_daily.json"
    for p in [wallet_path,journal_path,daily_path]:
        _clean(p)
    var progress = get_root().get_node("KubeSession")
    var journal = get_root().get_node("KubeJournal")
    var daily = get_root().get_node("KubeChallenge")
    progress.configure(Store.new(wallet_path))
    journal.configure(Store.new(journal_path))
    daily.configure(Store.new(daily_path))
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    hub._show_play_modes()
    var options := hub.dialog_box.find_children("Mode_*","PanelContainer",true,false)
    check(options.size()==2,"two distinct large mode cards")
    check(hub.modal_scroll.custom_minimum_size.y <= 410,
        "mode selector has no giant blank scroll area")
    hub._show_bestiary()
    var species := hub.dialog_box.find_children("Species_*","PanelContainer",true,false)
    var gallery: GridContainer = hub.dialog_box.find_child("SpeciesGallery",true,false)
    check(species.size()==7 and gallery.columns==2,"gallery in two columns")
    check(hub.modal_panel.custom_minimum_size.x >= 800,"bestiary given enough width")
    if species.size()>0:
        var prev := species[0].find_child("Preview",true,false)
        check(prev is Preview,"each species has an isometric cube preview")
    hub.queue_free()
    await process_frame
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.save_ready and game.workshop!=null,"the run starts normally")
    check(not game.workshop_open,"workshop not accessible during combat")
    game._open_workshop()
    check(not game.workshop_open,"can't shop while fighting")
    check(progress.credit_cube(900,150),"simulate 150 already earned coins")
    game.director.wallet.coins = 150
    game.director.phase = Director.Phase.BETWEEN
    game._open_workshop()
    check(game.workshop_open and game.workshop_center.visible,"workshop opens between waves")
    check(game.workshop_rows.size()==4,"four upgrades in two columns")
    check(game.workshop_balance.text.contains("150"),"displays run-only currency")
    game._buy_workshop_upgrade("tempo")
    check(game.workshop.rank("tempo")==1 and progress.balance()==120,
        "time purchase subtracts 30 durable coins")
    game._buy_workshop_upgrade("lucro")
    check(game.workshop.rank("lucro")==1 and progress.balance()==75,
        "coin-bonus purchase debits 45 and activates rank")
    check(game.workshop.coin_bonus()>0.09,"coin bonus truly enabled")
    game._buy_workshop_upgrade("escudo")
    check(game.workshop.rank("escudo")==1 and progress.balance()==50,
        "healing purchase also debits safely")
    check(game.workshop.spent==100 and game.workshop.available(150,progress.balance())==50,
        "budget tracks minted coins minus spent")
    var total: int = int(progress.balance())
    game._buy_workshop_upgrade("tempo")
    check(progress.balance()==total and game.workshop.rank("tempo")==1,
        "insufficient run balance cannot trigger duplicate purchase")
    game._close_workshop()
    check(not game.workshop_open and game.summary_panel.get_parent().visible,
        "closing shop returns to wave summary")
    game._start_next_wave()
    check(is_equal_approx(game.director.time_left,
        float(game.director.definition()["duration"])+game.build.time_bonus()+10.0),
        "bought time extends actual next wave timer")
    game.restart_run()
    check(game.workshop.spent==0 and game.workshop.rank("tempo")==0,
        "run-only purchases reset on restart")
    check(progress.balance()==50,"restart does not refund valid purchases")
    game.queue_free()
    await process_frame
    for p in [wallet_path,journal_path,daily_path]:
        _clean(p)
    print("KubRogue C8.2 mode/codex/workshop integration: %d failures" % failures)
    quit(0 if failures==0 else 1)
