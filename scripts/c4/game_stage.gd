extends Node3D
class_name KubRogueC4Stage
## Explicit script dependency so 'godot .' works with a fresh .godot/ cache.
## The autoload is still registered as /root/KubeSession in project.godot.
const ProgressScript = preload("res://scripts/c4/progress_service.gd")
## Checkpoint C2: multi-cube wave gameplay, with in-memory currency and XP.
## Final 5 waves, 3x3 boss, abilities, persistent shop belong to C3/C4.
const WaveRules = preload("res://scripts/c3/roguelite_director.gd")
const Build = preload("res://scripts/c3/run_build.gd")
const BossVisual = preload("res://scripts/visual/cube_3x3.gd")
const CubeBase = preload("res://scripts/visual/cube_3x3.gd")
const CubeVisual = preload("res://scripts/visual/cube_2x2.gd")
const HandCursor = preload("res://scripts/visual/hand_cursor_2d.gd")
const ACTION_INTERVAL := 0.34
const ROTATION_DURATION := 0.26
const TARGET_RADIUS := 0.95
const MAX_CUBES := 4

var director: WaveRules
var progress: ProgressScript
var save_ready := false
var pending_credits: Dictionary = {}
var best_combo_in_run := 0
var bank_label: Label
var exit_dialog: ConfirmationDialog
var retry_button: Button
var build: Build
var offers_open := false
var advance_after_offers := false
var combo_streak := 0
var last_solve_time := -999.0
var card_overlay: ColorRect
var card_center: CenterContainer
var card_header: Label
var card_buttons: Array[Button] = []
var camera: Camera3D
var hand: HandCursor
var actors: Dictionary = {} # cube_id -> {root, cube, ring, kind, home}
var focused_id := -1
var action_locked := false
var action_cooldown := 0.0
var spawn_attempt := 0
var animation_clock := 0.0
var paused := false

var hud_panel: PanelContainer
var title_label: Label
var wave_label: Label
var time_label: Label
var stability_label: Label
var stats_label: Label
var target_label: Label
var message_label: Label
var summary_panel: PanelContainer
var summary_title: Label
var summary_body: Label
var summary_button: Button
var pause_button: Button

const SPAWN_POINTS := [
    Vector2(-4.4, -2.0), Vector2(-3.1, 1.7),
    Vector2(-1.7, -2.3), Vector2(1.2, 1.9),
    Vector2(3.1, -2.1), Vector2(4.45, 1.5),
    Vector2(-4.2, 0.0), Vector2(3.4, 0.2),
    Vector2(-0.8, 0.75), Vector2(1.15, -0.75),
    Vector2(-2.35, -0.55), Vector2(2.0, 0.9)
]

func _ready() -> void:
    progress = get_node("/root/KubeSession") as ProgressScript
    _build_field()
    _build_light_and_camera()
    _build_hud()
    build = Build.new()
    director = WaveRules.new(build)
    restart_run()

func _field_material(color: Color) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 1.0
    # Preserve the actual soft-green field in Compatibility/Forward+.
    # Sun and ambient lighting were overexposing the grass in Windows.
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
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


func _add_label(parent: Node, value: String, size: int = 18) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_font_size_override("font_size", size)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(label)
    return label

