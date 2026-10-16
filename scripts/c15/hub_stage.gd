extends "res://scripts/c14/hub_stage.gd"
## Weekly is a third choice INSIDE the existing modes dialog, not a new hub action.
const Calendar = preload("res://scripts/c15/weekly_calendar.gd")

func _open_game() -> void:
    _close_modal()
    get_tree().change_scene_to_file("res://scenes/c15/game_stage.tscn")

func _show_play_modes() -> void:
    super._show_play_modes()
    _set_modal_dimensions(814,405)
    var choices := dialog_box.find_child("ModeCards",true,false) as HBoxContainer
    if choices == null:
        return
    choices.add_theme_constant_override("separation",10)
    for previous in choices.get_children():
        var card := previous as PanelContainer
        if card == null:
            continue
        card.custom_minimum_size.x = 222
        for option in card.find_children("*","Button",true,false):
            option.custom_minimum_size.x = 180
    var card := PanelContainer.new()
    card.name = "Mode_Weekly"
    card.custom_minimum_size = Vector2(222,210)
    card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    card.set_meta("skill_category","Controle")
    choices.add_child(card)
    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation",9)
    card.add_child(content)
    var marker := _label(content,"✧",36)
    marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var title := _label(content,"DESAFIO SEMANAL",20)
    title.name = "Title"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var description := _label(content,"Mesma seed de segunda a domingo (UTC).",13)
    description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    description.custom_minimum_size.y = 42
    var monday: String = challenge.current_week()
    var weekly: Dictionary = challenge.record_for_week(monday)
    var record := _label(content,"%s  ·  %d TENTATIVAS" % [
        monday,int(weekly["attempts"])],12)
    record.name = "Muted"
    record.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var button := _button(content,"JOGAR",_start_weekly,180)
    button.name = "PlayWeekly"
    button.set_meta("arcade_variant","teal")
    VisualTheme.apply(dialog_center)

func _start_weekly() -> void:
    if not challenge.select_mode("weekly"):
        feedback_label.text = "Não foi possível identificar a semana atual (UTC)."
        return
    if not bool(session.data.get("tutorial_completed",false)):
        _show_tutorial(true)
        return
    _open_game()

func _show_history() -> void:
    super._show_history()
    var filters := dialog_box.find_child("CareerFilters",true,false) as HBoxContainer
    if filters == null:
        return
    for option in filters.get_children():
        option.custom_minimum_size.x = 102
    var button := _button(filters,"SEMANAL",
        func(): _set_history_mode("weekly"),102)
    button.name = "HistoryFilterWeekly"
    button.custom_minimum_size.y = 38
    button.toggle_mode = true
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    career_buttons["weekly"] = button
    _refresh_career()
    VisualTheme.apply(dialog_center)

func _set_history_mode(mode: String) -> void:
    if mode != "weekly":
        super._set_history_mode(mode)
        return
    career_mode = "weekly"
    _refresh_career()

func _refresh_career() -> void:
    if career_mode != "weekly":
        super._refresh_career()
        return
    if career_gallery == null or career_scope == null:
        return
    var filtered: Array[Dictionary] = []
    for item in history.runs:
        if String(item["mode"]) == "weekly":
            filtered.append(item)
    var stats: Dictionary = CareerStats.summarize(filtered,"all")
    career_scope.text = "DESAFIO SEMANAL  ·  SOMENTE AS ÚLTIMAS 12 PARTIDAS"
    career_metrics.text = "%d partidas  ·  %d vitórias  ·  %d%% de vitórias  ·  melhor sequência %d" % [
        int(stats["games"]),int(stats["wins"]),int(stats["win_rate"]),
        int(stats["best_streak"])]
    career_medals.text = "OURO %d  ·  PRATA %d  ·  BRONZE %d    |    %d cubos  ·  +%d moedas  ·  %d FEVER" % [
        int(stats["gold"]),int(stats["silver"]),int(stats["bronze"]),
        int(stats["cubes"]),int(stats["coins"]),int(stats["fevers"])]
    for key in career_buttons:
        var button: Button = career_buttons[key] as Button
        button.set_pressed_no_signal(String(key)=="weekly")
    for old in career_gallery.get_children():
        career_gallery.remove_child(old)
        old.queue_free()
    for entry in history.recent():
        if String(entry["mode"]) == "weekly":
            _history_card(career_gallery,entry)
    if filtered.is_empty():
        var empty := _label(career_gallery,
            "Nenhuma partida semanal concluída. Experimente o desafio desta semana!",15)
        empty.name = "CareerEmpty"

func _history_card(parent: Node, item: Dictionary) -> void:
    super._history_card(parent,item)
    if String(item["mode"]) != "weekly":
        return
    var panel := parent.find_child("Run_%d" % int(item["run_id"]),false,false) as PanelContainer
    if panel == null:
        return
    var content := panel.get_child(0) as VBoxContainer
    if content == null or content.get_child_count() < 2:
        return
    var label := content.get_child(1) as Label
    label.text = "DESAFIO SEMANAL %s   ·   ONDA %d/5" % [
        String(item["date"]),int(item["wave"])]
