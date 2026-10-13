extends SceneTree
const State = preload("res://scripts/puzzle/cube_state_2x2.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error("C1 UNIT FAIL: " + message)

func _run() -> void:
    var fresh = State.new()
    var initial: Dictionary = fresh.snapshot()
    check(fresh.pieces.size() == 8, "eight corners")
    check(fresh.is_valid() and fresh.is_solved(), "solved and valid at start")
    for face in State.FACES:
        var item = State.new()
        check(item.selected_ids(face).size() == 4, "four corners on " + face)
        item.move(face, 1)
        check(not item.is_solved(), "one turn changes " + face)
        item.move(face, -1)
        check(item.snapshot() == initial, "inverse restores " + face)
        item.move(face, 2)
        item.move(face, 2)
        check(item.snapshot() == initial, "half-turn pair restores " + face)
    for seed_value in range(1, 101):
        var item = State.new()
        var plan: Array[Dictionary] = item.scramble(10, seed_value)
        for cmd in plan:
            item.move(String(cmd["face"]), int(cmd["turns"]))
            check(item.is_valid(), "valid state seed %d" % seed_value)
        for command in item.reversed_history():
            item.move(String(command["face"]), int(command["turns"]), false)
        check(item.is_solved() and item.snapshot() == initial, "inverse seed %d" % seed_value)
    print("KubRogue C1 2x2 unit tests: %d failures" % failures)
    quit(0 if failures == 0 else 1)
