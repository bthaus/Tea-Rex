extends Button

var _map_name: String
var unlocked: bool = true #testing

func set_level(map_name: String):
	_map_name = map_name
	text = map_name
	#TODO: Set stars, name etc.
	#var account_dto = Global.get_account()
	#var progress_dto = account_dto.get_map_progress_dto_by_name(map_name)
	#unlocked = progress_dto.unlocked
	#$map_preview/stars.text=str(progress_dto.stars_unlocked)
	#$map_preview.text=map_name

func _on_pressed():
	var picker = SceneHandler.get_scene_instance(SceneHandler.Scene.BATTLE_SLOT_PICKER)
	picker.map_name = _map_name
	SceneHandler.change_scene(picker)
