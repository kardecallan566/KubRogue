extends "res://scripts/c12/game_stage.gd"
## C14: medal notifications are only derived from persisted C4/C8 data.
const MedalRules = preload("res://scripts/c14/medal_service.gd")
var garden_medals: MedalRules = MedalRules.new()
var medal_notice: Label
var medal_notice_time := 0.0

func _ready() -> void:
    super._ready()
    var content := hud_panel.get_child(0) as VBoxContainer
    medal_notice = Label.new()
    medal_notice.name = "GardenMedalToast"
    medal_notice.text = ""
    medal_notice.visible = false
    medal_notice.autowrap_mode = TextServer.AUTOWRAP_WORD
    medal_notice.add_theme_font_size_override("font_size",13)
    medal_notice.add_theme_color_override("font_color",Color("#a86a22"))
    content.add_child(medal_notice)
    # A journal_changed emission means its atomic local write succeeded.
    journal.journal_changed.connect(_check_new_medals)

func restart_run() -> void:
    super.restart_run()
    if garden_medals != null and journal != null and progress != null:
        garden_medals.snapshot(journal,progress,best_combo_in_run)
    if medal_notice != null:
        medal_notice.visible = false
    medal_notice_time = 0.0

func _check_new_medals() -> void:
    if garden_medals == null or journal == null or progress == null:
        return
    var gained: Array[Dictionary] = garden_medals.newly_unlocked(
        journal,progress,best_combo_in_run)
    if gained.is_empty() or medal_notice == null:
        return
    var first: Dictionary = gained[0]
    medal_notice.text = "✦ NOVA CONQUISTA: %s%s" % [
        String(first["name"]),
        " (+%d OUTRAS)" % (gained.size()-1) if gained.size()>1 else ""]
    medal_notice.visible = true
    medal_notice_time = 4.0
    _sound("level")

func _process(delta: float) -> void:
    super._process(delta)
    if medal_notice_time > 0.0:
        medal_notice_time = maxf(0.0,medal_notice_time-delta)
        if medal_notice_time <= 0.0 and medal_notice != null:
            medal_notice.visible = false

func _return_hub() -> void:
    if not pending_credits.is_empty():
        message_label.text = "Existem pagamentos pendentes. Use Tentar salvar."
        return
    progress.update_record(director.wave_index+1,director.wallet.solved,best_combo_in_run)
    _record_challenge_if_needed()
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    get_tree().change_scene_to_file("res://scenes/c14/hub_stage.tscn")
