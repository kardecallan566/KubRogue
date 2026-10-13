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
    var idle: StyleBoxTexture = button.get_theme_stylebox("normal") as StyleBoxTexture
    var hover: StyleBoxTexture = button.get_theme_stylebox("hover") as StyleBoxTexture
    var pressed: StyleBoxTexture = button.get_theme_stylebox("pressed") as StyleBoxTexture
    check(idle != null and hover != null and pressed != null, "arcade buttons use generated layered textures")
    if idle != null and hover != null and pressed != null:
        check(idle.texture.get_width() == 288 and idle.texture.get_height() == 104,
            "original button texture includes deep layered bevel")
        var idle_pixel: Color = idle.texture.get_image().get_pixel(140, 30)
        var hover_pixel: Color = hover.texture.get_image().get_pixel(140, 30)
        var press_pixel: Color = pressed.texture.get_image().get_pixel(140, 30)
        check(idle_pixel != hover_pixel, "hover visibly changes the highlight")
        check(press_pixel != idle_pixel, "pressed state visually depresses face")
        check(idle.texture.get_image().get_pixel(0, 0).a < 0.01, "corners stay transparent")
    panel.queue_free()

    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(store_path + suffix))
    print("KubRogue C5 audio and visuals: %d failures" % failures)
    quit(0 if failures == 0 else 1)
