extends "res://scripts/c15/hub_stage.gd"
## C16 adds a practice doorway inside Jogar, keeping only four home actions.
func _open_game() -> void:
    _close_modal()
    get_tree().change_scene_to_file("res://scenes/c16/game_stage.tscn")

func _open_lab() -> void:
    _close_modal()
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    get_tree().change_scene_to_file("res://scenes/c16/lab_stage.tscn")

func _show_play_modes() -> void:
    super._show_play_modes()
    _set_modal_dimensions(814,456)
    var doorway := _button(dialog_box,
        "◈  LABORATÓRIO — TREINO LIVRE 2×2 A 5×5",_open_lab,440)
    doorway.name = "OpenLaboratory"
    doorway.custom_minimum_size.y = 43
    doorway.set_meta("arcade_variant","teal")
    var last: int = dialog_box.get_child_count() - 1
    dialog_box.move_child(doorway,maxi(0,last-1))
    VisualTheme.apply(dialog_center)

func _show_tutorial(start_after: bool) -> void:
    super._show_tutorial(start_after)
    var note := _label(dialog_box,
        "Se quiser praticar giros de camadas sem cronômetro, abra Jogar → Laboratório.",14)
    note.name = "LaboratoryHelp"
    if dialog_box.get_child_count() > 1:
        dialog_box.move_child(note,dialog_box.get_child_count()-2)
    VisualTheme.apply(dialog_center)
