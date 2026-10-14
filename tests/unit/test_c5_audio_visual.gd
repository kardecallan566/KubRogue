extends SceneTree
const Feedback = preload("res://scripts/c5/feedback_layer.gd")
const VisualTheme = preload("res://scripts/c5/ui_skin.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error("C5 UNIT FAIL: " + message)

func _run() -> void:
    var sound = get_root().get_node("KubeAudio")
    check(sound.effects.size() == 10, "all ten procedural SFX generated")
    check(sound.voices.size() == 6, "voice pool bounded")
    check(sound.music_player.stream != null, "looping music synthesized")
    check(sound.music_player.stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "music actually loops")
    check(sound.music_loop_seconds() > 14.0 and sound.music_loop_seconds() < 16.0,
        "upbeat eight-bar melody plays longer than old four-second drone")
    check(sound.music_player.stream.data.size() > 500000,
        "loop contains real full-length generated PCM, not a placeholder")
    for kind in ["tap","turn","solved","coins","spawn","level","wave","elite","error","victory"]:
        var wav: AudioStreamWAV = sound.effects[kind]
        check(wav.mix_rate == 22050 and wav.data.size() > 2000, "PCM data for " + kind)
    sound.muted_for_test = true
    sound.play_sfx("turn")
    sound.play_sfx("unknown")
    sound.muted_for_test = false

    var store_path := "user://c5_test_audio_options.json"
    var progress = get_root().get_node("KubeSession")
    progress.configure(Store.new(store_path))
    check(progress.set_setting("music_volume", 0.0), "mute music stored")
    check(sound.music_player.stream_paused, "muted music really stops")
    check(progress.set_setting("music_volume", 0.55), "unmute music stored")
    check(not sound.music_player.stream_paused, "music resumes after unmute")
    check(progress.set_setting("effects_volume", 0.0), "effects mute stored")
    check(sound.voices[0].volume_db <= -75.0, "SFX gain effectively muted")
    check(progress.set_setting("effects_volume", 0.6), "effects unmute stored")
    check(sound.voices[0].volume_db > -40.0, "effects resume at saved gain")

    var overlay: Feedback = Feedback.new()
    get_root().add_child(overlay)
    check(overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE, "particles never block clicking")
    progress.set_setting("reduced_particles", true)
    overlay.burst(Vector2(140, 140), "solved", "+10")
    check(overlay.active_count() == 1 and bool(overlay.pulses[0]["minimal"]), "reduced particle mode")
    progress.set_setting("reduced_particles", false)
    overlay.burst(Vector2(200, 140), "elite")
    check(overlay.active_count() == 2 and not bool(overlay.pulses[1]["minimal"]), "full particle mode")
    for i in range(60):
        overlay.burst(Vector2(150, 160), "turn")
    check(overlay.active_count() <= Feedback.MAX_PULSES, "particle pulses capped")
    overlay.queue_free()
    var panel := PanelContainer.new()
    get_root().add_child(panel)
    var button := Button.new()
    panel.add_child(button)
    VisualTheme.apply(panel)
    check(panel.has_theme_stylebox_override("panel"), "custom panel background")
    check(button.has_theme_stylebox_override("normal"), "custom button palette")
    var idle: StyleBoxFlat = button.get_theme_stylebox("normal") as StyleBoxFlat
    var hover: StyleBoxFlat = button.get_theme_stylebox("hover") as StyleBoxFlat
    var pressed: StyleBoxFlat = button.get_theme_stylebox("pressed") as StyleBoxFlat
    check(idle != null and hover != null and pressed != null,
        "restyled arcade buttons use lightweight native StyleBoxFlat")
    if idle != null and hover != null and pressed != null:
        check(idle.corner_radius_top_left >= 8, "buttons have restrained rounded corners")
        check(hover.bg_color != idle.bg_color, "hover visibly lightens face")
        check(pressed.border_width_bottom < idle.border_width_bottom,
            "pressed state loses bottom depth without oversized plinth")
        check(idle.shadow_size <= 3, "button shadow is subtle")
    var SkillCard = load("res://scripts/c5/skill_card.gd")
    var skill_widget = SkillCard.new()
    get_root().add_child(skill_widget)
    skill_widget.configure_skill(1, {
        "id":"bolsa_encantada", "tag":"Moedas", "name":"Bolsa encantada",
        "value":"+15% por nível", "description":"Moedas extras por solução"
    }, 0)
    check(skill_widget.title_label.text == "Bolsa encantada", "card title is separate")
    check(skill_widget.bonus_label.text == "+15% por nível", "bonus is readable alone")
    check(skill_widget.level_label.text.contains("0") and skill_widget.level_label.text.contains("1"),
        "card shows level transition independently")
    check(skill_widget.action_button.text == "ESCOLHER", "card has a distinct action")
    check(skill_widget.custom_minimum_size.y >= 200, "skill card has room to breathe")
    skill_widget.queue_free()
    panel.queue_free()

    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(store_path + suffix))
    print("KubRogue C5 audio and visuals: %d failures" % failures)
    quit(0 if failures == 0 else 1)
