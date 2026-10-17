extends SceneTree
const Hub = preload("res://scripts/c16/hub_stage.gd")
const Laboratory = preload("res://scripts/c16/lab_stage.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, reason: String) -> void:
    if not ok:
        failures += 1
        push_error("C16 LAB FAIL: " + reason)

func _clean(path: String) -> void:
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))

func _run() -> void:
    var money := "user://c16_lab_money.json"
    var daily := "user://c16_lab_daily.json"
    var weekly := "user://c16_lab_weekly.json"
    var journal := "user://c16_lab_journal.json"
    var history := "user://c16_lab_history.json"
    for p in [money,daily,weekly,journal,history]:
        _clean(p)
    var session = get_root().get_node("KubeSession")
    var challenge = get_root().get_node("KubeChallenge")
    var codex = get_root().get_node("KubeJournal")
    var career = get_root().get_node("KubeHistory")
    session.configure(Store.new(money))
    challenge.configure(Store.new(daily))
    challenge.configure_weekly(Store.new(weekly))
    codex.configure(Store.new(journal))
    career.configure(Store.new(history))
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    check(hub.find_child("PrimaryActions",true,false).get_child_count() == 4,
        "starting hub still has just four buttons")
    hub._show_play_modes()
    var modes = hub.dialog_box.find_child("ModeCards",true,false)
    check(modes != null and modes.get_child_count() == 3,
        "normal, daily and weekly cards remain unchanged")
    check(hub.dialog_box.find_child("OpenLaboratory",true,false) != null,
        "practice link lives inside play modal, not on home screen")
    hub.queue_free()
    await process_frame
    var balance_before: int = int(session.balance())
    var run_before: int = int(session.data["run_number"])
    var mode_before: String = String(challenge.active_mode)
    var lab: Laboratory = Laboratory.new()
    get_root().add_child(lab)
    check(lab._ready_done and lab.cube != null, "real cube playground initializes")
    check(lab.dimension == 2 and lab.cube.cubies.size() == 8,
        "2x2 contains eight actual corner cubies")
    check(lab.turn_buttons.size() == 3 and lab.face_buttons.size() == 6,
        "six legal faces and both quarter turns plus half turn")
    check(lab.size_buttons.size() == 4, "four selectable NxNxN sizes")
    for n in [2,3,4,5]:
        lab._select_size(n)
        lab.seed_value = 60231+n
        lab._scramble_now()
        var expected: int = n*n*n-(n-2)*(n-2)*(n-2)
        check(lab.cube.puzzle.is_valid(), "%d initial legal puzzle state" % n)
        check(lab.cube.cubies.size()==expected,"%d physical cubie count" % n)
        check(lab.cube.sticker_nodes.size()==6*n*n,
            "%d correct sticker count" % n)
        check(not lab.cube.is_solved(), "%d actually scrambled" % n)
        check(lab.cube.solution_plan.size() > 0,"%d has a legal inverse plan" % n)
        lab._select_face("U")
        lab._change_layer(1)
        if n < 4:
            check(lab.selected_layer == lab.max_layer(),
                "%d valid outer layer selection" % n)
        else:
            check(lab.selected_layer == 1,
                "%d internal slice selectable" % n)
        if n==5:
            lab._change_layer(1)
            check(lab.selected_layer==2,"5x5 supports second inner slice")
        if n>=4:
            check(lab.layer_label.text.contains("INTERNA"),"inner layer appears in UI")
        await lab._do_turn(1)
        check(lab.cube.puzzle.is_valid() and lab.manual_moves==1,
            "%d manual turn preserves legal cubie coordinates" % n)
        lab._show_hint()
        check(lab.hint_label.text.contains("PRÓXIMO"),
            "%d accurate next undo move shown" % n)
        var remaining := 0
        while not lab.cube.is_solved() and remaining < 26:
            await lab._apply_hint()
            remaining += 1
        check(lab.cube.is_solved() and lab.cube.puzzle.is_valid(),
            "%d authentic puzzle solved after manual turn and legal hints" % n)
        check(lab.apply_button.disabled and lab.turn_buttons[0].disabled,
            "%d completed cube stops further turns" % n)
        lab._replay_scramble()
        check(not lab.cube.is_solved() and lab.manual_moves==0
            and lab.assisted_moves==0,
            "%d same-seed replay resets history and input" % n)
    check(session.balance()==balance_before and session.data["run_number"]==run_before,
        "laboratory never credits coins or begins a normal run")
    check(challenge.active_mode==mode_before and not challenge.run_started,
        "daily or weekly challenges are never started by practice")
    check(codex.discovery_total()==0 and career.runs.is_empty(),
        "practice never grants achievements or records a result")
    check(not FileAccess.file_exists(money)
        and not FileAccess.file_exists(journal)
        and not FileAccess.file_exists(history),
        "practice did not persist wallet, codex or result history")
    lab.queue_free()
    await process_frame
    for p in [money,daily,weekly,journal,history]:
        _clean(p)
    print("KubRogue C16 no-stakes laboratory: %d failures" % failures)
    quit(0 if failures==0 else 1)
