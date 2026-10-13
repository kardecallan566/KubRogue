extends Node
## C5: entirely original synthesized audio. No downloaded music or sample licenses.
## Kept in one autoload so switching scenes never interrupts the background loop.
const RATE := 22050
const POLYPHONY := 6
const NOTE_FREQUENCIES := [220.0, 261.63, 329.63, 392.00, 440.0, 523.25, 587.33, 659.26]
var music_player: AudioStreamPlayer
var voices: Array[AudioStreamPlayer] = []
var effects: Dictionary = {}
var voice_index := 0
var muted_for_test := false

func _ready() -> void:
    music_player = AudioStreamPlayer.new()
    music_player.name = "GardenMusic"
    add_child(music_player)
    for i in range(POLYPHONY):
        var voice := AudioStreamPlayer.new()
        voice.name = "SFX_%d" % i
        add_child(voice)
        voices.append(voice)
    for kind in ["tap", "turn", "solved", "coins", "spawn", "level", "wave", "elite", "error", "victory"]:
        effects[kind] = _synthesize_effect(kind)
    music_player.stream = _synthesize_music()
    var progress := get_node_or_null("/root/KubeSession")
    if progress != null:
        progress.progress_changed.connect(refresh_volumes)
    refresh_volumes()
    music_player.play()

func _wav(samples: PackedByteArray, looping: bool = false) -> AudioStreamWAV:
    var wave := AudioStreamWAV.new()
    wave.format = AudioStreamWAV.FORMAT_16_BITS
    wave.mix_rate = RATE
    wave.stereo = false
    wave.data = samples
    if looping:
        wave.loop_mode = AudioStreamWAV.LOOP_FORWARD
        wave.loop_begin = 0
        wave.loop_end = samples.size() / 2
    return wave

func _synthesize_effect(kind: String) -> AudioStreamWAV:
    var duration := 0.34 if kind == "victory" else (0.45 if kind == "level" else 0.19)
    var count := int(RATE * duration)
    var pcm := PackedByteArray()
    pcm.resize(count * 2)
    var base := 420.0
    match kind:
        "tap": base = 640.0
        "turn": base = 385.0
        "solved": base = 660.0
        "coins": base = 980.0
        "spawn": base = 290.0
        "level": base = 580.0
        "wave": base = 460.0
        "elite": base = 185.0
        "error": base = 155.0
        "victory": base = 523.25
    for i in range(count):
        var t := float(i) / float(RATE)
        var normalized := float(i) / float(count)
        var attack := minf(1.0, normalized * 45.0)
        var tail := pow(1.0 - normalized, 2.0)
        var bend := 1.0 + (0.18 if kind == "solved" or kind == "coins" else -0.12) * normalized
        var fundamental := sin(TAU * base * bend * t)
        var overtone := 0.24 * sin(TAU * base * 2.02 * t)
        var sound := (fundamental + overtone) * attack * tail * 0.29
        pcm.encode_s16(i * 2, int(clampf(sound, -0.99, 0.99) * 32767.0))
    return _wav(pcm)

func _synthesize_music() -> AudioStreamWAV:
    # Four gently arpeggiated chords, 4 seconds long, repeat without external assets.
    var count := RATE * 4
    var pcm := PackedByteArray()
    pcm.resize(count * 2)
    var root_notes := [261.63, 293.66, 220.00, 246.94]
    for i in range(count):
        var t := float(i) / float(RATE)
        var beat_index := int(floor(t * 2.0))
        var root := float(root_notes[int(floor(t)) % root_notes.size()])
        var arpeggio: float = float([1.0, 1.25, 1.5, 2.0][beat_index % 4])
        var pulse := 0.5 + 0.5 * cos(TAU * fmod(t, 0.5) * 2.0)
        var chord := 0.075 * sin(TAU * root * t)
        chord += 0.045 * sin(TAU * root * 1.5 * t)
        chord += 0.025 * pulse * sin(TAU * root * arpeggio * t)
        pcm.encode_s16(i * 2, int(clampf(chord, -0.95, 0.95) * 32767.0))
    return _wav(pcm, true)

func refresh_volumes() -> void:
    if music_player == null:
        return
    var progress := get_node_or_null("/root/KubeSession")
    if progress == null or progress.data.is_empty():
        return
    var settings: Dictionary = progress.data["settings"]
    var music := clampf(float(settings.get("music_volume", 0.8)), 0.0, 1.0)
    var sfx := clampf(float(settings.get("effects_volume", 0.85)), 0.0, 1.0)
    music_player.volume_db = linear_to_db(maxf(music * 0.30, 0.0001))
    music_player.stream_paused = music <= 0.001
    for voice in voices:
        voice.volume_db = linear_to_db(maxf(sfx * 0.65, 0.0001))
        voice.stream_paused = sfx <= 0.001

func play_sfx(kind: String) -> void:
    if not effects.has(kind) or voices.is_empty() or muted_for_test:
        return
    var progress := get_node_or_null("/root/KubeSession")
    if progress != null and not progress.data.is_empty():
        if float(progress.data["settings"].get("effects_volume", 0.85)) <= 0.001:
            return
    var voice := voices[voice_index]
    voice_index = (voice_index + 1) % voices.size()
    voice.stop()
    voice.stream = effects[kind]
    voice.play()
