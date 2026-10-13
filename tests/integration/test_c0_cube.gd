extends SceneTree
## Structural and reversible-animation smoke test for the adapted 3x3x3.
const CubeVisual = preload("res://scripts/visual/cube_3x3.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(value: bool, message: String) -> void:
    if not value:
        failures += 1
        push_error("C0 FALHOU: " + message)

func _run() -> void:
    var cube: CubeVisual = CubeVisual.new()
    get_root().add_child(cube)
    check(cube.cubies.size() == 26, "26 cubinhos externos presentes")
    check(cube.body_nodes.size() == 26, "26 meshes de corpo")
    check(cube.sticker_nodes.size() == 54, "54 adesivos 3D presentes")
    check(cube.body_mesh != null and cube.sticker_mesh != null, "2 meshes compartilhadas")
    check(cube.is_solved(), "estado inicial resolvido")

    var original: Dictionary = cube.puzzle.snapshot()
    await cube.rotate_layer("R", 1, 0.01)
    check(not cube.is_solved(), "giro R altera estado")
    await cube.rotate_layer("R", -1, 0.01)
    check(cube.is_solved(), "giro inverso restaura solução")
    check(cube.puzzle.snapshot() == original, "giro inverso restaura poses")

    cube.scramble_now(10, 2026)
    check(cube.moves_remaining() == 10, "plano inverso completo")
    check(not cube.is_solved(), "estado embaralhado")
    var guard := 0
    while cube.moves_remaining() > 0 and guard < 15:
        await cube.solve_next_move(0.01)
        guard += 1
    check(cube.is_solved(), "animações inversas resolvem o 3x3")
    check(cube.moves_remaining() == 0, "solução consumiu plano")
    check(not cube.movement_busy, "pivô liberado após última rotação")
    cube.queue_free()
    print("KubRogue C0 integration: %d failures" % failures)
    quit(0 if failures == 0 else 1)
