extends "res://scripts/c13/hub_stage.gd"
## C14: add retroactive achievements while retaining the C12 hall and C13 stats.
const MedalRules = preload("res://scripts/c14/medal_service.gd")
var garden_medals: MedalRules = MedalRules.new()
var garden_tab := 0
var garden_tab_buttons: Array[Button] = []
var species_gallery: GridContainer
var achievements_gallery: GridContainer
var contracts_gallery: GridContainer
var contract_extras: Array[Control] = []

func _open_game() -> void:
    _close_modal()
    get_tree().change_scene_to_file("res://scenes/c14/game_stage.tscn")

func _show_bestiary() -> void:
    super._show_bestiary()
    garden_tab_buttons.clear()
    contract_extras.clear()
    species_gallery = dialog_box.find_child("SpeciesGallery", true, false) as GridContainer
    contracts_gallery = dialog_box.find_child("ContractGallery", true, false) as GridContainer
    if species_gallery == null or contracts_gallery == null:
        return
    # Keep the old C12 History button and C13 career filters untouched.
    var species_index := species_gallery.get_index()
    var contract_index := contracts_gallery.get_index()
    for index in range(species_index + 1, contract_index):
        var control := dialog_box.get_child(index) as Control
        if control != null:
            contract_extras.append(control)
    var summary := _label(dialog_box,
        "✦ %d / %d CONQUISTAS PERMANENTES  ·  JÁ OBTIDAS CONTAM RETROATIVAMENTE" % [
            garden_medals.trophy_count(journal,session),MedalRules.MEDALS.size()], 14)
    summary.name = "GardenMedalSummary"
    dialog_box.move_child(summary,species_gallery.get_index())

    var tabs := HBoxContainer.new()
    tabs.name = "GardenTabs"
    tabs.add_theme_constant_override("separation",10)
    dialog_box.add_child(tabs)
    dialog_box.move_child(tabs,species_gallery.get_index())
    for entry in [
        {"title":"CUBOS","name":"GardenTabSpecies"},
        {"title":"MEDALHAS","name":"GardenTabMedals"},
        {"title":"CONTRATOS","name":"GardenTabContracts"}
    ]:
        var index := garden_tab_buttons.size()
        var button := _button(tabs,String(entry["title"]),
            func(): _set_garden_tab(index),220)
        button.name = String(entry["name"])
        button.toggle_mode = true
        button.custom_minimum_size.y = 40
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        garden_tab_buttons.append(button)

    achievements_gallery = GridContainer.new()
    achievements_gallery.name = "GardenAchievementsGallery"
    achievements_gallery.columns = 2
    achievements_gallery.add_theme_constant_override("h_separation",12)
    achievements_gallery.add_theme_constant_override("v_separation",12)
    dialog_box.add_child(achievements_gallery)
    dialog_box.move_child(achievements_gallery,species_gallery.get_index())
    _populate_achievements()
    _append_mastery_to_species()
    _set_garden_tab(0)
    VisualTheme.apply(dialog_center)

func _set_garden_tab(selected: int) -> void:
    if selected < 0 or selected > 2:
        return
    garden_tab = selected
    species_gallery.visible = selected == 0
    achievements_gallery.visible = selected == 1
    contracts_gallery.visible = selected == 2
    for part in contract_extras:
        part.visible = selected == 2
    for index in range(garden_tab_buttons.size()):
        garden_tab_buttons[index].set_pressed_no_signal(index == selected)

func _append_mastery_to_species() -> void:
    for species in journal.CATALOG:
        var kind: String = String(species["id"])
        var panel := species_gallery.find_child("Species_" + kind, false, false) as PanelContainer
        if panel == null:
            continue
        var body := panel.get_child(0) as HBoxContainer
        if body == null or body.get_child_count() < 2:
            continue
        var details := body.get_child(1) as VBoxContainer
        if details == null:
            continue
        var solved: int = journal.solved_count(kind)
        var mastery := "MAESTRIA BLOQUEADA"
        if solved > 0:
            mastery = garden_medals.mastery_label(solved)
            if solved < MedalRules.MASTERY_GOLD:
                mastery += "  ·  PRÓXIMA %d/%d" % [
                    solved,garden_medals.next_mastery_target(solved)]
            else:
                mastery += "  ·  MÁXIMA"
        var label := _label(details,mastery,12)
        label.name = "Mastery_" + kind
        label.custom_minimum_size.y = 18

func _populate_achievements() -> void:
    for definition in MedalRules.MEDALS:
        var id: String = String(definition["id"])
        var value: int = garden_medals.progress(definition,journal,session)
        var goal: int = int(definition["goal"])
        var owned := garden_medals.unlocked(definition,journal,session)
        var panel := PanelContainer.new()
        panel.name = "Achievement_" + id
        panel.custom_minimum_size = Vector2(348,126)
        panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        panel.set_meta("skill_category","Moedas" if owned else "Controle")
        achievements_gallery.add_child(panel)
        var tint := StyleBoxFlat.new()
        tint.bg_color = Color("#fff1c9") if owned else Color("#edf3ec")
        tint.border_color = Color("#dbaf4b") if owned else Color("#9eafa3")
        tint.set_border_width_all(2)
        tint.set_corner_radius_all(12)
        tint.set_content_margin_all(12)
        panel.add_theme_stylebox_override("panel",tint)
        var body := VBoxContainer.new()
        body.add_theme_constant_override("separation",4)
        panel.add_child(body)
        var heading := _label(body,
            "%s  %s" % [String(definition["glyph"]),String(definition["name"])],17)
        heading.name = "Title"
        _label(body,String(definition["detail"]),12)
        var remaining := _label(body,
            "CONQUISTADA ✓" if owned else "PROGRESSO  %d/%d" % [mini(value,goal),goal],13)
        remaining.name = "AchievementProgress_" + id
