extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_up(game_state):
	var account=MainMenu.get_account_dto()
	var progress=account.get_map_progress_dto_by_name(game_state.map_dto.map_name)
	progress.stars_unlocked=3
	account.save()

func _on_continue_pressed():
	MainMenu.change_content(MainMenu.get_scene_instance(MainMenu.LEVEL_SELECTION_PATH))

