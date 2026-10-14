extends SceneTree
const Hub = preload("res://scripts/c12/hub_stage.gd")
const Game = preload("res://scripts/c12/game_stage.gd")
const Medals = preload("res://scripts/c12/medal_service.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool,why: String) -> void:
    if not ok:
        failures += 1
        push_error("C12 STAGE FAIL: " + why)

func _clean(path: String) -> void:
    for ext in ["",".bak",".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path+ext))

func _run() -> void:
    var money := "user://c12_game_wallet.json"
    var daily := "user://c12_game_daily.json"
    var journal_path := "user://c12_game_codex.json"
    for p in [money,daily,journal_path]:
        _clean(p)
    var progress = get_root().get_node("KubeSession")
    var challenge = get_root().get_node("KubeChallenge")
    var journal = get_root().get_node("KubeJournal")
    progress.configure(Store.new(money))
    challenge.configure(Store.new(daily))
    journal.configure(Store.new(journal_path))
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    var actions := hub.find_child("PrimaryActions",true,false)
    check(actions != null and actions.get_child_count()==4,
        "hub still has exactly four top-level actions")
    check(hub.medals_label.text.contains("0 / 12"),
        "hub medal count starts from existing durable state")
    hub._show_bestiary()
    check(hub.bestiary_pages.size()==3 and hub.bestiary_tabs.size()==3,
        "bestiary now has Cubos, Medalhas, Contratos tabs")
    check(hub.dialog_box.find_children("Species_*","PanelContainer",true,false).size()==7,
        "seven 2x2 through 5x5 types remain in collection")
    check(hub.dialog_box.find_children("Medal_*","PanelContainer",true,false).size()==12,
        "all twelve award cards built from real catalog")
    check(hub.dialog_box.find_children("Contract_*","PanelContainer",true,false).size()==3,
        "run contract cards remain accessible")
    check(hub.dialog_box.find_children("Mastery_*","Label",true,false).size()==7,
        "all seven species display mastery progress")
    hub._select_bestiary_tab(1)
    check(hub.bestiary_pages[1].visible and not hub.bestiary_pages[0].visible
        and hub.bestiary_tabs[1].disabled,"medals open as separate tab without clutter")
    hub._select_bestiary_tab(2)
    check(hub.bestiary_pages[2].visible and not hub.bestiary_pages[1].visible,
        "contracts tab switches correctly")
    hub.queue_free()
    await process_frame

    challenge.select_mode("normal")
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.save_ready and game.medals!=null and game.medal_notice!=null,
        "C12 game boots with original wallet and Garden Medals")
    check(game.workshop!=null and game.routes!=null and game.fever!=null,
        "workshop, two routes and Fever remain")
    check(game.hand.get_active_texture()!=null,"hand cursor loaded without image imports")
    check(not game.medal_notice.visible,"medal toast hidden at start")
    var attempts := 0
    if game.actors.is_empty():
        game.director.spawn_clock=game.director.SPAWN_INTERVAL
        game._spawn_one_if_possible()
    check(not game.actors.is_empty(),"genuine cube spawned")
    if not game.actors.is_empty():
        var id: int = int(game.actors.keys()[0])
        while game.actors.has(id) and attempts<8:
            await game.solve_actor_move(id)
            attempts += 1
        check(not game.actors.has(id),"first cube solved with legal animated turns")
    check(progress.balance()==10 and journal.solved_count("apprentice")==1,
        "coin credit and permanent discovery unaffected")
    check(game.medal_notice.visible and game.medal_notice.text.contains("PRIMEIRO GIRO"),
        "first earned Garden Medal visibly announces")
    check(game.medals.trophy_count(journal,progress)==1,
        "exactly one award appears with one solution")
    game.restart_run()
    check(not game.medal_notice.visible and game.medals.trophy_count(journal,progress)==1,
        "new run retains historical medal without showing an old toast")
    game.queue_free()
    await process_frame

    hub = Hub.new()
    get_root().add_child(hub)
    check(hub.medals_label.text.contains("1 / 12"),
        "hub reads earned medal immediately after scene reload")
    hub._show_bestiary()
    hub._select_bestiary_tab(1)
    var award = hub.dialog_box.find_child("Medal_first",true,false)
    check(award != null and award.find_children("*","Label",true,false)
        .any(func(lab): return String(lab.text).contains("CONQUISTADA")),
        "Garden Medals gallery shows the new achievement as unlocked")
    hub.queue_free()
    await process_frame
    for p in [money,daily,journal_path]:
        _clean(p)
    print("KubRogue C12 visual medals and original gameplay: %d failures" % failures)
    quit(0 if failures==0 else 1)
