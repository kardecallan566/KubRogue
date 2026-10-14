extends Control
class_name KubRogueC8Hub
const JournalScript = preload("res://scripts/c8/journal_service.gd")
const ChallengeScript = preload("res://scripts/c6/challenge_service.gd")
const VisualTheme = preload("res://scripts/c5/ui_skin.gd")
## Explicit script dependency so 'godot .' works with a fresh .godot/ cache.
## The autoload is still registered as /root/KubeSession in project.godot.
const ProgressScript = preload("res://scripts/c4/progress_service.gd")
## C5 UI: palette and scroll have no dependency on imported textures or fonts.
## Sound is provided by the KubeAudio autoload and obeys persisted settings.
## Original KubRogue hub with a light geometric garden theme.
## Legacy permanent upgrades are preserved in old saves; C8 no longer offers purchases.\n## Skill upgrades are selected while playing.
var session: ProgressScript
var challenge: ChallengeScript
var journal: JournalScript
var collection_label: Label
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
    journal = get_node("/root/KubeJournal") as JournalScript
    _build_ui()
    session.progress_changed.connect(_refresh)
    challenge.records_changed.connect(_refresh)
    journal.journal_changed.connect(_refresh)
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
    collection_label = _label(column, "", 13)
    collection_label.name = "Muted"
    collection_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var gap := HSeparator.new()
    gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
    column.add_child(gap)
    feedback_label = _label(column, "✦ DOURADO · BLINDADO · MESTRE 4×4 · TITÃ 5×5 ✦", 13)
    feedback_label.name = "Muted"
    feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var main_actions := VBoxContainer.new()
    main_actions.name = "PrimaryActions"
    main_actions.add_theme_constant_override("separation", 9)
    column.add_child(main_actions)
    _button(main_actions, "JOGAR", _show_play_modes, 332)
    var codex := _button(main_actions, "BESTIÁRIO", _show_bestiary, 332)
    codex.set_meta("arcade_variant", "teal")
    var config := _button(main_actions, "CONFIGURAÇÕES", _show_settings, 332)
    config.set_meta("arcade_variant", "blue")
    var exit := _button(main_actions, "SAIR", func(): get_tree().quit(), 332)
    exit.set_meta("arcade_variant", "red")
    exit.set_meta("compact", true)

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
    collection_label.text = "BESTIÁRIO %d / 7 TIPOS DESCOBERTOS" % journal.discovery_total()
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

func _show_play_modes() -> void:
    _clear_modal()
    var head := _label(dialog_box, "ESCOLHA SEU DESAFIO", 25)
    head.name = "Title"
    _label(dialog_box, "Uma partida, cinco ondas e novas habilidades a cada nível.", 15)
    _button(dialog_box, "MODO NORMAL", _play, 405)
    _label(dialog_box, "Novos embaralhamentos e uma build diferente a cada tentativa.", 14)
    var daily := _button(dialog_box, "DESAFIO DO DIA", _start_daily, 405)
    daily.set_meta("arcade_variant", "blue")
    _label(dialog_box, "Seed diária compartilhável e recordes pessoais.", 14)
    _button(dialog_box, "VOLTAR", _close_modal, 260)
    _open_modal()

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
    get_tree().change_scene_to_file("res://scenes/c8/game_stage.tscn")

func _show_tutorial(start_after: bool) -> void:
    _clear_modal()
    _label(dialog_box, "COMO JOGAR  ·  KUBROGUE", 27)
    _label(dialog_box, "1. Leve o cursor em forma de mão sobre um cubo colorido. Clique ou segure para girar camadas de verdade.", 18)
    _label(dialog_box, "2. Cubos resolvidos concedem moedas permanentes e XP da partida. Novos tipos exigem mais giros.", 18)
    _label(dialog_box, "3. A cada nível, escolha uma entre três habilidades. Resolva cinco ondas e a elite 3×3 antes do fim do tempo.", 18)
    _label(dialog_box, "4. Resolva cinco ondas antes que o tempo acabe. Evolua apenas durante a partida, escolhendo cartas de habilidade.", 18)
    _label(dialog_box, "5. Complete contratos por partida para ganhar moedas extras e descubra novas espécies no Bestiário.", 18)
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

func _show_bestiary() -> void:
    _clear_modal()
    var heading := _label(dialog_box, "BESTIÁRIO DO JARDIM", 25)
    heading.name = "Title"
    _label(dialog_box, "%d de 7 espécies descobertas · Histórico local" % journal.discovery_total(), 15)
    _label(dialog_box,
        "Resolva cubos durante as partidas para revelar novas espécies. "
        + "A coleção é permanente e não gasta moedas.", 14)
    for entry in journal.CATALOG:
        var kind: String = entry["id"]
        var count: int = journal.solved_count(kind)
        var item_panel := PanelContainer.new()
        item_panel.name = "Species_%s" % kind
        item_panel.set_meta("skill_category", "Controle" if count == 0 else (
            "Moedas" if String(entry["rarity"]) == "RARO" else "Velocidade"))
        dialog_box.add_child(item_panel)
        var block := VBoxContainer.new()
        block.add_theme_constant_override("separation", 4)
        item_panel.add_child(block)
        var header := HBoxContainer.new()
        block.add_child(header)
        var display_name := String(entry["name"]) if count > 0 else "??? · ESPÉCIE DESCONHECIDA"
        var name := _label(header, display_name, 17)
        name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _label(header, "DESCOBERTO" if count > 0 else "BLOQUEADO", 11)
        if count > 0:
            _label(block, "%s  ·  %d×%d×%d  ·  %d MOEDAS BASE" % [
                String(entry["rarity"]), int(entry["dimension"]),
                int(entry["dimension"]), int(entry["dimension"]), int(entry["coins"])
            ], 13)
            _label(block, String(entry["detail"]) + "  ·  Resolvidos: %d" % count, 13)
        else:
            _label(block, "Resolva esta espécie no Jardim para revelar seus detalhes.", 13)
    _label(dialog_box, "CONTRATOS DE CADA PARTIDA", 21)
    _label(dialog_box,
        "Complete estes objetivos durante uma partida. Os bônus são somados "
        + "ao pagamento do último cubo, sem cobrança e sem resgate manual.", 14)
    for goal in journal.CONTRACTS:
        var goal_panel := PanelContainer.new()
        goal_panel.name = "Contract_%s" % String(goal["id"])
        dialog_box.add_child(goal_panel)
        var body := VBoxContainer.new()
        goal_panel.add_child(body)
        _label(body, "%s  ·  +%d MOEDAS" % [
            String(goal["title"]), int(goal["reward"])
        ], 17)
        _label(body, String(goal["detail"]), 14)
    _button(dialog_box, "VOLTAR", _close_modal, 280)
    _open_modal()

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
    _button(dialog_box, "COMO JOGAR  ?", func(): _show_tutorial(false), 420)
    _button(dialog_box, "VOLTAR", _close_modal, 420)
    _open_modal()
