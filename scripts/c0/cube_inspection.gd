extends Node3D
## Checkpoint C0 — visual inspection, not a playable roguelite arena.
const CubeVisual = preload("res://scripts/visual/cube_3x3.gd")

var cube: CubeVisual
var status: Label
var next_seed := 43
var auto_solving := false

func _ready() -> void:
    _build_field()
    _build_camera()
    _build_lighting()
    cube = CubeVisual.new()
    cube.name = "KubosDerivedCube3x3"
    cube.position = Vector3(0.0, 1.1, 0.0)
    cube.scale = Vector3.ONE * 1.55
    add_child(cube)
    cube.rotation_finished.connect(_on_rotation_finished)
    _build_ui()
    _on_scramble()

func _build_field() -> void:
    var ground := MeshInstance3D.new()
    ground.name = "OpenGrassField"
    var plane := PlaneMesh.new()
    plane.size = Vector2(80, 80)
    ground.mesh = plane
    var material := StandardMaterial3D.new()
    material.albedo_color = Color("#a2c88c")
    material.roughness = 1.0
    ground.material_override = material
    add_child(ground)
    var rng := RandomNumberGenerator.new()
    rng.seed = 137
    # Low-profile grass spots; all decorative, with no collision.
    for i in range(46):
        var patch := MeshInstance3D.new()
        patch.name = "GrassPatch_%02d" % i
        var mesh := SphereMesh.new()
        mesh.radius = rng.randf_range(0.09, 0.22)
        mesh.height = 0.035
        patch.mesh = mesh
        var grass_material := StandardMaterial3D.new()
        grass_material.albedo_color = Color("#91bd7e") if i % 2 == 0 else Color("#b0d59c")
        grass_material.roughness = 1.0
        patch.material_override = grass_material
        patch.position = Vector3(
            rng.randf_range(-6.5, 6.5), 0.02,
            rng.randf_range(-4.5, 4.5)
        )
        if Vector2(patch.position.x, patch.position.z).length() < 2.0:
            patch.position.x += 2.5
        add_child(patch)

func _build_camera() -> void:
    var camera := Camera3D.new()
    camera.name = "FixedTopDownCamera"
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = 7.5
    camera.position = Vector3(3.4, 10.8, 4.6)
    add_child(camera)
    camera.look_at(Vector3(0, 0.75, 0), Vector3.UP)
    camera.current = true

func _build_lighting() -> void:
    var world := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color("#a2c88c")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("#e9f2eb")
    environment.ambient_light_energy = 0.76
    world.environment = environment
    add_child(world)
    var sun := DirectionalLight3D.new()
    sun.name = "SoftSun"
    sun.rotation_degrees = Vector3(-62, -30, 0)
    sun.light_energy = 1.1
    sun.shadow_enabled = true
    add_child(sun)

func _add_caption(parent: Node, value: String, font_size: int = 18) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_font_size_override("font_size", font_size)
    parent.add_child(label)
    return label

func _make_button(parent: Node, name_text: String, method: Callable) -> void:
    var button := Button.new()
    button.text = name_text
    button.custom_minimum_size = Vector2(0, 37)
    button.pressed.connect(method)
    parent.add_child(button)

func _build_ui() -> void:
    var layer := CanvasLayer.new()
    layer.name = "InspectionOverlay"
    add_child(layer)
    var panel := PanelContainer.new()
    panel.position = Vector2(22, 20)
    panel.custom_minimum_size = Vector2(345, 0)
    layer.add_child(panel)
    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation", 9)
    panel.add_child(content)
    _add_caption(content, "KUBROGUE  |  CHECKPOINT C0", 22)
    _add_caption(content, "Inspeção do modelo 3x3x3 do Kubos", 15)
    _add_caption(content, "26 cubinhos  ·  54 placas 3D", 15)
    _make_button(content, "Embaralhar (seed reproduzível)", _on_scramble)
    _make_button(content, "Resolver próximo giro", _on_next_move)
    _make_button(content, "Resolver todos os giros", _on_solve_all)
    _make_button(content, "Reiniciar cubo", _on_reset)
    status = _add_caption(content, "", 16)
    status.custom_minimum_size = Vector2(320, 48)
    status.autowrap_mode = TextServer.AUTOWRAP_WORD
    _refresh_status()

func _refresh_status() -> void:
    if status == null or cube == null:
        return
    status.text = "Estado: %s  |  movimentos: %d\nSeed seguinte: %d" % [
        "RESOLVIDO" if cube.is_solved() else "embaralhado",
        cube.moves_remaining(), next_seed
    ]

func _on_scramble() -> void:
    if auto_solving or cube.movement_busy:
        return
    cube.scramble_now(9, next_seed)
    next_seed += 1
    _refresh_status()

func _on_next_move() -> void:
    if auto_solving or cube.movement_busy:
        return
    await cube.solve_next_move()
    _refresh_status()

func _on_solve_all() -> void:
    if auto_solving or cube.movement_busy:
        return
    auto_solving = true
    while cube.moves_remaining() > 0:
        await cube.solve_next_move()
    auto_solving = false
    _refresh_status()

func _on_reset() -> void:
    if auto_solving or cube.movement_busy:
        return
    cube.reset_cube()
    _refresh_status()

func _on_rotation_finished(_face: String, _turns: int, _solved: bool) -> void:
    _refresh_status()