func _build_hud() -> void:
    var overlay := CanvasLayer.new()
    overlay.name = "C2Overlay"
    add_child(overlay)
    hud_panel = PanelContainer.new()
    hud_panel.name = "WaveHUD"
    hud_panel.position = Vector2(20.0, 18.0)
    hud_panel.custom_minimum_size = Vector2(335.0, 0.0)
    hud_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.add_child(hud_panel)
    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation", 5)
    hud_panel.add_child(content)
    title_label = _add_label(content, "KUBROGUE   ·   C4", 24)
    _add_label(content, "Jardim dos Cubos | Roguelite", 16)
    wave_label = _add_label(content, "", 17)
    time_label = _add_label(content, "", 18)
    stability_label = _add_label(content, "", 17)
    stats_label = _add_label(content, "", 16)
    bank_label = _add_label(content, "", 16)
    target_label = _add_label(content, "", 16)
    target_label.autowrap_mode = TextServer.AUTOWRAP_WORD
    message_label = _add_label(content, "Clique ou segure a mão sobre os cubos.", 15)
    message_label.autowrap_mode = TextServer.AUTOWRAP_WORD

    var actions := HBoxContainer.new()
    actions.add_theme_constant_override("separation", 10)
    content.add_child(actions)
    pause_button = Button.new()
    pause_button.text = "Pausar"
    pause_button.custom_minimum_size = Vector2(130, 35)
    pause_button.pressed.connect(_toggle_pause)
    actions.add_child(pause_button)
    var reset_button := Button.new()
    reset_button.text = "Recomeçar"
    reset_button.custom_minimum_size = Vector2(140, 35)
    reset_button.pressed.connect(restart_run)
    actions.add_child(reset_button)
    var second_actions := HBoxContainer.new()
    content.add_child(second_actions)
    var back_button := Button.new()
    back_button.text = "Voltar à hub"
    back_button.custom_minimum_size = Vector2(140, 35)
    back_button.pressed.connect(_request_exit)
    second_actions.add_child(back_button)
    retry_button = Button.new()
    retry_button.text = "Tentar salvar"
    retry_button.custom_minimum_size = Vector2(140, 35)
    retry_button.pressed.connect(_retry_credits)
    second_actions.add_child(retry_button)
    exit_dialog = ConfirmationDialog.new()
    exit_dialog.title = "Sair da partida"
    exit_dialog.dialog_text = "Voltar à hub? Moedas confirmadas já foram salvas; XP e cartas são temporários."
    exit_dialog.confirmed.connect(_return_hub)
    exit_dialog.canceled.connect(_cancel_exit)
    add_child(exit_dialog)

    var dim := ColorRect.new()
    dim.name = "ResultDim"
    dim.color = Color(0.08, 0.14, 0.16, 0.55)
    dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    dim.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.add_child(dim)
    var center := CenterContainer.new()
    center.name = "WaveSummaryCenter"
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    center.mouse_filter = Control.MOUSE_FILTER_IGNORE
    overlay.add_child(center)
    summary_panel = PanelContainer.new()
    summary_panel.custom_minimum_size = Vector2(390, 210)
    summary_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    center.add_child(summary_panel)
    var text_box := VBoxContainer.new()
    text_box.add_theme_constant_override("separation", 15)
    summary_panel.add_child(text_box)
    summary_title = _add_label(text_box, "", 25)
    summary_body = _add_label(text_box, "", 18)
    summary_body.autowrap_mode = TextServer.AUTOWRAP_WORD
    summary_button = Button.new()
    summary_button.custom_minimum_size = Vector2(220, 44)
    summary_button.pressed.connect(_continue_from_summary)
    text_box.add_child(summary_button)

    dim.visible = false
    center.visible = false
    dim.set_meta("result_center", center)
    summary_panel.set_meta("dimmer", dim)
    _build_card_overlay(overlay)
    hand = HandCursor.new()
    hand.name = "HandCursor2D"
    overlay.add_child(hand)

func _build_card_overlay(overlay: CanvasLayer) -> void:
    card_overlay = ColorRect.new()
    card_overlay.name = "CardOfferDim"
    card_overlay.color = Color(0.07, 0.11, 0.19, 0.78)
    card_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    card_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.add_child(card_overlay)
    card_center = CenterContainer.new()
    card_center.name = "CardOfferCenter"
    card_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    card_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
    overlay.add_child(card_center)
    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(560.0, 280.0)
    card_center.add_child(panel)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 10)
    panel.add_child(box)
    card_header = _add_label(box, "ESCOLHA UMA HABILIDADE", 24)
    _add_label(box, "Uma carta por nível · apenas nesta partida", 16)
    for i in range(3):
        var button := Button.new()
        button.custom_minimum_size = Vector2(500.0, 60.0)
        button.pressed.connect(_choose_card.bind(i))
        button.name = "CardChoice_%d" % i
        box.add_child(button)
        card_buttons.append(button)
    card_overlay.visible = false
    card_center.visible = false

