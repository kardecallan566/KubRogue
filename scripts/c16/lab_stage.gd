extends Node3D
## C16: an actual no-stakes NxNxN playground. Never starts a run or writes saves.
const Pocket = preload("res://scripts/visual/cube_2x2.gd")
const Classic = preload("res://scripts/visual/cube_3x3.gd")
const Large = preload("res://scripts/visual/cube_nxn.gd")
const VisualTheme = preload("res://scripts/c5/ui_skin.gd")
const FACES := ["F","R","U","L","D","B"]

var cube
var dimension := 2
var selected_face := "F"
var selected_layer := 0
var seed_value := 0
var manual_moves := 0
var assisted_moves := 0
var busy := false
var cube_root: Node3D
var status_label: Label
var details_label: Label
var move_label: Label
var hint_label: Label
var layer_label: Label
var size_buttons: Dictionary = {}
var face_buttons: Dictionary = {}
var turn_buttons: Array[Button] = []
var hint_button: Button
var apply_button: Button
var layer_back: Button
var layer_next: Button
var right_panel: PanelContainer
var top_label: Label
var _ready_done := false

func _ready() -> void:
    _build_world()
    _build_interface()
    _select_size(2)
    get_viewport().size_changed.connect(_layout)
    _layout()
    _ready_done = true

func _build_world() -> void:
    var ground := MeshInstance3D.new()
    ground.name = "TrainingMeadow"
    var plane := PlaneMesh.new()
    plane.size = Vector2(36,36)
    ground.mesh = plane
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color("#77b985")
    mat.roughness = 0.97
    ground.material_override = mat
    ground.position.y = -0.34
    add_child(ground)
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-53,-29,0)
    light.light_energy = 1.25
    add_child(light)
    var fill := OmniLight3D.new()
    fill.position = Vector3(-3.5,4.0,2.5)
    fill.light_energy = 0.65
    fill.omni_range = 10.0
    add_child(fill)
    var camera := Camera3D.new()
    camera.name = "LaboratoryCamera"
    camera.current = true
    camera.fov = 40.0
    # _ready creates the camera before its first in-tree update; this
    # variant does not require the Node3D to have an active World3D.
    camera.look_at_from_position(Vector3(3.1,2.65,4.8),
        Vector3(0,0.35,0),Vector3.UP)
    add_child(camera)
    cube_root = Node3D.new()
    cube_root.name = "PracticeCubePivot"
    cube_root.position.y = 0.64
    add_child(cube_root)

func _label(parent: Node, content: String, font: int = 15) -> Label:
    var result := Label.new()
    result.text = content
    result.add_theme_font_size_override("font_size",font)
    result.add_theme_color_override("font_color",Color("#244b42"))
    result.autowrap_mode = TextServer.AUTOWRAP_WORD
    result.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(result)
    return result

func _button(parent: Node, title: String, callback: Callable,
        height_px: float = 40.0) -> Button:
    var result := Button.new()
    result.text = title
    result.custom_minimum_size.y = height_px
    result.focus_mode = Control.FOCUS_ALL
    result.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    result.pressed.connect(callback)
    parent.add_child(result)
    return result

func _panel_style(color: Color = Color("#fffdf0")) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = color
    style.border_color = Color("#4c9c83")
    style.set_border_width_all(3)
    style.set_corner_radius_all(18)
    style.set_content_margin_all(13)
    style.shadow_color = Color(0.07,0.19,0.13,0.23)
    style.shadow_size = 5
    style.shadow_offset = Vector2(0,4)
    return style

func _panel(parent: Node, title: String) -> VBoxContainer:
    var frame := PanelContainer.new()
    frame.name = title.replace(" ","") + "Panel"
    frame.size = Vector2(278,565)
    frame.custom_minimum_size = Vector2(278,565)
    frame.add_theme_stylebox_override("panel",_panel_style())
    parent.add_child(frame)
    var inner := VBoxContainer.new()
    inner.add_theme_constant_override("separation",10)
    frame.add_child(inner)
    return inner

