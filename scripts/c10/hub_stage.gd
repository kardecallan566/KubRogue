extends Control
class_name KubRogueC10Hub
const JournalScript = preload("res://scripts/c8/journal_service.gd")
const ChallengeScript = preload("res://scripts/c6/challenge_service.gd")
const VisualTheme = preload("res://scripts/c5/ui_skin.gd")
const CubePreview = preload("res://scripts/c8/species_preview.gd")
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
var modal_panel: PanelContainer
var modal_scroll: ScrollContainer
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
    feedback_label = _label(column, "✦ COMBO FEVER · OFICINA · ROTAS DO JARDIM ✦", 13)
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
    modal_panel = PanelContainer.new()
    modal_panel.custom_minimum_size = Vector2(605, 0)
    dialog_center.add_child(modal_panel)
    modal_scroll = ScrollContainer.new()
    var scroll := modal_scroll
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

func _set_modal_dimensions(panel_width: float, scroll_height: float) -> void:
    modal_panel.custom_minimum_size = Vector2(panel_width,0)
    modal_scroll.custom_minimum_size = Vector2(panel_width - 36.0,scroll_height)
    dialog_box.custom_minimum_size = Vector2(panel_width - 70.0,0)

func _mode_card(parent: Node, icon: String, title: String,
        subtitle: String, detail: String, action: Callable, color: String) -> void:
    var card := PanelContainer.new()
    card.name = "Mode_%s" % ("Daily" if title.contains("DIA") else "Normal")
    card.custom_minimum_size = Vector2(310,210)
    card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    card.set_meta("skill_category","Controle" if title.contains("DIA") else "Moedas")
    parent.add_child(card)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation",9)
    card.add_child(column)
    var mark := _label(column,icon,36)
    mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var head := _label(column,title,21)
    head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var explanation := _label(column,subtitle,14)
    explanation.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    explanation.custom_minimum_size.y = 42
    var extra := _label(column,detail,12)
    extra.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    extra.name = "Muted"
    var play := _button(column,"JOGAR",action,220)
    play.set_meta("arcade_variant",color)
    play.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

func _show_play_modes() -> void:
    _clear_modal()
    _set_modal_dimensions(760,380)
    var headline := _label(dialog_box,"ESCOLHA SEU MODO",25)
    headline.name = "Title"
    headline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var subtitle := _label(dialog_box,"O Jardim tem cinco ondas. Como deseja jogar hoje?",14)
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var choices := HBoxContainer.new()
    choices.name = "ModeCards"
    choices.add_theme_constant_override("separation",14)
    dialog_box.add_child(choices)
    _mode_card(choices,"✦","MODO NORMAL","Cada partida é diferente.",
        "SEED ALEATÓRIA  ·  5 ONDAS",_play,"gold")
    var today: String = challenge.utc_day()
    _mode_card(choices,"◈","DESAFIO DO DIA","Uma seed por dia para superar seu recorde.",
        today+"  ·  RECORDES LOCAIS",_start_daily,"blue")
    var back := _button(dialog_box,"VOLTAR",_close_modal,165)
    back.set_meta("compact",true)
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
    get_tree().change_scene_to_file("res://scenes/c10/game_stage.tscn")