func _show_cards() -> void:
    if director.is_finished() or build.pending <= 0:
        return
    var ids: Array[String] = build.roll_offer()
    if ids.is_empty():
        return
    offers_open = true
    card_header.text = "NÍVEL %d  ·  ESCOLHA UMA HABILIDADE" % build.xp_level
    for i in range(card_buttons.size()):
        var button := card_buttons[i]
        button.visible = i < ids.size()
        if i < ids.size():
            var card: Dictionary = build.card_data(ids[i])
            button.text = "%s (Nv %d → %d)  |  %s  |  %s" % [
                String(card["name"]), build.rank(ids[i]), build.rank(ids[i]) + 1,
                String(card["value"]), String(card["description"])
            ]
    card_overlay.visible = true
    card_center.visible = true
    if is_instance_valid(hand):
        hand.visible = false
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _choose_card(index: int) -> void:
    if not offers_open or index < 0 or index >= build.current_offer.size():
        return
    if not build.select_card(build.current_offer[index]):
        return
    card_overlay.visible = false
    card_center.visible = false
    offers_open = false
    if build.pending > 0:
        _show_cards()
    elif advance_after_offers:
        advance_after_offers = false
        _start_next_wave()
    _update_hud()

func _request_exit() -> void:
    if action_locked:
        return
    if not pending_credits.is_empty():
        paused = true
        message_label.text = "Existem moedas não salvas. Tente salvar antes de sair."
        _update_hud()
        return
    paused_before_exit = paused
    paused = true
    exit_dialog.popup_centered()
    _update_hud()

var paused_before_exit := false

func _cancel_exit() -> void:
    paused = paused_before_exit
    _update_hud()

func _return_hub() -> void:
    if not pending_credits.is_empty():
        message_label.text = "Existem pagamentos pendentes. Use Tentar salvar."
        return
    progress.update_record(director.wave_index + 1, director.wallet.solved, best_combo_in_run)
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    get_tree().change_scene_to_file("res://scenes/c4/hub_stage.tscn")

func _retry_credits() -> void:
    if pending_credits.is_empty():
        return
    for id in pending_credits.keys():
        if progress.credit_cube(int(id), int(pending_credits[id])):
            pending_credits.erase(id)
        else:
            break
    if pending_credits.is_empty():
        paused = false
        message_label.text = "Moedas recuperadas e salvas no saldo permanente!"
        if director.ready_to_finish():
            _finish_wave()
    else:
        paused = true
        message_label.text = "Falha de gravação: verifique espaço/permissões e tente novamente."
    _update_hud()

func _set_summary_visible(show: bool) -> void:
    summary_panel.get_meta("dimmer").visible = show
    summary_panel.get_parent().visible = show
    if show:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        hand.visible = false

func _clear_actors() -> void:
    for id in actors.keys():
        var data: Dictionary = actors[id]
        var root: Node3D = data["root"]
        if is_instance_valid(root):
            root.queue_free()
    actors.clear()
    focused_id = -1

func restart_run() -> void:
    if action_locked or not pending_credits.is_empty():
        return
    save_ready = progress.begin_run()
    _clear_actors()
    build.reset(2026)
    director.stability_cap = progress.stability_max()
    director.start_run()
    best_combo_in_run = 0
    offers_open = false
    advance_after_offers = false
    card_overlay.visible = false
    card_center.visible = false
    combo_streak = 0
    last_solve_time = -999.0
    spawn_attempt = 0
    animation_clock = 0.0
    action_cooldown = 0.0
    paused = not save_ready
    message_label.text = "Aprendizes 10 · Reforçados 18 · Elite 80 moedas." if save_ready else (
        "Salvamento indisponível: não é seguro começar a partida.")
    _set_summary_visible(false)
    _spawn_one_if_possible()
    _update_hud()

func _pick_spawn() -> Variant:
    if camera == null:
        return null
    var screen := get_viewport().get_visible_rect()
    var inset := screen.grow(-40)
    for offset in range(SPAWN_POINTS.size()):
        var i := (spawn_attempt + offset) % SPAWN_POINTS.size()
        var point: Vector2 = SPAWN_POINTS[i]
        var world := Vector3(point.x, 0.65, point.y)
        var projection := camera.unproject_position(world)
        if camera.is_position_behind(world) or not inset.has_point(projection):
            continue
        if projection.x < 365.0 and projection.y < 325.0:
            continue
        var clear := true
        for id in actors:
            var existing: Dictionary = actors[id]
            var root: Node3D = existing["root"]
            if Vector2(root.position.x, root.position.z).distance_to(point) < 1.65:
                clear = false
                break
        if not clear:
            continue
        spawn_attempt = i + 1
        return point
    return null