func _build_interface() -> void:
    var canvas := CanvasLayer.new()
    canvas.name = "LaboratoryUI"
    add_child(canvas)
    var root := Control.new()
    root.name = "LabRoot"
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    canvas.add_child(root)
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var header := PanelContainer.new()
    header.name = "Header"
    header.position = Vector2(19,14)
    header.custom_minimum_size = Vector2(890,56)
    header.size = Vector2(890,56)
    header.add_theme_stylebox_override("panel",_panel_style(Color("#f1f9e9")))
    root.add_child(header)
    var head_row := HBoxContainer.new()
    head_row.add_theme_constant_override("separation",13)
    header.add_child(head_row)
    top_label = _label(head_row,"◈  LABORATÓRIO DO CUBISTA",23)
    top_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _button(head_row,"VOLTAR AO JARDIM",_back_to_hub,38)

    var left_wrap := Control.new()
    left_wrap.name = "LeftPanelPosition"
    left_wrap.position = Vector2(19,89)
    left_wrap.custom_minimum_size = Vector2(284,575)
    root.add_child(left_wrap)
    var left := _panel(left_wrap,"Controles")
    _label(left,"QUAL CUBO TREINAR?",17)
    var sizes := GridContainer.new()
    sizes.name = "CubeSizes"
    sizes.columns = 2
    sizes.add_theme_constant_override("h_separation",8)
    sizes.add_theme_constant_override("v_separation",7)
    left.add_child(sizes)
    for n in [2,3,4,5]:
        var current: int = n
        var select := _button(sizes,"%d×%d×%d" % [n,n,n],
            func(): _select_size(current),42)
        select.custom_minimum_size.x = 112
        select.name = "CubeSize%d" % n
        size_buttons[n] = select
    _label(left,"FACE A GIRAR",17)
    var faces := GridContainer.new()
    faces.name = "CubeFaces"
    faces.columns = 3
    faces.add_theme_constant_override("h_separation",7)
    faces.add_theme_constant_override("v_separation",7)
    left.add_child(faces)
    for face in FACES:
        var face_id: String = face
        var btn := Button.new()
        btn.text = face
        btn.custom_minimum_size.y = 36
        faces.add_child(btn)
        btn.custom_minimum_size.x = 64
        btn.pressed.connect(func(): _select_face(face_id))
        btn.name = "Face"+face
        face_buttons[face] = btn
    _label(left,"CAMADA A MOVIMENTAR",16)
    var layers := HBoxContainer.new()
    layers.add_theme_constant_override("separation",6)
    left.add_child(layers)
    layer_back = _button(layers,"◀",func(): _change_layer(-1),37)
    layer_back.custom_minimum_size.x = 41
    layer_label = _label(layers,"EXTERNA",13)
    layer_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    layer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    layer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    layer_next = _button(layers,"▶",func(): _change_layer(1),37)
    layer_next.custom_minimum_size.x = 41
    _label(left,"MOVIMENTO",16)
    var rotations := HBoxContainer.new()
    rotations.add_theme_constant_override("separation",6)
    left.add_child(rotations)
    for turn in [-1,1,2]:
        var actual_turn: int = turn
        var label := "↶ 90°" if turn == -1 else ("↷ 90°" if turn == 1 else "180°")
        var button := _button(rotations,label,func(): _do_turn(actual_turn),41)
        button.custom_minimum_size.x = 76
        turn_buttons.append(button)
    _button(left,"NOVO EMBARALHAMENTO",_new_scramble,41)
    _button(left,"REPETIR A MESMA SEED",_replay_scramble,40)

    right_panel = PanelContainer.new()
    right_panel.name = "HelpPanel"
    right_panel.position = Vector2(963,89)
    right_panel.custom_minimum_size = Vector2(290,430)
    right_panel.size = Vector2(290,430)
    right_panel.add_theme_stylebox_override("panel",_panel_style(Color("#eff9f5")))
    root.add_child(right_panel)
    var right := VBoxContainer.new()
    right.add_theme_constant_override("separation",12)
    right_panel.add_child(right)
    _label(right,"◈  MISSÃO LIVRE",19)
    _label(right,"Pratique giros reais. Sem tempo, sem moedas e sem afetar seus recordes.",13)
    details_label = _label(right,"",15)
    details_label.name = "TrainingDetails"
    status_label = _label(right,"",16)
    status_label.name = "TrainingStatus"
    move_label = _label(right,"",14)
    hint_label = _label(right,"",14)
    hint_label.name = "NextHint"
    hint_button = _button(right,"VER UMA DICA",_show_hint,40)
    apply_button = _button(right,"APLICAR DICA",_apply_hint,42)
    var detail := _label(right,
        "Uma dica mostra o próximo giro inverso do embaralhamento. " +
        "Você também pode girar livremente e tentar resolver sem ajuda.",12)
    detail.name = "Muted"
    VisualTheme.apply(root)
    # Preserve the same chunky toy-like panels independent of theme skinning.
    header.add_theme_stylebox_override("panel",_panel_style(Color("#f1f9e9")))
    right_panel.add_theme_stylebox_override("panel",_panel_style(Color("#eff9f5")))
    for panel in left_wrap.get_children():
        if panel is PanelContainer:
            panel.add_theme_stylebox_override("panel",_panel_style())

func _layout() -> void:
    if right_panel == null:
        return
    var viewport_size := get_viewport().get_visible_rect().size
    right_panel.position.x = maxf(776.0, viewport_size.x - 310.0)

