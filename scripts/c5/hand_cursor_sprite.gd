extends Control
## C5 cursor artwork: two original, transparent 128x128 sprites.
## The actual mouse position is the hotspot in both modes.
## Earlier C0-C4 scenes keep their original procedural hand.
# Read PNG bytes directly so 'godot .' can start without the editor having
# imported .png resources into .godot/imported/. The export preset explicitly
# includes these source files for the same behavior in the Windows .pck.
const OPEN_PATH := "res://assets/c5/hand_open.png"
const GRIP_PATH := "res://assets/c5/hand_grip.png"
const CURSOR_SIZE := Vector2(78.0, 78.0)
const OPEN_HOTSPOT := Vector2(29.0, 6.0)
const GRIP_HOTSPOT := Vector2(38.0, 22.0)

var is_targeting := false
var is_gripping := false
var action_flash := 0.0
var last_mouse := Vector2.ZERO
var _open_texture: Texture2D
var _grip_texture: Texture2D

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    custom_minimum_size = CURSOR_SIZE
    size = CURSOR_SIZE
    pivot_offset = CURSOR_SIZE * 0.5
    _open_texture = _read_png(OPEN_PATH)
    _grip_texture = _read_png(GRIP_PATH)
    set_process(true)

func _read_png(path: String) -> Texture2D:
    # ResourceLoader/preload() cannot resolve non-imported PNGs in fresh clones.
    # Image.load_png_from_buffer reads the original bytes without import metadata.
    var bytes := FileAccess.get_file_as_bytes(path)
    if bytes.is_empty():
        push_error("C5 cursor PNG não encontrado: " + path)
        return null
    var image := Image.new()
    var status := image.load_png_from_buffer(bytes)
    if status != OK:
        push_error("C5 cursor PNG inválido (%d): %s" % [status, path])
        return null
    if image.get_width() != 128 or image.get_height() != 128:
        push_error("C5 cursor PNG deve ter 128x128: " + path)
        return null
    return ImageTexture.create_from_image(image)

func get_active_texture() -> Texture2D:
    return _grip_texture if is_gripping else _open_texture

func current_hotspot() -> Vector2:
    return GRIP_HOTSPOT if is_gripping else OPEN_HOTSPOT

func follow_pointer(mouse: Vector2) -> void:
    last_mouse = mouse
    position = mouse - current_hotspot()

func set_targeting(value: bool) -> void:
    if is_targeting == value:
        return
    is_targeting = value
    queue_redraw()

func set_gripping(value: bool) -> void:
    if is_gripping == value:
        return
    is_gripping = value
    # Switching sprites must never shift the interaction point.
    follow_pointer(last_mouse)
    queue_redraw()

func celebrate_gesture() -> void:
    action_flash = 0.14
    queue_redraw()

func _process(delta: float) -> void:
    if action_flash > 0.0:
        action_flash = maxf(0.0, action_flash - delta)
        queue_redraw()

func _draw() -> void:
    var texture := get_active_texture()
    if texture == null:
        return
    draw_texture_rect(texture, Rect2(Vector2.ZERO, CURSOR_SIZE), false)
    if is_targeting and not is_gripping:
        draw_arc(current_hotspot(), 7.5, 0.0, TAU, 28,
            Color("#4ad3a1", 0.77), 1.9, true)
    if action_flash > 0.0 and is_gripping:
        draw_arc(current_hotspot(), 10.0 + action_flash * 13.0, 0.0,
            TAU, 24, Color("#ffe3a0", action_flash / 0.14 * 0.72), 2.0, true)
