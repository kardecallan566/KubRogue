extends Button
## Compact active skill with permanent visible level + small info marker.
const SkillIcon = preload("res://scripts/c8/skill_icon.gd")
signal inspect(id: String)
var skill_id := ""
var level := 0
var art: Control
var level_label: Label
var info_mark: Label

func _ready() -> void:
    custom_minimum_size = Vector2(62,64)
    focus_mode = Control.FOCUS_ALL
    mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    flat = false
    add_theme_stylebox_override("normal", _box(false))
    add_theme_stylebox_override("hover", _box(true))
    add_theme_stylebox_override("pressed", _box(true))
    add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    art = SkillIcon.new()
    art.position = Vector2(3,2)
    art.size = Vector2(50,50)
    art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(art)
    level_label = Label.new()
    level_label.name = "SkillLevel"
    level_label.position = Vector2(29,43)
    level_label.custom_minimum_size = Vector2(32,18)
    level_label.add_theme_font_size_override("font_size", 13)
    level_label.add_theme_color_override("font_color", Color("#244a42"))
    level_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(level_label)
    info_mark = Label.new()
    info_mark.name = "InfoMark"
    info_mark.text = "i"
    info_mark.position = Vector2(46,3)
    info_mark.add_theme_font_size_override("font_size", 14)
    info_mark.add_theme_color_override("font_color", Color("#173d50"))
    info_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(info_mark)
    pressed.connect(_inspect)

func _box(over: bool) -> StyleBoxFlat:
    var box := StyleBoxFlat.new()
    box.bg_color = Color("#ecf9ef") if over else Color("#ffffff")
    box.border_color = Color("#489c8a") if over else Color("#bbd5c8")
    box.set_border_width_all(2)
    box.set_corner_radius_all(12)
    box.shadow_size = 2
    box.shadow_color = Color("#253b33",0.16)
    box.shadow_offset = Vector2(0,2)
    return box

func configure(card: Dictionary, rank: int) -> void:
    skill_id = String(card.get("id", ""))
    level = rank
    if art != null:
        art.set_skill(skill_id)
    if level_label != null:
        level_label.text = "×%d" % level
    tooltip_text = "%s (Nv %d)\n%s\n%s\nClique para ver mais" % [
        String(card.get("name","")),level,String(card.get("value","")),
        String(card.get("description",""))
    ]

func _inspect() -> void:
    inspect.emit(skill_id)
