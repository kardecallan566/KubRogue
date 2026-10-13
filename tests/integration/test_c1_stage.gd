extends SceneTree
const Stage = preload("res://scripts/c1/hand_puzzle_prototype.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, detail: String) -> void:
    if not ok:
        failures += 1
        push_error("C1 STAGE FAIL: " + detail)

func _run() -> void:
    var stage: Stage = Stage.new()
    get_root().add_child(stage)
    check(stage.camera != null and stage.camera.projection == Camera3D.PROJECTION_ORTHOGONAL, "fixed orthographic camera")
    check(stage.hand != null, "hand exists")
    check(stage.hand.get_child_count() >= 6, "procedural palm and fingers")
    check(stage.cube != null and stage.cube.cubies.size() == 8, "real 2x2 in field")
    check(stage.cube.moves_remaining() > 0, "starts scrambled")
    check(stage.provisional_coins == 0 and stage.cubes_resolved == 0, "no free reward")
    var guard := 0
    while stage.cubes_resolved == 0 and guard < 8:
        await stage._advance_selected_cube()
        guard += 1
    check(stage.cubes_resolved == 1, "one puzzle solved")
    check(stage.provisional_coins == 10 and stage.provisional_xp == 1, "single provisional reward")
    check(stage.cube.moves_remaining() > 0, "next cube spawned automatically")
    check(not stage.respawning and not stage.cube.movement_busy, "unlocked after respawn")
    stage.queue_free()
    print("KubRogue C1 scene integration: %d failures" % failures)
    quit(0 if failures == 0 else 1)
