extends Node3D
## C1 playable vertical slice: the cursor controls a 3D hand to solve real 2x2 cubies.
## No waves, economy persistence or roguelite cards exist yet.
class_name KubRogueC1Stage

const CubeVisual = preload("res://scripts/visual/cube_2x2.gd")
const HandVisual = preload("res://scripts/visual/hand_3d.gd")
const ACTION_INTERVAL := 0.34
const ROTATION_DURATION := 0.26
const TARGET_RADIUS := 1.22
const REWARD_COINS := 10
const REWARD_XP := 1

var camera: Camera3D
var cube: CubeVisual
var hand: HandVisual
var focus_ring: MeshInstance3D
var counter_label: Label
var instruction_label: Label
var reward_label: Label
var hint_label: Label
var round_label: Label

var has_target := false
var provisional_coins := 0
var provisional_xp := 0
var cubes_resolved := 0
var current_seed := 42
var displayed_seed := 0
var action_cooldown := 0.0
var rewarded_this_cube := false
var respawning := false

func _ready() -> void:
    _build_field()
    _build_light_and_camera()
    _build_actors()
    _build_overlay()
    _spawn_cube()

func _field_material(color: Color) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 1.0
    return mat

func _build_field() -> void:
    var ground := MeshInstance3D.new()
    ground.name = "JardimDosCubos_OpenGrass"
    var plane := PlaneMesh.new()
    plane.size = Vector2(90.0, 90.0)
    ground.mesh = plane
    ground.material_override = _field_material(Color("#a4cd8c"))
    add_child(ground)
    # Original simplified tufts: intentionally no obstacles, physics or grid.
    var rng := RandomNumberGenerator.new()
    rng.seed = 1107
    var patch_mesh := SphereMesh.new()
    patch_mesh.radius = 0.20
    patch_mesh.height = 0.032
    var light_patch := _field_material(Color("#b9dc9d"))
    var shade_patch := _field_material(Color("#8eb97b"))
    for i in range(66):
        var patch := MeshInstance3D.new()
        patch.name = "SoftGrassPatch_%02d" % i
        patch.mesh = patch_mesh
        patch.material_override = light_patch if i % 3 == 0 else shade_patch
        var x := rng.randf_range(-9.0, 9.0)
        var z := rng.randf_range(-6.5, 6.5)
        if Vector2(x, z).length() < 1.5:
            x += 2.8
        patch.position = Vector3(x, 0.014, z)
        var dim := rng.randf_range(0.45, 1.55)
        patch.scale = Vector3(dim, 1.0, dim * rng.randf_range(0.55, 1.3))
        add_child(patch)

func _build_light_and_camera() -> void:
    var world := WorldEnvironment.new()
    world.name = "SoftDaylight"
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("#a4cd8c")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#eef5e8")
    env.ambient_light_energy = 0.85
    world.environment = env
    add_child(world)
    var light := DirectionalLight3D.new()
    light.name = "SunnySoftLight"
    light.rotation_degrees = Vector3(-61, -32, 0)
    light.light_energy = 1.05
    light.shadow_enabled = true
    add_child(light)
    camera = Camera3D.new()
    camera.name = "FixedTopDown"
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = 8.3
    camera.position = Vector3(2.6, 11.5, 3.5)
    add_child(camera)
    camera.look_at(Vector3(0.0, 0.15, 0.0), Vector3.UP)
    camera.current = true

func _build_actors() -> void:
    cube = CubeVisual.new()
    cube.name = "TargetCube2x2"
    cube.scale = Vector3.ONE * 1.72
    cube.position = Vector3(0.65, 0.58, 0.0)
    add_child(cube)
    hand = HandVisual.new()
    hand.name = "CursorHand"
    hand.position = Vector3(-1.2, 1.4, 1.0)
    add_child(hand)

    focus_ring = MeshInstance3D.new()
    focus_ring.name = "TargetFocusRing"
    var mesh := TorusMesh.new()
    mesh.inner_radius = 0.84
    mesh.outer_radius = 0.92
    focus_ring.mesh = mesh
    var ring_mat := StandardMaterial3D.new()
    ring_mat.albedo_color = Color("#f3f9d1")
    ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    focus_ring.material_override = ring_mat
    focus_ring.position = Vector3(cube.position.x, 0.08, cube.position.z)
    focus_ring.visible = false
    add_child(focus_ring)

func _add_label(parent: Node, value: String, size: int = 17) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_font_size_override("font_size", size)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(label)
    return label

