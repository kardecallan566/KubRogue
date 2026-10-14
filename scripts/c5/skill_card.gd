extends PanelContainer
## Focused, self-contained skill card. Three cards represent three distinct
## choices, not stretched menu buttons. Choice handling stays in C3 RunBuild.
signal chosen(index: int)
const ThemeStyle = preload("res://scripts/c5/ui_skin.gd")
var choice_index := 0
var skill_id := ""
var category := ""
var category_label: Label
var title_label: Label
var level_label: Label
var bonus_label: Label
var description_label: Label
var action_button: Button

func _ready() -> void:
    name = "SkillChoiceCard"
    custom_minimum_size = Vector2(252, 216)
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
    mouse_filter = Control.MOUSE_FILTER_STOP
    var content := VBoxContainer.new()
    content.name = "CardContent"
    content.add_theme_constant_override("separation", 7)
    add_child(content)

    var header := HBoxContainer.new()
    header.add_theme_constant_override("separation", 8)
    content.add_child(header)
    category_label = _label(header, "", 12)
    category_label.name = "Muted"
    category_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    level_label = _label(header, "", 12)

    title_label = _label(content, "", 21)
    title_label.autowrap_mode = TextServer.AUTOWRAP_WORD
    bonus_label = _label(content, "", 17)
    bonus_label.autowrap_mode = TextServer.AUTOWRAP_WORD
    description_label = _label(content, "", 14)
    description_label.autowrap_mode = TextServer.AUTOWRAP_WORD
    description_label.name = "Muted"

    var space := Control.new()
    space.size_flags_vertical = Control.SIZE_EXPAND_FILL
    space.mouse_filter = Control.MOUSE_FILTER_IGNORE
    content.add_child(space)
    action_button = Button.new()
    action_button.text = "ESCOLHER"
    action_button.set_meta("arcade_variant", "teal")
    action_button.custom_minimum_size.y = 43
    action_button.pressed.connect(func(): chosen.emit(choice_index))
    content.add_child(action_button)
    ThemeStyle.apply(self)

func _label(parent: Node, value: String, font_size: int) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_font_size_override("font_size", font_size)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(label)
    return label

func configure_skill(index: int, card: Dictionary, rank: int) -> void:
    choice_index = index
    skill_id = String(card.get("id", ""))
    category = String(card.get("tag", ""))
    set_meta("skill_category", category)
    category_label.text = category.to_upper()
    title_label.text = String(card.get("name", "Habilidade"))
    level_label.text = "NV %d → %d" % [rank, rank + 1]
    bonus_label.text = String(card.get("value", "Bônus"))
    description_label.text = String(card.get("description", ""))
    var colors: Dictionary = ThemeStyle.palette("blue" if category in ["Controle", "Tempo"] else ("gold" if category in ["Moedas", "Combo"] else "teal"))
    bonus_label.add_theme_color_override("font_color", colors["edge"])
    add_theme_stylebox_override("panel", ThemeStyle.card_box(category))
    action_button.disabled = false

func set_selected_focus() -> void:
    action_button.grab_focus()