func _show_tutorial(start_after: bool) -> void:
    _clear_modal()
    _set_modal_dimensions(605,420)
    _label(dialog_box, "COMO JOGAR  ·  KUBROGUE", 27)
    _label(dialog_box, "1. Leve o cursor em forma de mão sobre um cubo colorido. Clique ou segure para girar camadas de verdade.", 18)
    _label(dialog_box, "2. Cubos resolvidos concedem moedas permanentes e XP da partida. Novos tipos exigem mais giros.", 18)
    _label(dialog_box, "3. A cada nível, escolha uma entre três habilidades. Resolva cinco ondas e a elite 3×3 antes do fim do tempo.", 18)
    _label(dialog_box, "4. Resolva cinco ondas antes que o tempo acabe. Evolua apenas durante a partida, escolhendo cartas de habilidade.", 18)
    _label(dialog_box, "5. Resolva 4 cubos em sequência para ativar FEVER: +20% moedas e até +6 segundos de bônus por onda. Cartas e pausas congelam o relógio do Fever.", 18)
    _label(dialog_box, "6. Complete contratos, visite a Oficina e escolha rotas entre ondas para fortalecer a partida.", 18)
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
    _set_modal_dimensions(860,510)
    var heading := _label(dialog_box,"◈  BESTIÁRIO DO JARDIM",25)
    heading.name = "Title"
    var discovered: int = journal.discovery_total()
    var total_solved := 0
    for entry in journal.CATALOG:
        total_solved += journal.solved_count(String(entry["id"]))
    _label(dialog_box,"%d / 7 DESCOBERTOS     ◆     %d CUBOS RESOLVIDOS" % [
        discovered,total_solved],16)
    var gallery := GridContainer.new()
    gallery.name = "SpeciesGallery"
    gallery.columns = 2
    gallery.add_theme_constant_override("h_separation",12)
    gallery.add_theme_constant_override("v_separation",12)
    dialog_box.add_child(gallery)
    var shades := {
        "golden":Color("#ddaa41"), "armored":Color("#9e8bda"),
        "elite":Color("#bf82cb"), "master4":Color("#78cddd"),
        "master5":Color("#e8accd")
    }
    for entry in journal.CATALOG:
        var kind: String = String(entry["id"])
        var amount: int = journal.solved_count(kind)
        var known := amount > 0
        var panel := PanelContainer.new()
        panel.name = "Species_%s" % kind
        panel.custom_minimum_size = Vector2(371,154)
        panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        panel.set_meta("skill_category",
            "Moedas" if known and String(entry["rarity"]) in ["RARO","LENDÁRIO"] else "Controle")
        gallery.add_child(panel)
        var content := HBoxContainer.new()
        content.add_theme_constant_override("separation",12)
        panel.add_child(content)
        var preview := CubePreview.new()
        preview.name = "Preview"
        preview.custom_minimum_size = Vector2(110,112)
        content.add_child(preview)
        preview.configure(int(entry["dimension"]),known,
            shades.get(kind,Color("#65bea4")))
        var fields := VBoxContainer.new()
        fields.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        fields.add_theme_constant_override("separation",5)
        content.add_child(fields)
        var caption := _label(fields,
            String(entry["name"]) if known else "???  ·  A DESCOBRIR",17)
        caption.name = "Title"
        _label(fields,String(entry["rarity"]) if known else "BLOQUEADO",12)
        _label(fields,"%d×%d×%d  ·  %d MOEDAS" % [
            int(entry["dimension"]),int(entry["dimension"]),
            int(entry["dimension"]),int(entry["coins"])
        ] if known else "ESPÉCIE AINDA OCULTA",12)
        var description := _label(fields,
            String(entry["detail"]) if known else "Encontre no Jardim para revelar.",12)
        description.custom_minimum_size.y = 35
        _label(fields,"RESOLVIDOS  %d" % amount if known else "NÃO DESCOBERTO",12)
    var divider := HSeparator.new()
    dialog_box.add_child(divider)
    var contracts_title := _label(dialog_box,"CONTRATOS DA PARTIDA",21)
    contracts_title.name = "Title"
    _label(dialog_box,"Bônus recebidos ao concluir desafios. Nada para resgatar manualmente.",13)
    var goals := GridContainer.new()
    goals.name = "ContractGallery"
    goals.columns = 2
    goals.add_theme_constant_override("h_separation",10)
    goals.add_theme_constant_override("v_separation",10)
    dialog_box.add_child(goals)
    for goal in journal.CONTRACTS:
        var card := PanelContainer.new()
        card.name = "Contract_%s" % String(goal["id"])
        card.custom_minimum_size = Vector2(360,90)
        card.set_meta("skill_category","Moedas")
        goals.add_child(card)
        var body := VBoxContainer.new()
        body.add_theme_constant_override("separation",6)
        card.add_child(body)
        _label(body,"%s  ·  +%d" % [
            String(goal["title"]),int(goal["reward"])],16)
        _label(body,String(goal["detail"]),13)
    _button(dialog_box,"VOLTAR",_close_modal,210)
    _open_modal()

func _show_settings() -> void:
    _clear_modal()
    _set_modal_dimensions(605,420)
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
