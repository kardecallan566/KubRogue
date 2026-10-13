extends Control
class_name KubRogueC5Hub
const VisualTheme = preload("res://scripts/c5/ui_skin.gd")
## Explicit script dependency so 'godot .' works with a fresh .godot/ cache.
## The autoload is still registered as /root/KubeSession in project.godot.
const ProgressScript = preload("res://scripts/c4/progress_service.gd")
## C5 UI: palette and scroll have no dependency on imported textures or fonts.
## Sound is provided by the KubeAudio autoload and obeys persisted settings.
## Original KubRogue hub with a light geometric garden theme.
## All purchases are delegated to KubeSession; the UI never changes balances.
var session: ProgressScript
var wallet_label: Label
var records_label: Label
var feedback_label: Label
var dialog_dim: ColorRect
var dialog_center: CenterContainer
var dialog_box: VBoxContainer

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    session = get_node("/root/KubeSession") as ProgressScript
    _build_ui()
    session.progress_changed.connect(_refresh)
    _refresh()

func _label(parent: Node, content: String, font_size: int = 18) -> Label:
    var lbl := Label.new()
    lbl.text = content
    lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
    lbl.add_theme_font_size_override("font_size", font_size)
    parent.add_child(lbl)
    return lbl

func _button(parent: Node, title: String, action: Callable, width: float = 320) -> Button:
    var btn := Button.new()
    btn.text = title
    btn.custom_minimum_size = Vector2(width, 46)
    btn.pressed.connect(func(): get_node("/root/KubeAudio").play_sfx("tap"))
    btn.pressed.connect(action)
    parent.add_child(btn)
    return btn

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.name = "PastelGreenGarden"
    bg.color = Color("#9ec88a")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(bg)

    # Decorative translucent patches, all outside gameplay.
    for i in range(13):
        var patch := ColorRect.new()
        patch.color = Color("#b7d79d") if i % 2 == 0 else Color("#88b77c")
        patch.color.a = 0.32
        patch.size = Vector2(30 + i * 11, 14 + i * 4)
        patch.position = Vector2(38 + (i * 173) % 1220, 40 + (i * 97) % 700)
        patch.rotation = 0.28 * float(i % 4)
        patch.mouse_filter = Control.MOUSE_FILTER_IGNORE
        bg.add_child(patch)

    var centering := CenterContainer.new()
    centering.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    centering.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(centering)
    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(550, 550)
    centering.add_child(panel)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 12)
    panel.add_child(column)
    _label(column, "K U B R O G U E", 34)
    _label(column, "JARDIM DOS CUBOS  ·  Resolva. Evolua. Recomece.", 16)
    wallet_label = _label(column, "", 25)
    records_label = _label(column, "", 17)
    feedback_label = _label(column, "Cinco ondas · mão 2D · cubos 3D · Música original", 16)
    _button(column, "JOGAR", _play)
    _button(column, "LOJA DE MELHORIAS", _show_shop)
    _button(column, "COMO JOGAR", func(): _show_tutorial(false))
    _button(column, "CONFIGURAÇÕES", _show_settings)
    _button(column, "SAIR DO JOGO", func(): get_tree().quit())

    dialog_dim = ColorRect.new()
    dialog_dim.name = "ModalBackdrop"
    dialog_dim.color = Color(0.05, 0.12, 0.17, 0.76)
    dialog_dim.mouse_filter = Control.MOUSE_FILTER_STOP
    dialog_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(dialog_dim)
    dialog_center = CenterContainer.new()
    dialog_center.name = "ModalCenter"
    dialog_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
    dialog_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(dialog_center)
    var modal_panel := PanelContainer.new()
    modal_panel.custom_minimum_size = Vector2(605, 0)
    dialog_center.add_child(modal_panel)
    var scroll := ScrollContainer.new()
    scroll.name = "DialogScroll"
    scroll.custom_minimum_size = Vector2(570, 500)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    modal_panel.add_child(scroll)
    dialog_box = VBoxContainer.new()
    dialog_box.custom_minimum_size = Vector2(530, 0)
    dialog_box.add_theme_constant_override("separation", 13)
    scroll.add_child(dialog_box)
    _close_modal()
    VisualTheme.apply(self)

func _refresh() -> void:
    if wallet_label == null:
        return
    wallet_label.text = "Saldo permanente: %d moedas" % session.balance()
    var rec: Dictionary = session.data["records"]
    records_label.text = "Melhor onda: %d/5   ·   Cubos: %d   ·   Combo: %d" % [
        rec["best_wave"], rec["best_solved"], rec["best_combo"]
    ]
    if not session.last_error.is_empty():
        feedback_label.text = session.last_error

