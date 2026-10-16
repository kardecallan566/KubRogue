extends "res://scripts/c12/hub_stage.gd"
## C13 is a small, presentation-only extension of the approved C12 hub.
const CareerStats = preload("res://scripts/c13/career_stats.gd")
var career_mode := "all"
var career_scope: Label
var career_metrics: Label
var career_medals: Label
var career_buttons: Dictionary = {}
var career_gallery: GridContainer

func _show_history() -> void:
    # Preserve the C12 hall, history retry and Back-to-Bestiary navigation.
    super._show_history()
    career_mode = "all"
    career_buttons.clear()
    career_gallery = dialog_box.find_child("HistoryGallery", true, false) as GridContainer
    if career_gallery == null:
        return
    var panel := PanelContainer.new()
    panel.name = "CareerDashboard"
    panel.set_meta("skill_category", "Moedas")
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    dialog_box.add_child(panel)
    dialog_box.move_child(panel, career_gallery.get_index())
    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation", 7)
    panel.add_child(content)
    var title := _label(content, "◈ DESEMPENHO DAS PARTIDAS RECENTES", 18)
    title.name = "Title"
    career_scope = _label(content, "", 12)
    career_scope.name = "CareerScope"
    var filters := HBoxContainer.new()
    filters.name = "CareerFilters"
    filters.add_theme_constant_override("separation", 8)
    content.add_child(filters)
    for option in [
        {"id": "all", "caption": "TODAS", "name": "HistoryFilterAll"},
        {"id": "normal", "caption": "NORMAL", "name": "HistoryFilterNormal"},
        {"id": "daily", "caption": "DIÁRIO", "name": "HistoryFilterDaily"}
    ]:
        var mode_id: String = String(option["id"])
        var button := _button(filters, String(option["caption"]),
            func(): _set_history_mode(mode_id), 128)
        button.name = String(option["name"])
        button.custom_minimum_size.y = 38
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.toggle_mode = true
        career_buttons[mode_id] = button
    career_metrics = _label(content, "", 14)
    career_metrics.name = "CareerMetrics"
    career_medals = _label(content, "", 13)
    career_medals.name = "CareerMedals"
    _refresh_career()
    # New controls were inserted after the C12 modal's first style pass.
    VisualTheme.apply(dialog_center)

func _set_history_mode(mode: String) -> void:
    if mode not in ["all", "normal", "daily"]:
        return
    career_mode = mode
    _refresh_career()

func _refresh_career() -> void:
    if career_gallery == null:
        return
    var stats: Dictionary = CareerStats.summarize(history.runs, career_mode)
    var label: String = {
        "all": "TODOS OS MODOS",
        "normal": "MODO NORMAL",
        "daily": "DESAFIO DIÁRIO"
    }[career_mode]
    career_scope.text = "%s  ·  SOMENTE AS ÚLTIMAS 12 PARTIDAS CONCLUÍDAS" % label
    career_metrics.text = "%d partidas  ·  %d vitórias  ·  %d%% de vitórias  ·  melhor sequência %d" % [
        int(stats["games"]), int(stats["wins"]), int(stats["win_rate"]), int(stats["best_streak"])
    ]
    career_medals.text = "OURO %d  ·  PRATA %d  ·  BRONZE %d    |    %d cubos  ·  +%d moedas  ·  %d FEVER" % [
        int(stats["gold"]), int(stats["silver"]), int(stats["bronze"]),
        int(stats["cubes"]), int(stats["coins"]), int(stats["fevers"])
    ]
    for key in career_buttons:
        var button: Button = career_buttons[key] as Button
        button.set_pressed_no_signal(String(key) == career_mode)
    # Remove nodes from the tree immediately so switching filters is deterministic.
    for old_card in career_gallery.get_children():
        career_gallery.remove_child(old_card)
        old_card.queue_free()
    var shown := 0
    for item in history.recent():
        if career_mode != "all" and String(item["mode"]) != career_mode:
            continue
        _history_card(career_gallery, item)
        shown += 1
    if shown == 0:
        var empty := _label(career_gallery,
            "Nenhuma partida neste modo ainda. Conclua uma para ver suas estatísticas.", 15)
        empty.name = "CareerEmpty"
