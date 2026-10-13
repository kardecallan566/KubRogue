extends SceneTree
const Hub = preload("res://scripts/c4/hub_stage.gd")
const Game = preload("res://scripts/c4/game_stage.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, detail: String) -> void:
    if not ok:
        failures += 1
        push_error("C4 STAGE FAIL: " + detail)

func _run() -> void:
    var path := "user://c4_integration_progress.json"
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
    var progress = get_root().get_node("KubeSession")
    progress.configure(Store.new(path))
    check(not progress.data["tutorial_completed"], "tutorial shown for first-run user")
    var hub: Hub = Hub.new()
    # A script-typed Hub variable is not inferred as Node by this Godot
    # compiler path; explicit cast confirms its Control/Node base class.
    get_root().add_child(hub as Node)
    check(hub.wallet_label.text.contains("0 moedas"), "hub reflects balance")
    hub._show_tutorial(false)
    check(hub.dialog_dim.visible, "replayable tutorial dialog")
    hub._close_modal()
    check(progress.finish_tutorial(), "tutorial completion saved")
    hub._show_shop()
    check(hub.dialog_box.get_child_count() >= 10, "three upgrade offers displayed")
    hub._close_modal()
    hub.queue_free()
    await process_frame

    # Money is acquired through a confirmed test transaction in a previous run.
    check(progress.begin_run(), "first run sequence created")
    check(progress.credit_cube(999, 350), "test setup earned coins")
    check(progress.purchase("stable_field"), "permanent stability upgrade purchased")
    check(progress.stability_max() == 105 and progress.balance() == 50, "buy costs exactly 300")
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.save_ready and game.progress == progress, "game bound to save service")
    check(game.director.stability == 105 and game.director.stability_cap == 105,
        "meta stability correctly applied to new run")
    check(game.hand is Control and game.hand.mouse_filter == Control.MOUSE_FILTER_IGNORE,
        "2D hand preserved")
    check(game.actors.size() == 1, "first valid cube presented")
    var first_id: int = int(game.actors.keys()[0])
    var attempts := 0
    while game.actors.has(first_id) and attempts < 9:
        await game.solve_actor_move(first_id)
        attempts += 1
    check(not game.actors.has(first_id), "real cube solved")
    check(progress.balance() == 60, "real cube credits ten persistent coins")
    check(game.director.wallet.coins == 10, "run accounting still tracks same amount")
    check(game.pending_credits.is_empty(), "no pending payment after disk confirmation")
    await game.solve_actor_move(first_id)
    check(progress.balance() == 60, "solved cube never double credited")
    game.queue_free()
    await process_frame

    # Closing game must not lose credits; per-run XP is not saved.
    var from_disk = Store.new(path).read_json()
    check(from_disk["coins"] == 60, "money durable without finishing run")
    check(from_disk["meta"]["stable_field"] == 1, "purchased upgrade durable")
    check(from_disk["tutorial_completed"], "tutorial persisted")
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
    print("KubRogue C4 integration tests: %d failures" % failures)
    quit(0 if failures == 0 else 1)