func _build_overlay() -> void:
    var layer := CanvasLayer.new()
    layer.name = "C1Overlay"
    add_child(layer)
    var panel := PanelContainer.new()
    panel.position = Vector2(22, 22)
    panel.custom_minimum_size = Vector2(328, 0)
    panel.mouse_filter = Control.MOUSE_FILTER_STOP
    layer.add_child(panel)
    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation", 8)
    panel.add_child(content)
    _add_label(content, "KUBROGUE  •  C1", 24)
    _add_label(content, "Jardim dos Cubos  |  Protótipo", 16)
    instruction_label = _add_label(content, "Mova a mão sobre o cubo.", 17)
    instruction_label.autowrap_mode = TextServer.AUTOWRAP_WORD
    counter_label = _add_label(content, "", 16)
    round_label = _add_label(content, "", 16)
    reward_label = _add_label(content, "Resolva os cubos para ganhar moedas de teste.", 15)
    reward_label.autowrap_mode = TextServer.AUTOWRAP_WORD
    hint_label = _add_label(content, "Clique ou segure o botão esquerdo para girar.", 14)
    hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD
    var button := Button.new()
    button.text = "Novo cubo (reiniciar seed)"
    button.custom_minimum_size = Vector2(0, 35)
    button.pressed.connect(_manual_new_cube)
    content.add_child(button)
    _update_hud()

func _spawn_cube() -> void:
    if cube == null or cube.movement_busy:
        return
    rewarded_this_cube = false
    displayed_seed = current_seed
    current_seed += 1
    cube.scramble_now(3 + posmod(cubes_resolved, 2), displayed_seed)
    # Very short shuffle sequences can occasionally collapse to solved; retry.
    var attempts := 0
    while cube.is_solved() and attempts < 8:
        displayed_seed = current_seed
        current_seed += 1
        cube.scramble_now(4, displayed_seed)
        attempts += 1
    respawning = false
    _update_hud()

func _manual_new_cube() -> void:
    if respawning or cube.movement_busy:
        return
    _spawn_cube()

func _update_hud() -> void:
    if counter_label == null or cube == null:
        return
    counter_label.text = "Giros restantes: %d  |  Seed: %d" % [cube.moves_remaining(), displayed_seed]
    round_label.text = "Resolvidos: %d  |  Moedas teste: %d  |  XP teste: %d" % [
        cubes_resolved, provisional_coins, provisional_xp
    ]
    if respawning:
        instruction_label.text = "Resolvido! Um novo cubo está chegando."
    elif has_target:
        instruction_label.text = "Alvo selecionado: clique ou segure para resolver."
    else:
        instruction_label.text = "Aproxime a mão do cubo colorido."

func _cursor_ground_point() -> Variant:
    if camera == null:
        return null
    var mouse := get_viewport().get_mouse_position()
    var origin := camera.project_ray_origin(mouse)
    var direction := camera.project_ray_normal(mouse)
    if absf(direction.y) < 0.00001:
        return null
    var distance := -origin.y / direction.y
    if distance < 0.0:
        return null
    return origin + direction * distance

func _pointer_on_hud() -> bool:
    return get_viewport().gui_get_hovered_control() != null

func _process(delta: float) -> void:
    action_cooldown = maxf(0.0, action_cooldown - delta)
    var point: Variant = _cursor_ground_point()
    var targetable := false
    if point is Vector3 and is_instance_valid(hand) and is_instance_valid(cube):
        var hit: Vector3 = point
        var safe_point := Vector3(
            clampf(hit.x, -5.9, 5.9), 1.43,
            clampf(hit.z, -3.5, 3.5)
        )
        # Keep the drawn hand beside the actual cursor so stickers stay readable.
        var hand_pos := safe_point + Vector3(0.47, 0.0, 0.29)
        hand.position = hand.position.lerp(hand_pos, minf(delta * 17.0, 1.0))
        var horizontal_delta := Vector2(hit.x - cube.position.x, hit.z - cube.position.z)
        targetable = horizontal_delta.length() <= TARGET_RADIUS and not _pointer_on_hud()
        targetable = targetable and not respawning and not cube.movement_busy and not cube.is_solved()
    if targetable != has_target:
        has_target = targetable
        _update_hud()
    if is_instance_valid(hand):
        hand.set_targeting(has_target)
    if is_instance_valid(focus_ring):
        focus_ring.visible = has_target
    if has_target and action_cooldown <= 0.0 and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        _advance_selected_cube()

## Common gameplay action used by live mouse input and C1 integration tests.
## The caller enforces hover for real mouse actions. This method validates
## progression, cooldown/busy and idempotence, but not spatial selection.
func _advance_selected_cube() -> void:
    if cube == null or cube.movement_busy or cube.is_solved() or rewarded_this_cube or respawning:
        return
    action_cooldown = ACTION_INTERVAL
    hand.celebrate_gesture()
    await cube.solve_next_move(ROTATION_DURATION)
    if not is_inside_tree() or not is_instance_valid(cube):
        return
    if cube.is_solved() and not rewarded_this_cube:
        rewarded_this_cube = true
        respawning = true
        cubes_resolved += 1
        provisional_coins += REWARD_COINS
        provisional_xp += REWARD_XP
        if reward_label != null:
            reward_label.text = "RESOLVIDO!  +10 moedas e +1 XP (teste)."
        _update_hud()
        await get_tree().create_timer(0.58).timeout
        if is_inside_tree():
            _spawn_cube()
    else:
        _update_hud()
