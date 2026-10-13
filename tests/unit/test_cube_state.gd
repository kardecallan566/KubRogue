extends SceneTree
const Cube = preload("res://scripts/puzzle/cube_state.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(value: bool, message: String) -> void:
    if not value:
        failures += 1
        push_error("FALHOU: " + message)

func _run() -> void:
    var solved := Cube.new()
    var initial := solved.snapshot()
    check(solved.is_valid(), "26 posicoes validas")
    check(solved.pieces.size() == 26, "26 IDs unicos")
    check(solved.is_solved(), "solved inicial sem dependencia circular de class_name")
    var one_move := Cube.new()
    one_move.move("R")
    check(not one_move.is_solved(), "giro R muda o estado para nao resolvido")
    one_move.move("R", -1)
    check(one_move.is_solved(), "giro inverso restaura solved")
    for face in Cube.FACES:
        var cube := Cube.new()
        check(cube.selected_ids(face).size() == 9, "9 cubies face " + face)
        for _i in range(4):
            cube.move(face)
        check(cube.snapshot() == initial, "quatro giros " + face)
        cube = Cube.new()
        cube.move(face, 1)
        cube.move(face, -1)
        check(cube.snapshot() == initial, "inversos " + face)
    for seed_value in range(1, 21):
        var cube := Cube.new()
        for cmd in cube.scramble(50, seed_value):
            cube.move(cmd["face"], cmd["turns"])
            check(cube.is_valid(), "invariantes seed %d" % seed_value)
        for cmd in cube.reversed_history():
            cube.move(cmd["face"], cmd["turns"], false)
        check(cube.snapshot() == initial, "reversao seed %d" % seed_value)
    print("KUBOS domain tests: %d failures" % failures)
    quit(0 if failures == 0 else 1)