func _select_size(n: int) -> void:
    if busy or n not in [2,3,4,5]:
        return
    dimension = n
    selected_layer = 0
    selected_face = "F"
    manual_moves = 0
    assisted_moves = 0
    if cube != null:
        cube_root.remove_child(cube)
        cube.queue_free()
    if dimension == 2:
        cube = Pocket.new()
    elif dimension == 3:
        cube = Classic.new()
    else:
        cube = Large.new(dimension)
    cube.name = "ActualCube_%d" % dimension
    cube_root.add_child(cube)
    var cube_scale := 1.92 if dimension == 2 else 1.82
    cube.scale = Vector3.ONE * cube_scale
    seed_value = randi_range(1,2147483646)
    _scramble_now()

func _new_scramble() -> void:
    if busy:
        return
    seed_value = randi_range(1,2147483646)
    _scramble_now()

func _replay_scramble() -> void:
    if busy:
        return
    _scramble_now()

func _scramble_now() -> void:
    if cube == null or busy:
        return
    cube.scramble_now(6 + dimension * 2,seed_value)
    manual_moves = 0
    assisted_moves = 0
    hint_label.text = "A dica é opcional; tente primeiro por conta própria."
    _refresh_ui()

func _select_face(face: String) -> void:
    if busy or not FACES.has(face):
        return
    selected_face = face
    _refresh_ui()

func max_layer() -> int:
    return (dimension - 1) / 2

func _change_layer(delta: int) -> void:
    if busy:
        return
    selected_layer = clampi(selected_layer + delta,0,max_layer())
    _refresh_ui()

func _hint_text() -> String:
    if cube == null or cube.solution_plan.is_empty():
        return "Cubo resolvido! Embaralhe novamente."
    var step: Dictionary = cube.solution_plan[0]
    var direction := "180°" if absi(int(step["turns"])) == 2 else (
        "↷ 90°" if int(step["turns"]) == 1 else "↶ 90°")
    var layer: int = int(step.get("layer",0))
    return "PRÓXIMO: %s  ·  CAMADA %d  ·  %s" % [
        String(step["face"]),layer,direction]

func _show_hint() -> void:
    if busy:
        return
    hint_label.text = _hint_text()

func _do_turn(turns: int) -> void:
    await _rotate(selected_face,turns,selected_layer,true)

func _apply_hint() -> void:
    if cube == null or busy or cube.solution_plan.is_empty():
        return
    var step: Dictionary = cube.solution_plan.pop_front()
    assisted_moves += 1
    await _rotate(String(step["face"]),int(step["turns"]),
        int(step.get("layer",0)),false)

func _rotate(face: String, turns: int, layer: int, record: bool) -> void:
    if cube == null or busy or not FACES.has(face) or turns == 0:
        return
    busy = true
    _refresh_ui()
    if dimension <= 3:
        await cube.rotate_layer(face,turns,0.20,record)
    else:
        await cube.rotate_slice(face,turns,layer,0.20,record)
    if record:
        manual_moves += 1
        cube.solution_plan = cube.puzzle.reversed_history()
    if cube.is_solved():
        cube.solution_plan.clear()
        hint_label.text = "✦ CUBO RESOLVIDO! Recompensa: conhecimento."
    else:
        hint_label.text = "Movimento executado. Clique em dica se precisar."
    busy = false
    _refresh_ui()

func _refresh_ui() -> void:
    if cube == null:
        return
    var solved: bool = cube.is_solved()
    var layers: int = max_layer()
    layer_label.text = "EXTERNA" if selected_layer == 0 else "INTERNA %d" % selected_layer
    layer_back.disabled = busy or selected_layer == 0
    layer_next.disabled = busy or selected_layer >= layers
    for n in size_buttons:
        size_buttons[n].disabled = busy
        size_buttons[n].set_meta("selected",n == dimension)
    for f in face_buttons:
        face_buttons[f].disabled = busy
        face_buttons[f].set_meta("selected",f == selected_face)
    for btn in turn_buttons:
        btn.disabled = busy or solved
    hint_button.disabled = busy or solved
    apply_button.disabled = busy or solved
    details_label.text = "%d×%d×%d  ·  %d ADESIVOS  ·  SEED %d" % [
        dimension,dimension,dimension,6 * dimension * dimension,seed_value]
    status_label.text = "✦ PARABÉNS! CUBO RESOLVIDO." if solved else (
        "GIROS RESTANTES NO ROTEIRO: %d" % cube.moves_remaining())
    move_label.text = "%d GIROS MANUAIS  ·  %d DICAS APLICADAS" % [
        manual_moves,assisted_moves]

func _back_to_hub() -> void:
    if busy:
        return
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    get_tree().change_scene_to_file("res://scenes/c16/hub_stage.tscn")