func _spawn_one_if_possible() -> void:
    if director == null or not director.can_spawn():
        return
    var proposed: Variant = _pick_spawn()
    if not (proposed is Vector2):
        return
    var p: Vector2 = proposed
    var ticket: Dictionary = director.spawn_next()
    if ticket.is_empty():
        return
    var id: int = int(ticket["id"])
    var kind: String = String(ticket["kind"])
    var root := Node3D.new()
    root.name = "CubeActor_%d_%s" % [id, kind]
    root.position = Vector3(p.x, 0.0, p.y)
    add_child(root)
    var cube: CubeBase = BossVisual.new() if kind == "elite" else CubeVisual.new()
    cube.name = "Cube2x2"
    var scale_size := 1.49 if kind == "elite" else (1.78 if kind == "reinforced" else 1.65)
    cube.scale = Vector3.ONE * scale_size
    cube.position.y = (cube.CELL + cube.STEP * (2.0 if kind == "elite" else 1.0)) * scale_size * 0.5
    root.add_child(cube)
    # Two distinct challenges, no HP: 2-4 legal inverses vs 5-8.
    var depth := (6 + id % 7) if kind == "elite" else ((5 + id % 4) if kind == "reinforced" else (2 + id % 3))
    if kind == "reinforced":
        depth = maxi(2, depth - build.reinforced_reduction())
    cube.scramble_now(depth, 1000 + id * 73 + director.wave_index * 109)
    # Avoid a trivially solved cube yielding free money.
    var attempts := 0
    while cube.is_solved() and attempts < 10:
        cube.scramble_now(depth + 1, 9000 + id * 97 + attempts)
        attempts += 1
    if kind == "reinforced":
        var dark := StandardMaterial3D.new()
        dark.albedo_color = Color("#404168")
        dark.roughness = 0.44
        for body in cube.body_nodes:
            body.material_override = dark
    var ring := MeshInstance3D.new()
    ring.name = "TargetRing"
    var mesh := TorusMesh.new()
    mesh.inner_radius = 0.92 if kind == "elite" else 0.68
    mesh.outer_radius = 1.02 if kind == "elite" else 0.76
    ring.mesh = mesh
    var material := StandardMaterial3D.new()
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.albedo_color = Color("#e8b5ff") if kind == "elite" else (Color("#f4d36f") if kind == "reinforced" else Color("#e9fff0"))
    ring.material_override = material
    ring.position = Vector3(0, 0.055, 0)
    ring.visible = false
    root.add_child(ring)
    actors[id] = {
        "root": root, "cube": cube, "ring": ring,
        "kind": kind, "home": Vector2(p.x, p.y), "awarded": false
    }
    _update_hud()

func _remove_actor(id: int) -> void:
    if not actors.has(id):
        return
    var root: Node3D = actors[id]["root"]
    actors.erase(id)
    if is_instance_valid(root):
        root.queue_free()
    if focused_id == id:
        focused_id = -1

func _cursor_ground_point() -> Variant:
    if camera == null:
        return null
    var mouse := get_viewport().get_mouse_position()
    var origin := camera.project_ray_origin(mouse)
    var direction := camera.project_ray_normal(mouse)
    if absf(direction.y) < 0.00001:
        return null
    var dist := -origin.y / direction.y
    if dist < 0.0:
        return null
    return origin + direction * dist

func _pointer_on_ui() -> bool:
    return get_viewport().gui_get_hovered_control() != null

func _find_target(point: Vector3) -> int:
    var best_id := -1
    var min_distance := build.reach(TARGET_RADIUS)
    for id in actors:
        var item: Dictionary = actors[id]
        var cubie: CubeBase = item["cube"]
        if cubie.movement_busy or cubie.is_solved() or bool(item["awarded"]):
            continue
        var actor_root: Node3D = item["root"]
        var distance := Vector2(point.x, point.z).distance_to(
            Vector2(actor_root.position.x, actor_root.position.z)
        )
        if distance < min_distance:
            min_distance = distance
            best_id = int(id)
    return best_id

