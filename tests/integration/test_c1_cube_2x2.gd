extends SceneTree
const Model = preload("res://scripts/visual/cube_2x2.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, detail: String) -> void:
    if not ok:
        failures += 1
        push_error("C1 2x2 FAIL: " + detail)

func _run() -> void:
    var cube: Model = Model.new()
    get_root().add_child(cube)
    check(cube.cubies.size() == 8, "eight real cubies")
    check(cube.body_nodes.size() == 8, "eight meshes")
    check(cube.sticker_nodes.size() == 24, "24 stickers")
    check(cube.is_solved(), "solved initial condition")
    var original: Dictionary = cube.puzzle.snapshot()
    await cube.rotate_layer("F", 1, 0.01)
    check(not cube.is_solved(), "rotating face changes state")
    await cube.rotate_layer("F", -1, 0.01)
    check(cube.puzzle.snapshot() == original, "inverse animation restores")
    for seed_value in range(1, 11):
        cube.scramble_now(4 + seed_value % 3, seed_value)
        var guard := 0
        while cube.moves_remaining() > 0 and guard < 12:
            await cube.solve_next_move(0.001)
            guard += 1
        check(cube.is_solved(), "reverses whole scramble %d" % seed_value)
        check(not cube.movement_busy, "releases pivot %d" % seed_value)
    cube.queue_free()
    print("KubRogue C1 2x2 visual tests: %d failures" % failures)
    quit(0 if failures == 0 else 1)
