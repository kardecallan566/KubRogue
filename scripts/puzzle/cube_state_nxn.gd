extends RefCounted
## Integer, orientation-aware state for actual visible NxNxN puzzle cubies.
## Supports outer and inner slices, including even-sized 4x4 middle layers.
## Inner invisible core is omitted (only surface cubies can carry stickers).
const BaseState = preload("res://scripts/puzzle/cube_state.gd")
const FACES = BaseState.FACES

var order := 4
var limit := 3
var pieces: Dictionary = {}
var history: Array[Dictionary] = []

func _init(size: int = 4) -> void:
    order = clampi(size, 4, 5)
    limit = order - 1
    for ix in range(order):
        for iy in range(order):
            for iz in range(order):
                if ix > 0 and iy > 0 and iz > 0 \
                        and ix < order - 1 and iy < order - 1 and iz < order - 1:
                    continue
                var pos := Vector3i(-limit + 2 * ix, -limit + 2 * iy, -limit + 2 * iz)
                var id := "%d,%d,%d" % [pos.x, pos.y, pos.z]
                pieces[id] = {
                    "position": pos,
                    "axes": [Vector3i.RIGHT, Vector3i.UP, Vector3i(0, 0, 1)]
                }

static func dot_i(a: Vector3i, b: Vector3i) -> int:
    return BaseState.dot_i(a, b)

static func cross_i(a: Vector3i, b: Vector3i) -> Vector3i:
    return BaseState.cross_i(a, b)

static func rotate_vector(v: Vector3i, axis: Vector3i, turns: int) -> Vector3i:
    return BaseState.rotate_vector(v, axis, turns)

func selected_ids(face: String, layer: int = 0) -> Array[String]:
    var result: Array[String] = []
    if not FACES.has(face) or layer < 0 or layer >= order:
        return result
    var normal: Vector3i = FACES[face]
    var coordinate := limit - 2 * layer
    for id in pieces:
        var p: Vector3i = pieces[id]["position"]
        if dot_i(p, normal) == coordinate:
            result.append(id)
    result.sort()
    return result

func move(face: String, turns: int = 1, layer: int = 0, record: bool = true) -> bool:
    if not FACES.has(face) or turns == 0 or absi(turns) > 2 \
            or layer < 0 or layer >= order:
        return false
    var axis: Vector3i = FACES[face]
    for id in selected_ids(face, layer):
        var piece: Dictionary = pieces[id]
        piece["position"] = rotate_vector(piece["position"], axis, turns)
        var current: Array = piece["axes"]
        var rotated: Array = []
        for v in current:
            rotated.append(rotate_vector(v, axis, turns))
        piece["axes"] = rotated
        pieces[id] = piece
    if record:
        history.append({"face":face, "layer":layer, "turns":turns})
    return true

func scramble(count: int, seed_value: int = 0) -> Array[Dictionary]:
    var rng := RandomNumberGenerator.new()
    if seed_value == 0:
        rng.randomize()
    else:
        rng.seed = seed_value
    var faces: Array = FACES.keys()
    var result: Array[Dictionary] = []
    var previous_axis := ""
    for _i in range(maxi(0, count)):
        var face: String = String(faces[rng.randi_range(0, faces.size() - 1)])
        var layer := rng.randi_range(0, order - 2)
        # Keep at least some internal slices, but avoid identity through
        # consecutive identical slice repeats.
        var key := face + "-" + str(layer)
        while key == previous_axis:
            face = String(faces[rng.randi_range(0, faces.size() - 1)])
            layer = rng.randi_range(0, order - 2)
            key = face + "-" + str(layer)
        var turns: int = [-1, 1, 2][rng.randi_range(0, 2)]
        result.append({"face":face, "layer":layer, "turns":turns})
        previous_axis = key
    return result

func reversed_history() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for i in range(history.size() - 1, -1, -1):
        var item: Dictionary = history[i]
        result.append({"face":item["face"], "layer":item["layer"], "turns":-int(item["turns"])})
    return result

func snapshot() -> Dictionary:
    var items: Array[Dictionary] = []
    var ids := pieces.keys()
    ids.sort()
    for id in ids:
        var piece: Dictionary = pieces[id]
        var p: Vector3i = piece["position"]
        var a: Array = piece["axes"]
        items.append({"id":id, "p":[p.x,p.y,p.z],
            "a":[[a[0].x,a[0].y,a[0].z],[a[1].x,a[1].y,a[1].z],[a[2].x,a[2].y,a[2].z]]})
    return {"size":order, "pieces":items}

func is_valid() -> bool:
    var expected := order * order * order - (order - 2) * (order - 2) * (order - 2)
    if pieces.size() != expected:
        return false
    var locations := {}
    for id in pieces:
        var piece: Dictionary = pieces[id]
        var p: Vector3i = piece["position"]
        if absi(p.x) > limit or absi(p.y) > limit or absi(p.z) > limit:
            return false
        if posmod(p.x + limit, 2) != 0 or posmod(p.y + limit, 2) != 0 \
                or posmod(p.z + limit, 2) != 0:
            return false
        if absi(p.x) != limit and absi(p.y) != limit and absi(p.z) != limit:
            return false
        if locations.has(p):
            return false
        locations[p] = true
        var a: Array = piece["axes"]
        if a.size() != 3:
            return false
        var x: Vector3i = a[0]
        var y: Vector3i = a[1]
        var z: Vector3i = a[2]
        if x.length_squared() != 1 or y.length_squared() != 1 or z.length_squared() != 1:
            return false
        if dot_i(x,y) != 0 or dot_i(x,z) != 0 or dot_i(y,z) != 0:
            return false
        if cross_i(x,y) != z:
            return false
    return true

func is_solved() -> bool:
    if not is_valid():
        return false
    for id in pieces:
        var item: Dictionary = pieces[id]
        var p: Vector3i = item["position"]
        var axes: Array = item["axes"]
        if String(id) != "%d,%d,%d" % [p.x,p.y,p.z]:
            return false
        if axes[0] != Vector3i.RIGHT or axes[1] != Vector3i.UP \
                or axes[2] != Vector3i(0,0,1):
            return false
    return true
