extends PanelContainer
## Visual C8 card. Same API as the C5 card; C0-C7 remain unmodified.
signal chosen(index: int)
const ThemeStyle = preload("res://scripts/c5/ui_skin.gd")
const SkillIcon = preload("res://scripts/c8/skill_icon.gd")
var choice_index := 0
var skill_id := ""
var category := ""
var category_label: Label
var title_label: Label
var level_label: Label
var bonus_label: Label
var description_label: Label
var action_button: Button
var artwork: Control

func _ready() -> void:
    name = "SkillChoiceCard"
    custom_minimum_size = Vector2(252,260)
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
    mouse_filter = Control.MOUSE_FILTER_STOP
    var body := VBoxContainer.new()
    body.name = "CardContent"
    body.add_theme_constant_override("separation", 6)
    add_child(body)
    var header := HBoxContainer.new()
    header.add_theme_constant_override("separation",8)
    body.add_child(header)
    var icon_frame := PanelContainer.new()
    icon_frame.name = "AbilityIconFrame"
    icon_frame.custom_minimum_size = Vector2(74,74)
    var backing := StyleBoxFlat.new()
    backing.bg_color = Color("#e7f3e9")
    backing.set_corner_radius_all(15)
    backing.border_color = Color("#99baaa")
    backing.set_border_width_all(2)
    icon_frame.add_theme_stylebox_override("panel",backing)
    header.add_child(icon_frame)
    artwork = SkillIcon.new()
    artwork.custom_minimum_size = Vector2(70,70)
    icon_frame.add_child(artwork)
    var head_right := VBoxContainer.new()
    head_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    head_right.add_theme_constant_override("separation",4)
    header.add_child(head_right)
    category_label = _label(head_right,"",12)
    category_label.name = "Muted"
    level_label = _label(head_right,"",14)
    title_label = _label(body,"",22)
    title_label.autowrap_mode = TextServer.AUTOWRAP_WORD
    bonus_label = _label(body,"",18)
    bonus_label.autowrap_mode = TextServer.AUTOWRAP_WORD
    description_label = _label(body,"",14)
    description_label.autowrap_mode = TextServer.AUTOWRAP_WORD
    description_label.name = "Muted"
    var spacer := Control.new()
    spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    body.add_child(spacer)
    action_button = Button.new()
    action_button.text = "ESCOLHER"
    action_button.set_meta("arcade_variant", "teal")
    action_button.custom_minimum_size.y = 43
    action_button.pressed.connect(func(): chosen.emit(choice_index))
    body.add_child(action_button)
    ThemeStyle.apply(self)

func _label(parent: Node, value: String, size_px: int) -> Label:
    var lab := Label.new()
    lab.text = value
    lab.add_theme_font_size_override("font_size",size_px)
    lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(lab)
    return lab

func configure_skill(index: int, card: Dictionary, rank: int) -> void:
    choice_index = index
    skill_id = String(card.get("id", ""))
    category = String(card.get("tag", ""))
    set_meta("skill_category",category)
    artwork.set_skill(skill_id)
    category_label.text = category.to_upper()
    title_label.text = String(card.get("name", "Habilidade"))
    level_label.text = "NV %d → %d" % [rank,rank+1]
    bonus_label.text = String(card.get("value","Bônus"))
    description_label.text = String(card.get("description",""))
    var palette: Dictionary = ThemeStyle.palette(
        "blue" if category in ["Controle","Tempo"] else (
            "gold" if category in ["Moedas","Combo"] else "teal"))
    bonus_label.add_theme_color_override("font_color",palette["edge"])
    add_theme_stylebox_override("panel",ThemeStyle.card_box(category))
    action_button.disabled = false

func set_selected_focus() -> void:
    action_button.grab_focus()
