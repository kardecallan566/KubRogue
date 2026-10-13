extends Node3D
class_name KubRogueHand3D
## Lightweight procedural cartoon glove, deliberately original to KubRogue.
## Only a visual; puzzle moves and rewards belong to the gameplay controller.

var is_targeting := false
var action_flash := 0.0
var idle_clock := 0.0

func _ready() -> void:
    _make_hand()

func _make_material(hex: String) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = Color(hex)
    m.roughness = 0.64
    return m

func _add_box(part: String, dimensions: Vector3, pos: Vector3, mat: Material) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = part
    var mesh := BoxMesh.new()
    mesh.size = dimensions
    node.mesh = mesh
    node.position = pos
    node.material_override = mat
    add_child(node)
    return node

func _add_capsule(part: String, radius: float, height: float, pos: Vector3, mat: Material, tilt: float = 0.0) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = part
    var mesh := CapsuleMesh.new()
    mesh.radius = radius
    mesh.height = height
    node.mesh = mesh
    node.position = pos
    node.rotation.y = tilt
    node.rotation.x = PI * 0.5
    node.material_override = mat
    add_child(node)
    return node

func _make_hand() -> void:
    var glove := _make_material("#f7e8c8")
    var cuff := _make_material("#4769bb")
    var seam := _make_material("#e9b999")
    var palm := MeshInstance3D.new()
    palm.name = "RoundedPalm"
    var palm_mesh := SphereMesh.new()
    palm_mesh.radius = 0.5
    palm_mesh.height = 1.0
    palm.mesh = palm_mesh
    palm.scale = Vector3(0.63, 0.21, 0.51)
    palm.material_override = glove
    add_child(palm)
    for i in range(4):
        var x := (float(i) - 1.5) * 0.145
        _add_capsule("Finger_%d" % i, 0.072, 0.32 + (0.04 if i == 1 or i == 2 else 0.0),
            Vector3(x, -0.025, -0.35), glove)
    _add_capsule("Thumb", 0.10, 0.29, Vector3(-0.33, -0.03, -0.035), glove, 0.9)
    _add_box("WristCuff", Vector3(0.44, 0.21, 0.18), Vector3(0.0, 0.02, 0.33), cuff)
    _add_box("CuffSeam", Vector3(0.39, 0.035, 0.02), Vector3(0.0, -0.065, 0.225), seam)

func set_targeting(value: bool) -> void:
    is_targeting = value

func celebrate_gesture() -> void:
    action_flash = 0.36

func _process(delta: float) -> void:
    idle_clock += delta
    action_flash = maxf(0.0, action_flash - delta)
    var pulse := 1.08 if is_targeting else 1.0
    if action_flash > 0.0:
        pulse = 1.18
    scale = scale.lerp(Vector3.ONE * pulse, minf(delta * 13.0, 1.0))
    rotation.z = lerpf(rotation.z, -0.14 if action_flash > 0.0 else 0.0, minf(delta * 12.0, 1.0))
    rotation.y = sin(idle_clock * 1.7) * 0.045
