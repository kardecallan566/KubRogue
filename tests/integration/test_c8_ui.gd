extends SceneTree
const Hub = preload("res://scripts/c8/hub_stage.gd")
const Game = preload("res://scripts/c8/game_stage.gd")
const Store = preload("res://scripts/c4/save_store.gd")
const SkillIcon = preload("res://scripts/c8/skill_icon.gd")
var errors := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, message: String) -> void:
    if not ok:
        errors += 1
        push_error("C8 UI FAIL: " + message)

func _clean(p: String) -> void:
    for s in ["", ".bak", ".tmp"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(p + s))

func _run() -> void:
    var money := "user://c8_ui_wallet.json"
    var daily := "user://c8_ui_daily.json"
    var journal := "user://c8_ui_journal.json"
    for p in [money,daily,journal]:
        _clean(p)
    var progress = get_root().get_node("KubeSession")
    var challenge = get_root().get_node("KubeChallenge")
    var codex = get_root().get_node("KubeJournal")
    progress.configure(Store.new(money))
    challenge.configure(Store.new(daily))
    codex.configure(Store.new(journal))
    var hub: Hub = Hub.new()
    get_root().add_child(hub)
    var actions := hub.get_node("PrimaryActions") if hub.has_node("PrimaryActions") else hub.find_child("PrimaryActions",true,false)
    check(actions != null and actions.get_child_count() == 4, "four actions on starting screen")
    var headings: Array[String] = []
    if actions != null:
        for button in actions.get_children():
            headings.append(String(button.text))
    check(headings == ["JOGAR","BESTIÁRIO","CONFIGURAÇÕES","SAIR"],
        "no shop or daily mode clutter in main screen")
    hub._show_play_modes()
    check(hub.dialog_center.visible, "Jogar opens mode selector")
    var mode_buttons := hub.dialog_box.find_children("*","Button",true,false)
    check(mode_buttons.size() == 3, "mode selector has normal, daily and back")
    hub._show_settings()
    var has_help := false
    for button in hub.dialog_box.find_children("*","Button",true,false):
        has_help = has_help or String(button.text).contains("COMO JOGAR")
    check(has_help,"tutorial accessible from settings")
    hub._show_bestiary()
    check(hub.dialog_box.find_children("Species_*","PanelContainer",true,false).size()==7,
        "codex unchanged")
    hub.queue_free()
    await process_frame
    challenge.select_mode("normal")
    var game: Game = Game.new()
    get_root().add_child(game)
    check(game.skill_slots != null and game.skill_info_label != null,
        "HUD has active skill icon grid and detail line")
    check(game.card_widgets.size() == 3, "three C8 card choices")
    game.build.register_xp(5)
    game._show_cards()
    check(game.offers_open, "level-up still opens pause")
    var first = game.card_widgets[0]
    check(first.artwork is SkillIcon and first.artwork.skill_id == first.skill_id,
        "large choice card renders the correct original vector icon")
    check(first.description_label.text.length() > 0,
        "the familiar short skill description stays intact")
    game._choose_card(0)
    check(not game.offers_open and game.skill_slots.get_child_count() == 1,
        "one chosen skill appears as an icon")
    var badge = game.skill_slots.get_child(0)
    check(badge.skill_id == first.skill_id and badge.level == 1,
        "HUD badge matches actual selected level")
    check(badge.info_mark.text == "i" and badge.tooltip_text.contains(first.description_label.text),
        "badge has i marker and accessible description on hover")
    game._show_skill_details(first.skill_id)
    check(game.skill_info_label.text.contains(first.description_label.text),
        "clicking icon displays the exact description")
    game._show_skill_details(first.skill_id)
    check(not game.skill_info_label.text.contains(first.description_label.text),
        "clicking same icon hides details without clutter")
    game.restart_run()
    check(game.skill_slots.find_children("ActiveSkill_*","Button",true,false).is_empty(),
        "a new run resets the temporary upgrade icons")
    check(game.hand.get_active_texture() != null, "the approved mouse cursor still loads")
    game.queue_free()
    await process_frame
    for p in [money,daily,journal]:
        _clean(p)
    print("KubRogue C8 compact UI/icons test: %d failures" % errors)
    quit(0 if errors == 0 else 1)
