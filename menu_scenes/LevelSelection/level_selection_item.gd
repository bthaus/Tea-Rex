extends Button

var _map_name: String
var unlocked: bool = true #testing

func set_level(map_name: String):
	_map_name = map_name
	text = map_name
	#TODO: Set stars, name etc.
	#var account_dto = MainMenu.get_account_dto()
	#var progress_dto = account_dto.get_map_progress_dto_by_name(map_name)
	#unlocked = progress_dto.unlocked
	#$map_preview/stars.text=str(progress_dto.stars_unlocked)
	#$map_preview.text=map_name

func _on_pressed():
	var picker = MainMenu.get_scene_instance(MainMenu.BATTLE_SLOT_PICKER_PATH)
	picker.map_name = _map_name
	MainMenu.change_content(picker)
