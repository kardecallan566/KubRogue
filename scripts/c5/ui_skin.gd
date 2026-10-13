extends RefCounted
## A reusable original, lightweight UI theme; no imported fonts or textures.
const TEXT := Color("#223a38")
const MINT := Color("#59d4a0")
const PANEL := Color("#f4f7e9")
const BORDER := Color("#7baf98")

static func _panel() -> StyleBoxFlat:
    var skin := StyleBoxFlat.new()
    skin.bg_color = PANEL
    skin.border_color = BORDER
    skin.set_border_width_all(2)
    skin.set_corner_radius_all(15)
    skin.content_margin_left = 17
    skin.content_margin_right = 17
    skin.content_margin_top = 14
    skin.content_margin_bottom = 14
    skin.shadow_size = 3
    skin.shadow_color = Color(0.17, 0.27, 0.24, 0.13)
    return skin

static func _button(bg: Color, outline: Color) -> StyleBoxFlat:
    var skin := StyleBoxFlat.new()
    skin.bg_color = bg
    skin.border_color = outline
    skin.set_border_width_all(2)
    skin.set_corner_radius_all(10)
    skin.content_margin_left = 12
    skin.content_margin_right = 12
    skin.content_margin_top = 7
    skin.content_margin_bottom = 7
    return skin

static func apply(root: Node) -> void:
    if root is PanelContainer:
        (root as PanelContainer).add_theme_stylebox_override("panel", _panel())
    elif root is Button:
        var btn: Button = root
        btn.add_theme_stylebox_override("normal", _button(MINT, Color("#318966")))
        btn.add_theme_stylebox_override("hover", _button(Color("#a5efbd"), Color("#318966")))
        btn.add_theme_stylebox_override("pressed", _button(Color("#39a97c"), Color("#286f59")))
        btn.add_theme_stylebox_override("disabled", _button(Color("#c9d2c8"), Color("#9aa99c")))
        btn.add_theme_color_override("font_color", TEXT)
        btn.add_theme_color_override("font_hover_color", TEXT)
        btn.add_theme_color_override("font_pressed_color", Color.WHITE)
        btn.add_theme_color_override("font_disabled_color", Color("#63786b"))
        btn.add_theme_font_size_override("font_size", 16)
    elif root is Label:
        (root as Label).add_theme_color_override("font_color", TEXT)
    for child in root.get_children():
        apply(child)
