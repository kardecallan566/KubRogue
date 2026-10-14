extends SceneTree
## Mirrors opening the C5 hub and clicking JOGAR immediately after "godot ."
## on a clean checkout, BEFORE Godot editor imports PNGs or writes .godot/.
const Game = preload("res://scripts/c5/game_stage.gd")
const Store = preload("res://scripts/c4/save_store.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_test_cold_game")

func check(condition: bool, note: String) -> void:
    if not condition:
        failures += 1
        push_error("C5 COLD FAIL: " + note)

func _test_cold_game() -> void:
    var path := "user://c5_cold_start_sandbox.json"
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
    get_root().get_node("KubeSession").configure(Store.new(path))
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.hand != null, "game creates the C5 cursor on a clean startup")
    if game.hand != null:
        var idle: Texture2D = game.hand.get_active_texture()
        check(idle != null and idle.get_width() == 128, "raw open PNG decodes without import")
        game.hand.set_gripping(true)
        var grip: Texture2D = game.hand.get_active_texture()
        check(grip != null and grip.get_width() == 128, "raw grip PNG decodes without import")
        check(grip != idle, "open and grip use different image textures")
        game.hand.set_gripping(false)
        check(game.hand.get_active_texture() == idle, "releasing returns to open sprite")
    check(game.hud_panel != null and game.card_widgets.size() == 3,
        "actual C5 HUD and new skill card layout are loaded, not C4")
    check(game.director != null and game.director.waves.size() == 5,
        "five-wave game state initializes")
    game.queue_free()
    await process_frame
    for suffix in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
    print("KubRogue C5 first-run cold-start test: %d failures" % failures)
    quit(0 if failures == 0 else 1)
