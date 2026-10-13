extends RefCounted
## C5.2: restrained playful UI. The 3D cubes are the main attraction;
## buttons retain a tactile arcade bevel without giant colored plinths.
const INK := Color("#39413a")
const MUTED := Color("#737a6d")
const PAPER := Color("#fbf8ed")
const BORDER := Color("#c9d3bd")

static func palette(kind: String) -> Dictionary:
    match kind:
        "teal":
            return {"front":Color("#56c49c"), "edge":Color("#319478"), "ink":Color("#193e37")}
        "red":
            return {"front":Color("#ee9988"), "edge":Color("#bc6860"), "ink":Color("#5c2c28")}
        "blue":
            return {"front":Color("#9bc8f5"), "edge":Color("#6398cd"), "ink":Color("#234465")}
        "disabled":
            return {"front":Color("#daddd5"), "edge":Color("#b5bcb2"), "ink":Color("#777e77")}
        _:
            return {"front":Color("#ffcc65"), "edge":Color("#d69d43"), "ink":Color("#62451f")}

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

static func button_box(kind: String, state: String) -> StyleBoxFlat:
    var colors: Dictionary = palette(kind)
    var bg: Color = colors["front"]
    if state == "hover":
        bg = bg.lightened(0.10)
    elif state == "pressed":
        bg = bg.darkened(0.06)
    var b := StyleBoxFlat.new()
    b.bg_color = bg
    b.border_color = colors["edge"]
    b.border_width_bottom = 2 if state == "pressed" else 4
    b.border_width_left = 1
    b.border_width_right = 1
    b.border_width_top = 1
    b.set_corner_radius_all(10)
    b.corner_detail = 10
    b.shadow_size = 0 if state == "pressed" else 2
    b.shadow_color = Color("#463b30", 0.17)
    b.shadow_offset = Vector2(0, 1)
    b.content_margin_left = 12
    b.content_margin_right = 12
    b.content_margin_top = 7
    b.content_margin_bottom = 9
    return b

static func _panel(name: String) -> StyleBoxFlat:
    var b := StyleBoxFlat.new()
    b.bg_color = Color("#f9f8f0") if name == "WaveHUD" else PAPER
    b.border_color = BORDER
    b.set_border_width_all(2)
    b.set_corner_radius_all(17)
    b.corner_detail = 12
    b.content_margin_left = 16
    b.content_margin_right = 16
    b.content_margin_top = 13
    b.content_margin_bottom = 15
    b.shadow_color = Color("#2b4233", 0.20)
    b.shadow_size = 5
    b.shadow_offset = Vector2(0, 3)
    return b

static func card_box(category: String, active: bool = false) -> StyleBoxFlat:
    var b := StyleBoxFlat.new()
    b.bg_color = Color("#fffdf5") if not active else Color("#f4ffe9")
    b.border_color = Color("#79bca0") if active else Color("#d6dacb")
    if category == "Tempo" or category == "Controle":
        b.border_color = Color("#9ab5d5") if not active else Color("#608bbb")
    elif category == "Moedas" or category == "Combo":
        b.border_color = Color("#e4c38a") if not active else Color("#c89547")
    b.set_border_width_all(2)
    b.set_corner_radius_all(14)
    b.content_margin_left = 16
    b.content_margin_right = 16
    b.content_margin_top = 15
    b.content_margin_bottom = 15
    b.shadow_color = Color("#223b32", 0.09)
    b.shadow_size = 3
    b.shadow_offset = Vector2(0, 2)
    return b

static func _apply_button(btn: Button) -> void:
    var kind := button_variant(btn)
    btn.add_theme_stylebox_override("normal", button_box(kind, "normal"))
    btn.add_theme_stylebox_override("hover", button_box(kind, "hover"))
    btn.add_theme_stylebox_override("pressed", button_box(kind, "pressed"))
    btn.add_theme_stylebox_override("disabled", button_box("disabled", "normal"))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    var ink: Color = palette(kind)["ink"]
    for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
        btn.add_theme_color_override(state, ink)
    btn.add_theme_color_override("font_disabled_color", MUTED)
    btn.add_theme_font_size_override("font_size", 16 if not btn.has_meta("compact") else 14)
    btn.add_theme_constant_override("outline_size", 0)
    btn.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
    btn.custom_minimum_size.y = maxf(40.0, btn.custom_minimum_size.y)
    btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

static func _apply_label(label: Label) -> void:
    label.add_theme_color_override("font_color", INK)
    label.add_theme_constant_override("shadow_offset_y", 0)
    if label.name == "HeroTitle" or label.name == "Title":
        label.add_theme_color_override("font_color", Color("#3a584b"))
    elif label.name == "Counter" or label.name == "HudTime":
        label.add_theme_color_override("font_color", Color("#a46c35"))
    elif label.name == "Muted":
        label.add_theme_color_override("font_color", MUTED)

static func _bar_box(fill: bool, name: String = "") -> StyleBoxFlat:
    var b := StyleBoxFlat.new()
    b.bg_color = Color("#dfe5db")
    if fill:
        b.bg_color = Color("#e5b75f")
        if name == "StabilityBar":
            b.bg_color = Color("#67c99b")
        elif name == "TimeBar":
            b.bg_color = Color("#79b8ed")
    b.set_corner_radius_all(6)
    return b

static func apply(root: Node) -> void:
    if root is PanelContainer:
        var panel: PanelContainer = root
        if panel.has_meta("skill_category"):
            panel.add_theme_stylebox_override("panel", card_box(String(panel.get_meta("skill_category"))))
        else:
            panel.add_theme_stylebox_override("panel", _panel(panel.name))
    elif root is Button:
        _apply_button(root as Button)
    elif root is Label:
        _apply_label(root as Label)
    elif root is ProgressBar:
        var bar: ProgressBar = root
        bar.add_theme_stylebox_override("background", _bar_box(false))
        bar.add_theme_stylebox_override("fill", _bar_box(true, bar.name))
        bar.show_percentage = false
        bar.custom_minimum_size.y = maxf(9, bar.custom_minimum_size.y)
    for child in root.get_children():
        apply(child)
