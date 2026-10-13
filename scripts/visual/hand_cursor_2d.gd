extends Control
class_name KubRogueHandCursor2D
## Original screen-space hand cursor; drawn in 2D inside CanvasLayer.
## Index fingertip follows the actual mouse pointer without input lag.
## No external images, import step or 3D meshes.
const HOTSPOT := Vector2(14.0, 3.0)
const OUTLINE := Color("#253749")
const FILL := Color("#ffdfba")
const LIGHT := Color("#fff0d6")
const CUFF := Color("#4d72c8")
const ACCENT := Color("#f3c592")
var is_targeting := false
var action_flash := 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    custom_minimum_size = Vector2(58, 80)
    size = Vector2(58, 80)
    pivot_offset = HOTSPOT
    set_process(true)

func follow_pointer(mouse: Vector2) -> void:
    # The fingertip is aligned with the system pointer's click hotspot.
    position = mouse - HOTSPOT

func set_targeting(value: bool) -> void:
    if is_targeting != value:
        is_targeting = value
        queue_redraw()

func celebrate_gesture() -> void:
    action_flash = 0.24
    queue_redraw()

func _process(delta: float) -> void:
    if action_flash > 0.0:
        action_flash = maxf(0.0, action_flash - delta)
        queue_redraw()

func _draw() -> void:
    # Curved cartoon silhouette: extended index + thumb + rounded knuckles.
    # Closing duplicate endpoints makes the outline continuous.
    var silhouette := PackedVector2Array([
        Vector2(10, 8), Vector2(10, 4), Vector2(13, 1),
        Vector2(17, 1), Vector2(20, 4), Vector2(20, 31),
        Vector2(23, 28), Vector2(27, 28), Vector2(30, 31),
        Vector2(30, 35), Vector2(33, 32), Vector2(37, 32),
        Vector2(40, 36), Vector2(40, 39), Vector2(43, 37),
        Vector2(47, 38), Vector2(49, 41), Vector2(49, 49),
        Vector2(47, 56), Vector2(40, 65), Vector2(23, 65),
        Vector2(17, 61), Vector2(7, 48), Vector2(3, 43),
        Vector2(3, 38), Vector2(6, 35), Vector2(9, 36),
        Vector2(15, 43), Vector2(15, 8)
    ])
    var shadow := PackedVector2Array()
    for point in silhouette:
        shadow.append(point + Vector2(2.0, 3.0))
    draw_colored_polygon(shadow, Color(0.09, 0.16, 0.23, 0.22))
    draw_colored_polygon(silhouette, LIGHT if action_flash > 0.0 else FILL)
    var stroke := silhouette.duplicate()
    stroke.append(silhouette[0])
    draw_polyline(stroke, OUTLINE, 2.7, true)

    # Cuff covers the wrist, but never hides the index fingertip.
    var cuff_polygon := PackedVector2Array([
        Vector2(21, 62), Vector2(42, 62), Vector2(45, 70),
        Vector2(21, 72), Vector2(18, 67)
    ])
    draw_colored_polygon(cuff_polygon, CUFF)
    var cuff_stroke := cuff_polygon.duplicate()
    cuff_stroke.append(cuff_polygon[0])
    draw_polyline(cuff_stroke, OUTLINE, 2.4, true)

    draw_line(Vector2(21, 31), Vector2(21, 43), ACCENT, 2.0, true)
    draw_line(Vector2(31, 36), Vector2(31, 45), ACCENT, 2.0, true)
    draw_line(Vector2(40, 40), Vector2(40, 47), ACCENT, 1.8, true)
    draw_line(Vector2(12, 9), Vector2(12, 27), Color("#ffffff"), 2.0, true)

    if is_targeting:
        draw_arc(Vector2(15, 5), 8.5, 0.0, TAU, 24,
            Color("#fff3a5") if action_flash > 0.0 else Color("#6bdbab"), 2.2, true)
