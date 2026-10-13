extends RefCounted
class_name CubeState
## Pure integer-domain state. Never depends on scene, mesh, camera or animation.
const FACES := {"U": Vector3i.UP, "D": Vector3i.DOWN, "R": Vector3i.RIGHT, "L": Vector3i.LEFT, "F": Vector3i(0, 0, 1), "B": Vector3i(0, 0, -1)}
var pieces: Dictionary = {}
var history: Array[Dictionary] = []

## Vector3i deliberately has no dot() / cross() methods in Godot 4.7.
## Keep all spatial domain operations entirely integer-based.
static func dot_i(a: Vector3i, b: Vector3i) -> int:
    return a.x * b.x + a.y * b.y + a.z * b.z

static func cross_i(a: Vector3i, b: Vector3i) -> Vector3i:
    return Vector3i(
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x
    )

func _init() -> void:
    for x in range(-1, 2):
        for y in range(-1, 2):
            for z in range(-1, 2):
                var p := Vector3i(x, y, z)
                if p == Vector3i.ZERO:
                    continue
                var basis := [Vector3i.RIGHT, Vector3i.UP, Vector3i(0, 0, 1)]
                var id := "%d,%d,%d" % [x, y, z]
                pieces[id] = {"position": p, "axes": basis.duplicate()}

static func rotate_vector(v: Vector3i, axis: Vector3i, turns: int) -> Vector3i:
    var out := v
    var direction := 1 if axis.x + axis.y + axis.z > 0 else -1
    for _i in range(posmod(turns * direction, 4)):
        if axis.x != 0:
            out = Vector3i(out.x, -out.z, out.y)
        elif axis.y != 0:
            out = Vector3i(out.z, out.y, -out.x)
        else:
            out = Vector3i(-out.y, out.x, out.z)
    return out

func selected_ids(face: String) -> Array[String]:
    var result: Array[String] = []
    if not FACES.has(face):
        return result
    var axis: Vector3i = FACES[face]
    for id in pieces:
        var p: Vector3i = pieces[id]["position"]
        if dot_i(p, axis) == 1:
            result.append(id)
    result.sort()
    return result

func move(face: String, turns: int = 1, record: bool = true) -> bool:
    if not FACES.has(face) or turns == 0 or abs(turns) > 2:
        return false
    var axis: Vector3i = FACES[face]
    for id in selected_ids(face):
        var piece: Dictionary = pieces[id]
        piece["position"] = rotate_vector(piece["position"], axis, turns)
        var old_axes: Array = piece["axes"]
        var new_axes: Array = []
        for v in old_axes:
            new_axes.append(rotate_vector(v, axis, turns))
        piece["axes"] = new_axes
        pieces[id] = piece
    if record:
        history.append({"face": face, "turns": turns})
    return true

func scramble(count: int, seed_value: int = 0) -> Array[Dictionary]:
    var rng := RandomNumberGenerator.new()
    if seed_value == 0:
        rng.randomize()
    else:
        rng.seed = seed_value
    var faces := FACES.keys()
    var commands: Array[Dictionary] = []
    var previous := ""
    for _i in range(maxi(0, count)):
        var face: String = faces[rng.randi_range(0, faces.size() - 1)]
        while face == previous:
            face = faces[rng.randi_range(0, faces.size() - 1)]
        var turns: int = [-1, 1, 2][rng.randi_range(0, 2)]
        commands.append({"face": face, "turns": turns})
        previous = face
    return commands

func reversed_history() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for i in range(history.size() - 1, -1, -1):
        var command: Dictionary = history[i]
        result.append({"face": command["face"], "turns": -int(command["turns"])})
    return result

func snapshot() -> Dictionary:
    var entries: Array[Dictionary] = []
    var ids := pieces.keys()
    ids.sort()
    for id in ids:
        var p: Vector3i = pieces[id]["position"]
        var axes: Array = pieces[id]["axes"]
        entries.append({"id": id, "p": [p.x, p.y, p.z],
            "a": [[axes[0].x, axes[0].y, axes[0].z], [axes[1].x, axes[1].y, axes[1].z], [axes[2].x, axes[2].y, axes[2].z]]})
    return {"version": 1, "pieces": entries}

func is_valid() -> bool:
    if pieces.size() != 26:
        return false
    var occupied := {}
    for id in pieces:
        var piece: Dictionary = pieces[id]
        var p: Vector3i = piece["position"]
        if p == Vector3i.ZERO or maxi(abs(p.x), maxi(abs(p.y), abs(p.z))) > 1 or occupied.has(p):
            return false
        occupied[p] = true
        var a: Array = piece["axes"]
        if a.size() != 3:
            return false
        var right: Vector3i = a[0]
        var up: Vector3i = a[1]
        var back: Vector3i = a[2]
        if dot_i(right, up) != 0 or dot_i(up, back) != 0 or dot_i(right, back) != 0:
            return false
        if right.length_squared() != 1 or up.length_squared() != 1 or back.length_squared() != 1:
            return false
        if cross_i(right, up) != back:
            return false
    return true

func is_solved() -> bool:
    # Check the canonical integer pose directly. Do not instantiate this
    # script by its own class_name: cold Godot starts may not have populated
    # the global script-class registry when compiling this file.
    if not is_valid():
        return false
    for id in pieces:
        var piece: Dictionary = pieces[id]
        var position: Vector3i = piece["position"]
        if String(id) != "%d,%d,%d" % [position.x, position.y, position.z]:
            return false
        var axes: Array = piece["axes"]
        if axes[0] != Vector3i.RIGHT or axes[1] != Vector3i.UP or axes[2] != Vector3i(0, 0, 1):
            return false
    return true
