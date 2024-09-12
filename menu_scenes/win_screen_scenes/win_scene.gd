extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_up(game_state):
	var account=Global.get_account()
	var progress=account.get_map_progress_dto_by_name(game_state.map_dto.map_name)
	progress.stars_unlocked=3
	account.save()

func _on_continue_pressed():
	SceneHandler.change_scene(SceneHandler.get_scene_instance(SceneHandler.Scene.LEVEL_SELECTION))
