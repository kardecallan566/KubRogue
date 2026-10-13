extends RefCounted
## KubRogue C5.1 — original procedural arcade UI.
## Reference interpreted as stacked cartoon buttons with diagonal stripes,
## gold/wood depth, glossy highlight and white outlined text.
## No external texture or font, and no copyrighted assets.
const INK := Color("#503120")
const PANEL_BG := Color("#fff5df")
const PANEL_EDGE := Color("#96552d")
const PALE_TEXT := Color("#fffaf0")
const W := 288
const H := 104

static var _cached_buttons: Dictionary = {}

static func _inside(x: int, y: int, left: int, top: int, width: int, height: int, radius: int) -> bool:
    if x < left or y < top or x >= left + width or y >= top + height:
        return false
    var cx := clampi(x, left + radius, left + width - radius - 1)
    var cy := clampi(y, top + radius, top + height - radius - 1)
    var dx := x - cx
    var dy := y - cy
    return dx * dx + dy * dy <= radius * radius

static func _palette(kind: String) -> Array[Color]:
    match kind:
        "teal":
            return [Color("#315e55"), Color("#3c886b"), Color("#45b884"), Color("#5de3a3"), Color("#bbffe0")]
        "red":
            return [Color("#60333a"), Color("#8e4150"), Color("#d45656"), Color("#ff7672"), Color("#ffd6af")]
        "blue":
            return [Color("#293f62"), Color("#385c91"), Color("#4f91da"), Color("#67b6ff"), Color("#def2ff")]
        "disabled":
            return [Color("#585c5c"), Color("#777a79"), Color("#979a98"), Color("#b5b9b6"), Color("#d3d7d4")]
        _:
            return [Color("#653a28"), Color("#995125"), Color("#d47a24"), Color("#ffbd1f"), Color("#fff08c")]

static func _render_button(kind: String, state: String) -> StyleBoxTexture:
    var key := kind + ":" + state
    if _cached_buttons.has(key):
        return _cached_buttons[key]
    var colors: Array[Color] = _palette(kind)
    var image := Image.create(W, H, false, Image.FORMAT_RGBA8)
    image.fill(Color.TRANSPARENT)
    var pressed := state == "pressed"
    var lift := 8 if pressed else 0
    var face: Color = colors[3]
    if state == "hover":
        face = face.lightened(0.13)
    if pressed:
        face = face.darkened(0.12)
    for y in range(H):
        for x in range(W):
            var paint := Color.TRANSPARENT
            # Deep stacked layers remain fixed when the face is pressed.
            if _inside(x, y, 2, 22, 284, 78, 24):
                paint = colors[0].darkened(0.17)
            if _inside(x, y, 4, 17, 280, 78, 24):
                paint = colors[0]
            if _inside(x, y, 7, 15, 274, 73, 22):
                paint = colors[1]
            if _inside(x, y, 8, 12 + lift, 272, 69, 22):
                paint = colors[0].darkened(0.25)
            if _inside(x, y, 11, 9 + lift, 266, 68, 22):
                paint = colors[2]
            if _inside(x, y, 14, 6 + lift, 260, 65, 21):
                paint = face
                # Diagonal candy stripes have deliberately low contrast.
                if ((x + y * 2) % 55) < 18:
                    paint = paint.lerp(colors[4], 0.17)
                # Broad curved-looking gloss at the upper third of the face.
                if y < 27 + lift:
                    paint = paint.lerp(colors[4], 0.19)
                elif y > 49 + lift:
                    paint = paint.darkened(0.045 * float(y - 49 - lift) / 20.0)
            if _inside(x, y, 26, 8 + lift, 226, 5, 2):
                paint = paint.lerp(Color.WHITE, 0.48)
            if _inside(x, y, 24, 61 + lift, 233, 3, 1):
                paint = paint.lerp(colors[4], 0.52)
            if paint.a > 0.0:
                image.set_pixel(x, y, paint)
    var texture := ImageTexture.create_from_image(image)
    var box := StyleBoxTexture.new()
    box.texture = texture
    box.texture_margin_left = 32
    box.texture_margin_right = 32
    box.texture_margin_top = 25
    box.texture_margin_bottom = 24
    box.content_margin_left = 19
    box.content_margin_right = 19
    box.content_margin_top = 12
    box.content_margin_bottom = 20
    _cached_buttons[key] = box
    return box