func _clear_modal() -> void:
    for child in dialog_box.get_children():
        dialog_box.remove_child(child)
        child.queue_free()

func _open_modal() -> void:
    VisualTheme.apply(dialog_center)
    dialog_dim.visible = true
    dialog_center.visible = true

func _close_modal() -> void:
    dialog_dim.visible = false
    dialog_center.visible = false

func _play() -> void:
    if not bool(session.data.get("tutorial_completed", false)):
        _show_tutorial(true)
        return
    _open_game()

func _open_game() -> void:
    _close_modal()
    get_tree().change_scene_to_file("res://scenes/c5/game_stage.tscn")

func _show_tutorial(start_after: bool) -> void:
    _clear_modal()
    _label(dialog_box, "COMO JOGAR  ·  KUBROGUE", 27)
    _label(dialog_box, "1. Leve o cursor em forma de mão sobre um cubo colorido. Clique ou segure para girar camadas de verdade.", 18)
    _label(dialog_box, "2. Cubos resolvidos concedem moedas permanentes e XP da partida. Novos tipos exigem mais giros.", 18)
    _label(dialog_box, "3. A cada nível, escolha uma entre três habilidades. Resolva cinco ondas e a elite 3×3 antes do fim do tempo.", 18)
    _label(dialog_box, "4. Se cubos apresentados não forem resolvidos, a estabilidade diminui. Na hub, compre melhorias permanentes.", 18)
    if start_after:
        _button(dialog_box, "ENTENDI — COMEÇAR PARTIDA", _finish_tutorial_and_play, 420)
    else:
        _button(dialog_box, "VOLTAR AO MENU", _close_modal, 420)
    _open_modal()

func _finish_tutorial_and_play() -> void:
    if not session.finish_tutorial():
        feedback_label.text = session.last_error
        return
    _open_game()

func _show_shop() -> void:
    _clear_modal()
    _label(dialog_box, "LOJA DE MELHORIAS", 28)
    _label(dialog_box, "Saldo: %d moedas  ·  Todas as melhorias duram entre partidas." % session.balance(), 18)
    for id in ["hand_training", "cubist_pocket", "stable_field"]:
        var lvl: int = session.meta_level(id)
        var cost: int = session.next_cost(id)
        _label(dialog_box, "%s  ·  Nível %d/3" % [session.UPGRADE_NAMES[id], lvl], 20)
        _label(dialog_box, session.UPGRADE_DESCRIPTIONS[id], 15)
        var buy := _button(dialog_box, "MÁXIMO" if cost < 0 else "Comprar por %d moedas" % cost,
            _buy_upgrade.bind(id), 430)
        buy.disabled = cost < 0 or session.balance() < cost
    if not session.last_error.is_empty():
        _label(dialog_box, session.last_error, 15)
    _button(dialog_box, "VOLTAR", _close_modal, 430)
    _open_modal()

func _buy_upgrade(id: String) -> void:
    var ok: bool = session.purchase(id)
    feedback_label.text = "Melhoria adquirida: %s" % session.UPGRADE_NAMES[id] if ok else (
        session.last_error if not session.last_error.is_empty() else "Saldo insuficiente ou nível máximo.")
    _show_shop()

func _show_settings() -> void:
    _clear_modal()
    _label(dialog_box, "CONFIGURAÇÕES", 27)
    _label(dialog_box, "Áudio sintetizado original com volumes aplicados em tempo real. Partículas reduzidas e tremor opcional funcionam nas partidas.", 15)
    var opts: Dictionary = session.data["settings"]
    for id in ["music_volume", "effects_volume"]:
        _label(dialog_box, "Volume da música" if id == "music_volume" else "Volume dos efeitos", 18)
        var slider := HSlider.new()
        slider.custom_minimum_size = Vector2(440, 38)
        slider.min_value = 0.0
        slider.max_value = 1.0
        slider.step = 0.05
        slider.value = float(opts[id])
        slider.value_changed.connect(func(amount: float): session.set_setting(id, amount))
        dialog_box.add_child(slider)
    for id in ["reduced_particles", "screen_shake"]:
        var check := CheckBox.new()
        check.text = "Reduzir partículas" if id == "reduced_particles" else "Ativar tremor de câmera"
        check.button_pressed = bool(opts[id])
        check.toggled.connect(func(enabled: bool): session.set_setting(id, enabled))
        dialog_box.add_child(check)
    _button(dialog_box, "VOLTAR", _close_modal, 420)
    _open_modal()
