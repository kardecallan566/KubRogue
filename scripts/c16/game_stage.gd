extends "res://scripts/c15/game_stage.gd"
## Keep the entire weekly C15 run unchanged, only return to the new hub.
func _return_hub() -> void:
    if not pending_credits.is_empty():
        message_label.text = "Existem pagamentos pendentes. Use Tentar salvar."
        return
    progress.update_record(director.wave_index+1,director.wallet.solved,best_combo_in_run)
    _record_challenge_if_needed()
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    get_tree().change_scene_to_file("res://scenes/c16/hub_stage.tscn")