static func button_variant(btn: Button) -> String:
    if btn.has_meta("arcade_variant"):
        return String(btn.get_meta("arcade_variant"))
    var label := btn.text.to_lower()
    if label.contains("sair") or label.contains("cancel") or label.contains("recome") or label.contains("voltar"):
        return "red"
    if label.contains("config") or label.contains("pausar") or label.contains("continuar"):
        return "blue"
    if label.contains("loja") or label.contains("comprar") or label.contains("salvar"):
        return "teal"
    return "gold"

static func _panel(name: String) -> StyleBoxFlat:
    var box := StyleBoxFlat.new()
    box.bg_color = PANEL_BG if name != "WaveHUD" else Color("#fff0d4")
    box.border_color = PANEL_EDGE
    box.set_border_width_all(3)
    box.set_corner_radius_all(18)
    box.corner_detail = 12
    box.content_margin_left = 16
    box.content_margin_right = 16
    box.content_margin_top = 15
    box.content_margin_bottom = 17
    box.shadow_color = Color("#503126", 0.42)
    box.shadow_size = 8
    box.shadow_offset = Vector2(0.0, 6.0)
    return box

static func _apply_label(label: Label) -> void:
    label.add_theme_color_override("font_color", INK)
    if label.name == "Title" or label.name == "HeroTitle":
        label.add_theme_color_override("font_color", Color("#713819"))
        label.add_theme_color_override("font_shadow_color", Color("#ffc756"))
        label.add_theme_constant_override("shadow_offset_y", 2)
    if label.name == "Counter" or label.name == "HudTime":
        label.add_theme_color_override("font_color", Color("#b65717"))

static func apply(root: Node) -> void:
    if root is PanelContainer:
        var panel: PanelContainer = root
        panel.add_theme_stylebox_override("panel", _panel(panel.name))
    elif root is Button:
        var btn: Button = root
        var kind := button_variant(btn)
        btn.add_theme_stylebox_override("normal", _render_button(kind, "normal"))
        btn.add_theme_stylebox_override("hover", _render_button(kind, "hover"))
        btn.add_theme_stylebox_override("pressed", _render_button(kind, "pressed"))
        btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
        btn.add_theme_stylebox_override("disabled", _render_button("disabled", "normal"))
        btn.add_theme_color_override("font_color", PALE_TEXT)
        btn.add_theme_color_override("font_hover_color", Color.WHITE)
        btn.add_theme_color_override("font_pressed_color", Color.WHITE)
        btn.add_theme_color_override("font_focus_color", PALE_TEXT)
        btn.add_theme_color_override("font_disabled_color", Color("#eef0e9"))
        btn.add_theme_color_override("font_outline_color", Color("#653b26"))
        btn.add_theme_constant_override("outline_size", 3)
        btn.add_theme_color_override("font_shadow_color", Color("#5c311e"))
        btn.add_theme_constant_override("shadow_offset_x", 1)
        btn.add_theme_constant_override("shadow_offset_y", 3)
        btn.add_theme_font_size_override("font_size", 18)
        btn.add_theme_font_override("font", ThemeDB.fallback_font)
        btn.custom_minimum_size.y = maxf(48.0, btn.custom_minimum_size.y)
        btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    elif root is Label:
        _apply_label(root as Label)
    elif root is ProgressBar:
        var progress: ProgressBar = root
        progress.add_theme_stylebox_override("background", _bar_background())
        progress.add_theme_stylebox_override("fill", _bar_fill(progress.name))
        progress.show_percentage = false
        progress.custom_minimum_size.y = maxf(17.0, progress.custom_minimum_size.y)
    for child in root.get_children():
        apply(child)

static func _bar_background() -> StyleBoxFlat:
    var b := StyleBoxFlat.new()
    b.bg_color = Color("#634b38")
    b.border_color = Color("#9e6738")
    b.set_border_width_all(2)
    b.set_corner_radius_all(9)
    return b

static func _bar_fill(name: String) -> StyleBoxFlat:
    var b := StyleBoxFlat.new()
    b.bg_color = Color("#ffbb27")
    if name == "StabilityBar":
        b.bg_color = Color("#42c58e")
    elif name == "TimeBar":
        b.bg_color = Color("#ff9d3d")
    b.set_corner_radius_all(8)
    b.border_color = b.bg_color.lightened(0.28)
    b.set_border_width_all(1)
    return b
