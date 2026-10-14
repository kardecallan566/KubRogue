extends SceneTree
const State = preload("res://scripts/puzzle/cube_state_nxn.gd")
const Visual = preload("res://scripts/visual/cube_nxn.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, name: String) -> void:
    if not ok:
        failures += 1
        push_error("C7 NXN FAIL: " + name)

func _run() -> void:
    for n in [4, 5]:
        var puzzle = State.new(n)
        var initial: Dictionary = puzzle.snapshot()
        var count: int = n * n * n - (n - 2) * (n - 2) * (n - 2)
        check(puzzle.pieces.size() == count, "%d: correct visible cubie count" % n)
        check(puzzle.is_valid() and puzzle.is_solved(), "%d: valid solved state" % n)
        for face in State.FACES:
            check(puzzle.selected_ids(face).size() == n * n, "%d: %s outer layer" % [n, face])
            check(puzzle.selected_ids(face, 1).size() == 4 * n - 4,
                "%d: %s inner slice" % [n, face])
            var original: Dictionary = puzzle.snapshot()
            puzzle.move(face, 1, 1, false)
            check(puzzle.is_valid() and not puzzle.is_solved(),
                "%d: inner layer %s rotates logically" % [n, face])
            puzzle.move(face, -1, 1, false)
            check(puzzle.snapshot() == original, "%d: inner slice inverse" % [n, face])
        var moves: Array[Dictionary] = puzzle.scramble(16, 4395)
        var repeat: Array[Dictionary] = State.new(n).scramble(16, 4395)
        check(moves == repeat, "%d: seeded scramble deterministic" % n)
        var internal := false
        for command in moves:
            internal = internal or int(command["layer"]) > 0
            check(puzzle.move(String(command["face"]), int(command["turns"]),
                int(command["layer"])), "%d: all scrambled moves legal" % n)
            check(puzzle.is_valid(), "%d: invariants after every move" % n)
        check(internal, "%d: scramble includes inner layers" % n)
        for command in puzzle.reversed_history():
            puzzle.move(String(command["face"]), int(command["turns"]),
                int(command["layer"]), false)
        check(puzzle.snapshot() == initial and puzzle.is_solved(),
            "%d: all outer/inner turns reversed exactly" % n)

        var visual = Visual.new(n)
        get_root().add_child(visual)
        check(visual.cubies.size() == count, "%d: visual cubies match domain" % n)
        check(visual.sticker_nodes.size() == 6 * n * n,
            "%d: 6 full colored faces, not enlarged 3x3" % n)
        check(visual.is_solved(), "%d: visual begins solved" % n)
        visual.scramble_now(6, 764)
        check(visual.solution_plan.size() == 6 and visual.puzzle.is_valid(),
            "%d: visual generated legal solution plan" % n)
        var moves_done := 0
        while visual.moves_remaining() > 0 and moves_done < 10:
            await visual.solve_next_move(0.001)
            moves_done += 1
        check(visual.is_solved() and visual.puzzle.is_valid(),
            "%d: physical inner and outer pivots return solved NxN" % n)
        visual.queue_free()
        await process_frame
    print("KubRogue C7 4x4/5x5 integer and visual tests: %d failures" % failures)
    quit(0 if failures == 0 else 1)