func _process(delta: float) -> void:
    if director == null:
        return
    if not save_ready:
        _update_hud()
        return
    action_cooldown = maxf(0.0, action_cooldown - delta)
    var mouse := get_viewport().get_mouse_position()
    var inside := get_viewport().get_visible_rect().has_point(mouse)
    var on_ui := _pointer_on_ui()
    var playing := director.phase == WaveRules.Phase.RUNNING and not paused and not offers_open
    if playing:
        animation_clock += delta
        if combo_streak > 0 and animation_clock - last_solve_time > 12.0:
            combo_streak = 0
            _update_hud()
    if is_instance_valid(hand):
        hand.follow_pointer(mouse)
        hand.visible = inside and not on_ui and playing
    var desired_cursor := Input.MOUSE_MODE_HIDDEN if inside and not on_ui and playing else Input.MOUSE_MODE_VISIBLE
    if Input.mouse_mode != desired_cursor:
        Input.set_mouse_mode(desired_cursor)

    for id in actors:
        var item: Dictionary = actors[id]
        var root: Node3D = item["root"]
        if playing and item["kind"] == "reinforced":
            var home: Vector2 = item["home"]
            root.position.x = home.x + sin(animation_clock * 0.8 + float(id)) * 0.10
            root.position.z = home.y + cos(animation_clock * 0.6 + float(id)) * 0.10

    var next_target := -1
    var ground: Variant = _cursor_ground_point()
    if playing and inside and not on_ui and ground is Vector3 and not action_locked:
        next_target = _find_target(ground)
    if focused_id != next_target:
        focused_id = next_target
        _update_hud()
    for id in actors:
        var ring: MeshInstance3D = actors[id]["ring"]
        ring.visible = playing and int(id) == focused_id
    if is_instance_valid(hand):
        hand.set_targeting(focused_id >= 0)

    if not playing:
        return
    director.tick(delta)
    _spawn_one_if_possible()
    if focused_id >= 0 and action_cooldown <= 0.0 and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        solve_actor_move(focused_id)
    if not action_locked and director.ready_to_finish():
        _finish_wave()
    _update_hud()

## Direct C2 integration-test entry point. The actual mouse path calls this only
## after a valid cursor hover; the function itself guarantees one actor/action.
func solve_actor_move(id: int) -> void:
    if director == null or director.phase != WaveRules.Phase.RUNNING or paused or offers_open or action_locked:
        return
    if not actors.has(id) or director.time_left <= 0.0:
        return
    var item: Dictionary = actors[id]
    var cube: CubeBase = item["cube"]
    if cube.movement_busy or cube.is_solved() or bool(item["awarded"]):
        return
    action_locked = true
    action_cooldown = maxf(0.16,
        ACTION_INTERVAL * (1.0 - 0.08 * build.rank("pulso_agil") - progress.cooldown_reduction()))
    var grant_extra_move := build.record_action_bonus_move()
    if is_instance_valid(hand):
        hand.celebrate_gesture()
    await cube.solve_next_move(ROTATION_DURATION)
    if not is_inside_tree() or not actors.has(id):
        action_locked = false
        return
    if grant_extra_move and not cube.is_solved() and cube.moves_remaining() > 0:
        await cube.solve_next_move(ROTATION_DURATION)
    if not is_inside_tree() or not actors.has(id):
        action_locked = false
        return
    if cube.is_solved() and not bool(item["awarded"]):
        combo_streak = combo_streak + 1 if animation_clock - last_solve_time <= 12.0 else 1
        last_solve_time = animation_clock
        best_combo_in_run = maxi(best_combo_in_run, combo_streak)
        director.money_modifier = minf(1.5, build.money_bonus(combo_streak) + progress.coin_bonus())
        var reward: Dictionary = director.resolve_cube(id)
        if not reward.is_empty():
            item["awarded"] = true
            build.register_xp(director.wallet.xp)
            var saved: bool = progress.credit_cube(id, int(reward["coins"]))
            if saved:
                message_label.text = "%s resolvido! +%d moedas salvas · +%d XP" % [
                    "Elite 3x3" if item["kind"] == "elite" else (
                        "Reforçado" if item["kind"] == "reinforced" else "Aprendiz"),
                    int(reward["coins"]), int(reward["xp"])
                ]
            else:
                pending_credits[id] = int(reward["coins"])
                paused = true
                message_label.text = "Falha ao salvar +%d moedas. Use 'Tentar salvar'." % int(reward["coins"])
            _remove_actor(id)
    action_locked = false
    if pending_credits.is_empty() and director.ready_to_finish():
        _finish_wave()
    elif pending_credits.is_empty() and build.pending > 0:
        _show_cards()
    _update_hud()

