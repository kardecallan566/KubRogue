extends "res://scripts/visual/cube_3x3.gd"
class_name KubRogueCube2x2
## C1: exactly eight independent corner cubies and 24 physical stickers.
## One shared bevelled cubie mesh and one shared sticker mesh from Kubos.
## The rendering/animation pipeline is inherited from the C0-tested 3x3.
const PocketState = preload("res://scripts/puzzle/cube_state_2x2.gd")

func _new_puzzle():
    return PocketState.new()
