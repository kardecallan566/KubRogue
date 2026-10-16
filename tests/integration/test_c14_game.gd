extends SceneTree
const Hub = preload("res://scripts/c14/hub_stage.gd")
const Game = preload("res://scripts/c14/game_stage.gd")
const Store = preload("res://scripts/c4/save_store.gd")
const Medals = preload("res://scripts/c14/medal_service.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, reason: String) -> void:
    if not ok:
        failures += 1
        push_error("C14 UI FAIL: " + reason)

func _clean(path: String) -> void:
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))

func _run() -> void:
    var money := "user://c14_ui_money.json"
    var journal_path := "user://c14_ui_journal.json"
    var history_path := "user://c14_ui_history.json"
    for p in [money,journal_path,history_path]:
        _clean(p)
    var session = get_root().get_node("KubeSession")
    var journal = get_root().get_node("KubeJournal")
    var history = get_root().get_node("KubeHistory")
    session.configure(Store.new(money))
    journal.configure(Store.new(journal_path))
    history.configure(Store.new(history_path))
    var balance := int(session.data["coins"])
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    check(hub.find_child("PrimaryActions",true,false).get_child_count()==4,
        "still four hub actions")
    hub._show_bestiary()
    check(hub.dialog_box.find_child("OpenHistory",true,false)!=null,
        "C12 hall button preserved")
    check(hub.species_gallery.get_child_count()==7
        and hub.achievements_gallery.get_child_count()==12
        and hub.contracts_gallery.get_child_count()==3,
        "species, achievements and contracts galleries are complete")
    check(hub.species_gallery.visible and not hub.achievements_gallery.visible,
        "species tab is the default")
    hub._set_garden_tab(1)
    check(hub.achievements_gallery.visible and not hub.species_gallery.visible
        and not hub.contracts_gallery.visible, "achievement tab switches correctly")
    hub._set_garden_tab(2)
    check(hub.contracts_gallery.visible and not hub.achievements_gallery.visible,
        "contracts tab switches correctly")
    hub._show_history()
    check(hub.dialog_box.find_child("CareerDashboard",true,false)!=null,
        "C13 career dashboard and filters retained in history")
    hub._show_bestiary()
    check(hub.dialog_box.find_child("GardenTabs",true,false)!=null,
        "history returns to new tabbed bestiary")
    hub.queue_free()
    await process_frame

    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.medal_notice!=null and not game.medal_notice.visible,
        "existing unlocks never announce on startup")
    check(game.history==history and game.fever!=null and game.workshop!=null,
        "C12 history, Fever and Workshop preserved in C14 arena")
    var id := int(session.data["run_number"])
    check(journal.record_cube("apprentice",id,500),
        "new journal observation persisted")
    check(game.medal_notice.visible and game.medal_notice.text.contains("PRIMEIRO GIRO"),
        "durable first unlock creates unobtrusive notice")
    game._check_new_medals()
    check(game.medal_notice.text.contains("PRIMEIRO GIRO"),
        "same medal never generates a second announcement")
    game.restart_run()
    check(not game.medal_notice.visible,
        "restart clears notice and snapshots previously earned unlock")
    check(int(session.data["coins"])==balance,
        "achievements have no currency reward")
    game.queue_free()
    await process_frame
    var reloaded: Medals = Medals.new()
    check(reloaded.trophy_count(journal,session)>=1,
        "medal remains unlocked from C8's existing journal")
    for p in [money,journal_path,history_path]:
        _clean(p)
    print("KubRogue C14 hub and gameplay integration: %d failures" % failures)
    quit(0 if failures==0 else 1)
