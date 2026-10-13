extends Node3D
## KubRogue C0 visual adapter based on the procedural 3x3x3 model in Kubos.
## Original reference: kardecallan566/Kubos, scripts/presentation/kubo_model.gd.
## Only geometry, color and legal layer rotations are retained. No Kubos gameplay.
class_name KubRogueCube3D

signal rotation_finished(face: String, turns: int, solved: bool)

const Puzzle = preload("res://scripts/puzzle/cube_state.gd")
const RoundedBox = preload("res://scripts/visual/rounded_box_mesh.gd")

const COLORS := {
    "U": Color("#f2f3f5"), "D": Color("#efcf35"),
    "R": Color("#dc4851"), "L": Color("#f18a36"),
    "F": Color("#39b97c"), "B": Color("#357cda")
}
const CELL := 0.327
const STEP := 0.338
const STICKER_SIZE := 0.283
const STICKER_DEPTH := 0.014
const BODY_RADIUS := 0.023

var puzzle
var cubies: Dictionary = {}
var body_nodes: Array[MeshInstance3D] = []
var sticker_nodes: Array[MeshInstance3D] = []
var assembly: Node3D
var body_mesh: ArrayMesh
var sticker_mesh: ArrayMesh
var movement_busy := false
var solution_plan: Array[Dictionary] = []

func _new_puzzle():
    return Puzzle.new()

func _ready() -> void:
    puzzle = _new_puzzle()
    assembly = Node3D.new()
    assembly.name = "CubeAssembly"
    add_child(assembly)
    _build_geometry()
    sync_poses()

func _material(color: Color, roughness: float = 0.34) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    material.metallic = 0.04
    return material

func _build_geometry() -> void:
    body_mesh = RoundedBox.make_mesh(Vector3.ONE * CELL, BODY_RADIUS, 3)
    sticker_mesh = RoundedBox.make_mesh(
        Vector3(STICKER_SIZE, STICKER_SIZE, STICKER_DEPTH), 0.005, 2
    )
    var body_material := _material(Color("#192436"), 0.40)
    var sticker_materials: Dictionary = {}
    for face in COLORS:
        sticker_materials[face] = _material(COLORS[face], 0.29)
    for id in puzzle.pieces:
        var home: Vector3i = puzzle.pieces[id]["position"]
        var piece := Node3D.new()
        piece.name = "Cubie_" + String(id).replace(",", "_")
        assembly.add_child(piece)
        cubies[id] = piece

        var body := MeshInstance3D.new()
        body.name = "RoundedBody"
        body.mesh = body_mesh
        body.material_override = body_material
        piece.add_child(body)
        body_nodes.append(body)

        for face in COLORS:
            var normal: Vector3i = Puzzle.FACES[face]
            if Puzzle.dot_i(home, normal) != 1:
                continue
            var sticker := MeshInstance3D.new()
            sticker.name = "Sticker_" + face
            sticker.mesh = sticker_mesh
            sticker.material_override = sticker_materials[face]
            sticker.position = Vector3(normal) * (CELL * 0.5 + STICKER_DEPTH * 0.5 + 0.001)
            sticker.quaternion = Quaternion(Vector3.BACK, Vector3(normal))
            piece.add_child(sticker)
            sticker_nodes.append(sticker)

func sync_poses() -> void:
    if puzzle == null:
        return
    for id in puzzle.pieces:
        var piece: Dictionary = puzzle.pieces[id]
        var p: Vector3i = piece["position"]
        var axes: Array = piece["axes"]
        var root: Node3D = cubies[id]
        root.position = Vector3(p) * STEP
        root.basis = Basis(
            Vector3(axes[0]), Vector3(axes[1]), Vector3(axes[2])
        ).orthonormalized()

func is_solved() -> bool:
    return puzzle != null and puzzle.is_solved()

func moves_remaining() -> int:
    return solution_plan.size()

## Rebuilds a new puzzle from the solved state. Only call while no animation is active.
func reset_cube() -> void:
    if movement_busy:
        return
    puzzle = _new_puzzle()
    solution_plan.clear()
    sync_poses()

func scramble_now(count: int = 9, seed_value: int = 42) -> void:
    if movement_busy:
        return
    puzzle = _new_puzzle()
    var commands: Array[Dictionary] = puzzle.scramble(maxi(2, count), seed_value)
    for command in commands:
        puzzle.move(String(command["face"]), int(command["turns"]), true)
    solution_plan = puzzle.reversed_history()
    sync_poses()

## Real pivot-based quarter/half-turn, followed by exact integer-domain snapping.
## record=false when consuming an inverse solution move.
func rotate_layer(face: String, turns: int = 1, duration: float = 0.26, record: bool = false) -> void:
    if movement_busy or not Puzzle.FACES.has(face) or turns == 0 or abs(turns) > 2:
        return
    movement_busy = true
    var axis: Vector3i = Puzzle.FACES[face]
    var selected: Array[String] = puzzle.selected_ids(face)
    var pivot := Node3D.new()
    pivot.name = "TemporaryLayerPivot"
    assembly.add_child(pivot)
    for id in selected:
        cubies[id].reparent(pivot, true)
    var tween := create_tween()
    tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(
        pivot, "quaternion",
        Quaternion(Vector3(axis), float(turns) * PI * 0.5),
        maxf(duration, 0.001)
    )
    await tween.finished
    for id in selected:
        cubies[id].reparent(assembly, true)
    pivot.queue_free()
    puzzle.move(face, turns, record)
    sync_poses()
    movement_busy = false
    rotation_finished.emit(face, turns, puzzle.is_solved())

func solve_next_move(duration: float = 0.26) -> void:
    if movement_busy or solution_plan.is_empty():
        return
    var command: Dictionary = solution_plan.pop_front()
    await rotate_layer(String(command["face"]), int(command["turns"]), duration, false)
    # The inverse history need not be mathematically shortest. End on actual solution.
    if puzzle.is_solved():
        solution_plan.clear()
