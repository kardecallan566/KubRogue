extends "res://scripts/c14/game_stage.gd"
## Keep all of the C12 combat, C14 medals, and C6 rewards/XP unchanged.

func _return_hub() -> void:
    if not pending_credits.is_empty():
        message_label.text = "Existem pagamentos pendentes. Use Tentar salvar."
        return
    progress.update_record(director.wave_index+1,director.wallet.solved,best_combo_in_run)
    _record_challenge_if_needed()
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    get_tree().change_scene_to_file("res://scenes/c15/hub_stage.tscn")
