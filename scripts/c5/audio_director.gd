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

## Upbeat, original eight-bar loop (C major / F / Am / G), 132 BPM.
## Procedural drums, bounce bass, bright plucks and a syncopated melody.
## Generated once at boot; no external assets, streaming or runtime synthesis.
const MUSIC_BPM := 132.0
const MUSIC_BARS := 8
const MUSIC_MELODY := [
    72,76,79,76,74,76,79,-1,
    76,79,84,79,76,74,72,-1,
    72,77,81,77,76,74,72,-1,
    77,81,84,81,79,77,76,-1,
    69,72,76,72,69,76,79,-1,
    72,76,81,79,76,72,69,-1,
    71,74,79,74,71,74,77,-1,
    74,79,83,79,76,74,72,-1
]
const MUSIC_CHORDS := [
    [60,64,67], [60,64,67], [65,69,72], [65,69,72],
    [57,60,64], [57,60,64], [67,71,74], [67,71,74]
]

func music_loop_seconds() -> float:
    return 60.0 / MUSIC_BPM * 4.0 * float(MUSIC_BARS)

func _midi(note: int) -> float:
    return 440.0 * pow(2.0, (float(note) - 69.0) / 12.0)

func _synthesize_music() -> AudioStreamWAV:
    var total_seconds := music_loop_seconds()
    var frame_count := int(round(float(RATE) * total_seconds))
    var pcm := PackedByteArray()
    pcm.resize(frame_count * 2)
    var beat_length := 60.0 / MUSIC_BPM
    var eighth_length := beat_length * 0.5
    var melody_hz: Array[float] = []
    for note in MUSIC_MELODY:
        melody_hz.append(_midi(int(note)) if int(note) >= 0 else 0.0)
    var chord_hz: Array[Array] = []
    for bar in MUSIC_CHORDS:
        var freqs: Array = []
        for note in bar:
            freqs.append(_midi(int(note)))
        chord_hz.append(freqs)
    for i in range(frame_count):
        var t := float(i) / float(RATE)
        var step := mini(int(t / eighth_length), MUSIC_MELODY.size() - 1)
        var bar_id := mini(step / 8, MUSIC_BARS - 1)
        var beat := step / 2
        var eighth_phase := fmod(t, eighth_length) / eighth_length
        var beat_age := fmod(t, beat_length)
        var beat_phase := beat_age / beat_length
        var env := pow(1.0 - eighth_phase, 2.0)

        # Joyful video-game melody: two bright harmonics, tight pluck envelope.
        var lead := 0.0
        var freq: float = melody_hz[step]
        if freq > 0.0:
            var attack := minf(1.0, eighth_phase * 24.0)
            lead = (sin(TAU * freq * t) * 0.74 +
                sin(TAU * freq * 2.0 * t) * 0.18 +
                sin(TAU * freq * 3.0 * t) * 0.08) * attack * env * 0.21

        # Playful octave bass with a short decay and a tiny higher harmonic.
        var roots: Array = MUSIC_CHORDS[bar_id]
        var bass_hz := _midi(int(roots[0]) - 24)
        var bass_env := pow(1.0 - beat_phase, 2.0)
        var bass := (sin(TAU * bass_hz * t) + 0.24 * sin(TAU * bass_hz * 2.0 * t))
        bass *= bass_env * 0.13

        # Chord stabs on the upbeats keep the accompaniment moving.
        var chord := 0.0
        if step % 2 == 1:
            var triad: Array = chord_hz[bar_id]
            for chord_tone in triad:
                var hz: float = float(chord_tone)
                chord += sin(TAU * hz * t) * 0.012 * env

        # Four-on-the-floor kick, 2/4 snare and eighth-note hi-hats.
        # Deterministic integer noise avoids RNG state or sample downloads.
        var noise := float(((i * 1103515245 + 12345) & 32767)) / 16384.0 - 1.0
        var kick := 0.0
        if beat_phase < 0.46:
            var pitch := 95.0 - 55.0 * minf(1.0, beat_phase * 3.0)
            kick = sin(TAU * pitch * beat_age) * exp(-13.0 * beat_age) * 0.19
        var snare := 0.0
        if beat % 4 == 1 or beat % 4 == 3:
            snare = noise * exp(-22.0 * beat_age) * 0.105
        var hat := noise * exp(-50.0 * eighth_phase * eighth_length) * 0.039

        # A near-silent seam at the exact loop boundary prevents pops.
        var seam := minf(1.0, t / 0.009)
        seam = minf(seam, (total_seconds - t) / 0.009)
        var sample := (lead + bass + chord + kick + snare + hat) * clampf(seam, 0.0, 1.0)
        pcm.encode_s16(i * 2, int(clampf(sample, -0.91, 0.91) * 32767.0))
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
    music_player.volume_db = linear_to_db(maxf(music * 0.45, 0.0001))
    music_player.stream_paused = music <= 0.001
    for voice in voices:
        voice.volume_db = linear_to_db(maxf(sfx * 0.65, 0.0001))
        # A not-yet-playing AudioStreamPlayer does not preserve stream_paused.
        # Actual mute is gain -80 dB plus play_sfx() skipping all new events.

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
