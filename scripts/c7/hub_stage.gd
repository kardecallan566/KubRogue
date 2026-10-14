extends Control
class_name KubRogueC7Hub
const ChallengeScript = preload("res://scripts/c6/challenge_service.gd")
const VisualTheme = preload("res://scripts/c5/ui_skin.gd")
## Explicit script dependency so 'godot .' works with a fresh .godot/ cache.
## The autoload is still registered as /root/KubeSession in project.godot.
const ProgressScript = preload("res://scripts/c4/progress_service.gd")
## C5 UI: palette and scroll have no dependency on imported textures or fonts.
## Sound is provided by the KubeAudio autoload and obeys persisted settings.
## Original KubRogue hub with a light geometric garden theme.
## All purchases are delegated to KubeSession; the UI never changes balances.
var session: ProgressScript
var challenge: ChallengeScript
var daily_label: Label
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
    challenge = get_node("/root/KubeChallenge") as ChallengeScript
    _build_ui()
    session.progress_changed.connect(_refresh)
    challenge.records_changed.connect(_refresh)
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
    btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    var lower := title.to_lower()
    if lower.contains("jogar") or lower.contains("começar"):
        btn.set_meta("arcade_variant", "gold")
    elif lower.contains("loja") or lower.contains("comprar"):
        btn.set_meta("arcade_variant", "teal")
    elif lower.contains("config") or lower.contains("como jogar"):
        btn.set_meta("arcade_variant", "blue")
    elif lower.contains("sair") or lower.contains("voltar"):
        btn.set_meta("arcade_variant", "red")
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
    panel.custom_minimum_size = Vector2(460, 0)
    centering.add_child(panel)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 11)
    panel.add_child(column)
    var logo := _label(column, "KUBROGUE", 34)
    logo.name = "HeroTitle"
    logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var subtitle := _label(column, "JARDIM DOS CUBOS  ·  ROGUELITE", 13)
    subtitle.name = "Muted"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    wallet_label = _label(column, "", 26)
    wallet_label.name = "Counter"
    wallet_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    records_label = _label(column, "", 14)
    records_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    daily_label = _label(column, "", 12)
    daily_label.name = "Muted"
    daily_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var gap := HSeparator.new()
    gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
    column.add_child(gap)
    feedback_label = _label(column, "✦ NOVOS CUBOS: DOURADO E BLINDADO ✦", 13)
    feedback_label.name = "Muted"
    feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var main_actions := VBoxContainer.new()
    main_actions.name = "PrimaryActions"
    main_actions.add_theme_constant_override("separation", 8)
    column.add_child(main_actions)
    _button(main_actions, "JOGAR  ·  MODO NORMAL", _play, 332)
    var daily_button := _button(main_actions, "DESAFIO DO DIA", _start_daily, 332)
    daily_button.set_meta("arcade_variant", "blue")
    _button(main_actions, "LOJA DE MELHORIAS", _show_shop, 332)

    var secondary := HBoxContainer.new()
    secondary.name = "SecondaryActions"
    secondary.add_theme_constant_override("separation", 8)
    secondary.alignment = BoxContainer.ALIGNMENT_CENTER
    column.add_child(secondary)
    var how_button := _button(secondary, "COMO JOGAR", func(): _show_tutorial(false), 162)
    how_button.set_meta("compact", true)
    var settings_button := _button(secondary, "CONFIGURAÇÕES", _show_settings, 162)
    settings_button.set_meta("compact", true)
    var exit_button := _button(column, "SAIR", func(): get_tree().quit(), 154)
    exit_button.set_meta("compact", true)

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
    scroll.custom_minimum_size = Vector2(570, 460)
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
    wallet_label.text = "%d MOEDAS" % session.balance()
    var rec: Dictionary = session.data["records"]
    records_label.text = "Onda %d/5    ·    Cubos %d    ·    Combo %d" % [
        rec["best_wave"], rec["best_solved"], rec["best_combo"]
    ]
    var date_text := challenge.utc_day()
    var record: Dictionary = challenge.record_for(date_text)
    daily_label.text = "DESAFIO %s  ·  MELHOR ONDA %d/5  ·  %d TENTATIVAS" % [
        date_text, int(record["best_wave"]), int(record["attempts"])
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
    challenge.select_mode("normal")
    if not bool(session.data.get("tutorial_completed", false)):
        _show_tutorial(true)
        return
    _open_game()

func _start_daily() -> void:
    if not challenge.select_mode("daily"):
        feedback_label.text = "Não foi possível identificar o dia atual."
        return
    if not bool(session.data.get("tutorial_completed", false)):
        _show_tutorial(true)
        return
    _open_game()

func _open_game() -> void:
    _close_modal()
    get_tree().change_scene_to_file("res://scenes/c7/game_stage.tscn")

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
    _label(dialog_box, "MELHORIAS PERMANENTES", 25)
    _label(dialog_box, "Saldo disponível: %d moedas" % session.balance(), 17)
    for id in ["hand_training", "cubist_pocket", "stable_field"]:
        var level: int = session.meta_level(id)
        var cost: int = session.next_cost(id)
        var shop_card := PanelContainer.new()
        shop_card.name = "ShopPerk_%s" % id
        shop_card.set_meta("skill_category", "Moedas" if id == "cubist_pocket" else "Velocidade")
        dialog_box.add_child(shop_card)
        var perk_content := VBoxContainer.new()
        perk_content.add_theme_constant_override("separation", 5)
        shop_card.add_child(perk_content)
        var header := HBoxContainer.new()
        perk_content.add_child(header)
        var perk_title := _label(header, session.UPGRADE_NAMES[id], 19)
        perk_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _label(header, "NV %d/3" % level, 14)
        _label(perk_content, session.UPGRADE_DESCRIPTIONS[id], 14)
        var buy := _button(perk_content,
            "NÍVEL MÁXIMO" if cost < 0 else "MELHORAR  ·  %d MOEDAS" % cost,
            _buy_upgrade.bind(id), 340)
        buy.disabled = cost < 0 or session.balance() < cost
    if not session.last_error.is_empty():
        _label(dialog_box, session.last_error, 15)
    _button(dialog_box, "VOLTAR", _close_modal, 300)
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
