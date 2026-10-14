extends Control
## Pooled lightweight screen-space particles. Never captures clicks.
## Reduced particles setting uses only a single ring, with no confetti.
var pulses: Array[Dictionary] = []
var total_events := 0
const MAX_PULSES := 22
const LIFETIME := 0.46
const PALETTE := {
    "turn": Color("#d4f2ef"),
    "solved": Color("#ffe47a"),
    "coins": Color("#f8d36b"),
    "elite": Color("#dcbbff"),
    "wave": Color("#f8faf2"),
    "hit": Color("#ff9477"),
    "level": Color("#84f1d5")
}

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    set_process(false)

func reduced() -> bool:
    var progress := get_node_or_null("/root/KubeSession")
    if progress == null or progress.data.is_empty():
        return false
    return bool(progress.data["settings"].get("reduced_particles", false))

func burst(screen_point: Vector2, kind: String, message: String = "") -> void:
    if not PALETTE.has(kind):
        return
    var bounds := get_viewport_rect().size
    var p := Vector2(clampf(screen_point.x, 55.0, maxf(55.0, bounds.x - 55.0)),
        clampf(screen_point.y, 42.0, maxf(42.0, bounds.y - 42.0)))
    if pulses.size() >= MAX_PULSES:
        pulses.pop_front()
    pulses.append({"point":p, "kind":kind, "age":0.0, "minimal":reduced()})
    total_events += 1
    if not message.is_empty():
        _floating_text(p, message, PALETTE[kind])
    set_process(true)
    queue_redraw()

func _floating_text(point: Vector2, message: String, tint: Color) -> void:
    var label := Label.new()
    label.name = "FloatingReward"
    label.text = message
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 22)
    label.add_theme_color_override("font_color", tint)
    label.add_theme_color_override("font_shadow_color", Color("#233444"))
    label.add_theme_constant_override("shadow_offset_x", 1)
    label.add_theme_constant_override("shadow_offset_y", 2)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    label.position = point + Vector2(-110.0, -51.0)
    label.size = Vector2(220.0, 36.0)
    add_child(label)
    var tween := create_tween().set_parallel(true)
    tween.tween_property(label, "position:y", label.position.y - 45.0, 0.78)
    tween.tween_property(label, "modulate:a", 0.0, 0.78)
    tween.chain().tween_callback(label.queue_free)

func _process(delta: float) -> void:
    for i in range(pulses.size() - 1, -1, -1):
        pulses[i]["age"] = float(pulses[i]["age"]) + delta
        if float(pulses[i]["age"]) >= LIFETIME:
            pulses.remove_at(i)
    queue_redraw()
    if pulses.is_empty():
        set_process(false)

func _draw() -> void:
    for pulse in pulses:
        var center: Vector2 = pulse["point"]
        var age: float = float(pulse["age"]) / LIFETIME
        var color: Color = PALETTE[pulse["kind"]]
        color.a = (1.0 - age) * 0.86
        draw_arc(center, 12.0 + age * 32.0, 0.0, TAU, 28, color, 3.0, true)
        if bool(pulse["minimal"]):
            continue
        for n in range(9):
            var angle := TAU * float(n) / 9.0 + float(total_events) * 0.14
            var radius := 7.0 + age * (21.0 + float(n % 3) * 8.0)
            var particle := center + Vector2(cos(angle), sin(angle)) * radius
            draw_circle(particle, (1.0 - age) * 3.4, color)

func active_count() -> int:
    return pulses.size()