func _finish_wave() -> void:
    if action_locked or director == null or not pending_credits.is_empty():
        return
    var summary: Dictionary = director.finish_wave()
    if summary.is_empty():
        return
    if not progress.update_record(director.wave_index + 1, director.wallet.solved,
            best_combo_in_run):
        message_label.text = "Aviso: não foi possível salvar um recorde."
    _clear_actors()
    paused = false
    combo_streak = 0
    if director.is_finished():
        build.discard_pending()
    summary_title.text = "DERROTA" if director.phase == WaveRules.Phase.DEFEAT else (
        "VITÓRIA! 5 ONDAS!" if director.phase == WaveRules.Phase.VICTORY else "ONDA CONCLUÍDA"
    )
    summary_body.text = (
        "Onda %d/%d  |  Resolvidos %d/%d\n" +
        "Cubos não resolvidos: %d  ·  Não exibidos: %d\n" +
        "Estabilidade: %d  (-%d)\n" +
        "Moedas: %d  ·  XP: %d  ·  Cartas: %d"
    ) % [
        summary["wave"], director.waves.size(), summary["resolved"],
        summary["spawned"], summary["unresolved"], summary["unseen"],
        summary["stability"], summary["penalty"], summary["coins"], summary["xp"], build.offers_taken
    ]
    summary_button.text = "Próxima onda" if director.phase == WaveRules.Phase.BETWEEN else "Voltar à hub"
    _set_summary_visible(true)
    _update_hud()

func _start_next_wave() -> void:
    if not director.begin_next_wave():
        return
    message_label.text = "Nova onda! Cubos mais desafiadores surgiram."
    focused_id = -1
    action_cooldown = 0.0
    _spawn_one_if_possible()
    _update_hud()

func _continue_from_summary() -> void:
    if director.phase == WaveRules.Phase.BETWEEN:
        _set_summary_visible(false)
        if build.pending > 0:
            advance_after_offers = true
            _show_cards()
        else:
            _start_next_wave()
    elif director.is_finished():
        _return_hub()

func _toggle_pause() -> void:
    if director == null or director.phase != WaveRules.Phase.RUNNING or offers_open or action_locked:
        return
    paused = not paused
    pause_button.text = "Continuar" if paused else "Pausar"
    message_label.text = "PAUSADO — o relógio parou." if paused else "Jogo retomado!"
    _update_hud()

func _update_hud() -> void:
    if director == null or wave_label == null:
        return
    wave_label.text = "Onda %d/%d  ·  Campo aberto" % [
        maxi(1, director.wave_index + 1), director.waves.size()
    ]
    time_label.text = "Tempo: %02d s%s" % [ceili(director.time_left), "  ·  PAUSA" if paused else ""]
    stability_label.text = "Estabilidade: %d / %d" % [director.stability, director.stability_cap]
    stats_label.text = "Cubos %d/%d · Moedas %d · XP %d (Nv %d)" % [
        director.wave_resolved, director.total_expected(),
        director.wallet.coins, director.wallet.xp, build.xp_level
    ]
    if bank_label != null:
        bank_label.text = "Carteira permanente: %d moedas" % progress.balance()
    if retry_button != null:
        retry_button.disabled = pending_credits.is_empty()
    if focused_id >= 0 and actors.has(focused_id):
        var item: Dictionary = actors[focused_id]
        var cube: CubeBase = item["cube"]
        target_label.text = "Alvo: %s  ·  %d giros" % [
            "Elite 3x3" if item["kind"] == "elite" else ("Reforçado" if item["kind"] == "reinforced" else "Aprendiz"),
            cube.moves_remaining()
        ]
    else:
        target_label.text = "Combo x%d · %s" % [combo_streak, build.active_description()]
    if pause_button != null:
        pause_button.text = "Continuar" if paused else "Pausar"

func _exit_tree() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
