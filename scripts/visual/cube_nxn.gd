extends "res://scripts/visual/cube_3x3.gd"
## Parametric genuine 4x4x4 and 5x5x5 geometry.
## Uses the same rounded cubie meshes and legal pivot animation as C0–C7,
## but supports all inner/outer layers of the NxNxN integer puzzle state.
const NxState = preload("res://scripts/puzzle/cube_state_nxn.gd")
var order := 4
var physical_spacing := 0.28
var physical_cell := 0.265
var physical_sticker := 0.222
var physical_sticker_depth := 0.010

func _init(size: int = 4) -> void:
    order = clampi(size, 4, 5)
    physical_spacing = 1.14 / float(order)
    physical_cell = physical_spacing * 0.948
    physical_sticker = physical_cell * 0.83
    physical_sticker_depth = physical_cell * 0.037

func _new_puzzle():
    return NxState.new(order)

func visual_height() -> float:
    return physical_cell + float(order - 1) * physical_spacing

## Coordinates advance by two on every logical cubie position.
func _grid_step() -> float:
    return physical_spacing * 0.5

func _build_geometry() -> void:
    body_mesh = RoundedBox.make_mesh(Vector3.ONE * physical_cell,
        physical_cell * 0.070, 2)
    sticker_mesh = RoundedBox.make_mesh(
        Vector3(physical_sticker, physical_sticker, physical_sticker_depth),
        physical_sticker_depth * 0.23, 1
    )
    var body_material := _material(Color("#172436"), 0.37)
    var stickers := {}
    for face in COLORS:
        stickers[face] = _material(COLORS[face], 0.28)
    var outer := order - 1
    for id in puzzle.pieces:
        var home: Vector3i = puzzle.pieces[id]["position"]
        var cubie := Node3D.new()
        cubie.name = "Cubie_" + String(id).replace(",", "_")
        assembly.add_child(cubie)
        cubies[id] = cubie

        var body := MeshInstance3D.new()
        body.name = "RoundedBody"
        body.mesh = body_mesh
        body.material_override = body_material
        cubie.add_child(body)
        body_nodes.append(body)

        for face in COLORS:
            var direction: Vector3i = NxState.FACES[face]
            if NxState.dot_i(home, direction) != outer:
                continue
            var sticker := MeshInstance3D.new()
            sticker.name = "Sticker_" + face
            sticker.mesh = sticker_mesh
            sticker.material_override = stickers[face]
            sticker.position = Vector3(direction) * (
                physical_cell * 0.5 + physical_sticker_depth * 0.5 + 0.0005)
            sticker.quaternion = Quaternion(Vector3.BACK, Vector3(direction))
            cubie.add_child(sticker)
            sticker_nodes.append(sticker)

func scramble_now(count: int = 9, seed_value: int = 42) -> void:
    if movement_busy:
        return
    puzzle = _new_puzzle()
    var commands: Array[Dictionary] = puzzle.scramble(maxi(2, count), seed_value)
    for command in commands:
        puzzle.move(String(command["face"]), int(command["turns"]), int(command["layer"]), true)
    solution_plan = puzzle.reversed_history()
    sync_poses()

## Real quarter/half turns of outer and inner physical layers.
func rotate_layer(face: String, turns: int = 1, layer: int = 0,
        duration: float = 0.26, record: bool = false) -> void:
    if movement_busy or not NxState.FACES.has(face) or turns == 0 \
            or absi(turns) > 2 or layer < 0 or layer >= order:
        return
    movement_busy = true
    var axis: Vector3i = NxState.FACES[face]
    var selected: Array[String] = puzzle.selected_ids(face, layer)
    var pivot := Node3D.new()
    pivot.name = "RotatingSlice_%s_%d" % [face, layer]
    assembly.add_child(pivot)
    for id in selected:
        cubies[id].reparent(pivot, true)
    var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(pivot, "quaternion",
        Quaternion(Vector3(axis), float(turns) * PI * 0.5), maxf(0.001, duration))
    await tween.finished
    for id in selected:
        cubies[id].reparent(assembly, true)
    pivot.queue_free()
    puzzle.move(face, turns, layer, record)
    sync_poses()
    movement_busy = false
    rotation_finished.emit(face, turns, puzzle.is_solved())

func solve_next_move(duration: float = 0.26) -> void:
    if movement_busy or solution_plan.is_empty():
        return
    var command: Dictionary = solution_plan.pop_front()
    await rotate_layer(String(command["face"]), int(command["turns"]),
        int(command["layer"]), duration, false)
    if puzzle.is_solved():
        solution_plan.clear()
