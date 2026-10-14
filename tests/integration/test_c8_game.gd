extends SceneTree
const Hub = preload("res://scripts/c8/hub_stage.gd")
const Game = preload("res://scripts/c8/game_stage.gd")
const Store = preload("res://scripts/c4/save_store.gd")
const Journal = preload("res://scripts/c8/journal_service.gd")
var failures := 0
func _initialize() -> void:
    call_deferred("_run")
func check(ok: bool, reason: String) -> void:
    if not ok:
        failures += 1
        push_error("C8 STAGE FAIL: " + reason)
func _clean(p: String) -> void:
    for e in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(p + e))
func _run() -> void:
    var money := "user://c8_stage_money.json"
    var journal_path := "user://c8_stage_journal.json"
    var daily := "user://c8_stage_daily.json"
    for p in [money, journal_path, daily]:
        _clean(p)
    var progress = get_root().get_node("KubeSession")
    var challenge = get_root().get_node("KubeChallenge")
    var journal = get_root().get_node("KubeJournal")
    progress.configure(Store.new(money))
    challenge.configure(Store.new(daily))
    journal.configure(Store.new(journal_path))
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    check(hub.collection_label.text.contains("0 / 7"), "locked journal shown in hub")
    hub._show_bestiary()
    check(hub.dialog_center.visible, "bestiary modal opens")
    check(hub.dialog_box.find_children("Species_*", "PanelContainer", true, false).size() == 7,
        "bestiary shows seven gallery cards")
    check(hub.dialog_box.find_children("Contract_*", "PanelContainer", true, false).size() == 3,
        "three contract definitions are visible")
    hub.queue_free()
    await process_frame
    challenge.select_mode("normal")
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.save_ready and game.director.waves.size() == 5, "existing five-wave run works")
    check(game.hand.get_active_texture() != null and game.card_widgets.size() == 3,
        "approved 2D hand and ability cards remain")
    check(game.journal.run_active, "contracts activated on the run")
    check(game.contract_label.text.contains("0/3"), "HUD shows contract progress")
    for n in range(4):
        if game.actors.is_empty():
            game.director.spawn_clock = game.director.SPAWN_INTERVAL
            game._spawn_one_if_possible()
        check(not game.actors.is_empty(), "fresh apprentice target appeared")
        if game.actors.is_empty():
            break
        var id: int = int(game.actors.keys()[0])
        var loops := 0
        while game.actors.has(id) and loops < 7:
            await game.solve_actor_move(id)
            loops += 1
        check(not game.actors.has(id), "solved real apprentice")
    check(journal.run_solved == 4 and journal.completed_contracts() == 1,
        "four actual solves complete first contract")
    check(progress.balance() == 60, "four cubes credited 40 plus one 20-coin contract")
    check(journal.solved_count("apprentice") == 4, "only durably credited cubes count")
    check(game.pending_credits.is_empty(), "no duplicate or failed payments")
    check(game.contract_label.text.contains("1/3"), "HUD updates contract success")
    game.queue_free()
    await process_frame
    var stored: Journal = Journal.new()
    stored.configure(Store.new(journal_path))
    check(stored.solved_count("apprentice") == 4, "collections survive restart")
    check(Store.new(money).read_json().get("coins", -1) == progress.balance(),
        "contract coins saved in original C4 wallet")
    stored.free()
    for p in [money, journal_path, daily]:
        _clean(p)
    print("KubRogue C8 game and hub integration: %d failures" % failures)
    quit(0 if failures == 0 else 1)
