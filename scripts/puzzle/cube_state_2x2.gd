extends "res://scripts/puzzle/cube_state.gd"
class_name CubeState2x2
## Reuses the integer 3x3 movement engine, but exposes only eight corners.
## Six physical faces, four stickers per face, no fictitious HP or fake grid.

func _init() -> void:
    pieces.clear()
    history.clear()
    for x in [-1, 1]:
        for y in [-1, 1]:
            for z in [-1, 1]:
                var pos := Vector3i(x, y, z)
                var id := "%d,%d,%d" % [x, y, z]
                pieces[id] = {
                    "position": pos,
                    "axes": [Vector3i.RIGHT, Vector3i.UP, Vector3i(0, 0, 1)]
                }

func is_valid() -> bool:
    if pieces.size() != 8:
        return false
    var occupied := {}
    for id in pieces:
        var item: Dictionary = pieces[id]
        var p: Vector3i = item["position"]
        if abs(p.x) != 1 or abs(p.y) != 1 or abs(p.z) != 1 or occupied.has(p):
            return false
        occupied[p] = true
        var axes: Array = item["axes"]
        if axes.size() != 3:
            return false
        var a: Vector3i = axes[0]
        var b: Vector3i = axes[1]
        var c: Vector3i = axes[2]
        if a.length_squared() != 1 or b.length_squared() != 1 or c.length_squared() != 1:
            return false
        if dot_i(a, b) != 0 or dot_i(a, c) != 0 or dot_i(b, c) != 0:
            return false
        if cross_i(a, b) != c:
            return false
    return true

func is_solved() -> bool:
    ## C1 uses the canonical identity pose, fully restored by the recorded inverse.
    ## Future free-form cubing will need a face-uniform acceptance predicate.
    if not is_valid():
        return false
    for id in pieces:
        var item: Dictionary = pieces[id]
        var p: Vector3i = item["position"]
        if id != "%d,%d,%d" % [p.x, p.y, p.z]:
            return false
        var axes: Array = item["axes"]
        if axes[0] != Vector3i.RIGHT or axes[1] != Vector3i.UP or axes[2] != Vector3i(0, 0, 1):
            return false
    return true
