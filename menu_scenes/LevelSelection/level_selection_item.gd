extends Button

var _map_dto: MapDTO
var unlocked: bool = true #testing

func set_map(map_dto: MapDTO):
	_map_dto = map_dto
	text = map_dto.map_name
	#TODO: Set stars, name etc.
	#var account_dto = Global.get_account()
	#var progress_dto = account_dto.get_map_progress_dto_by_name(map_name)
	#unlocked = progress_dto.unlocked
	#$map_preview/stars.text=str(progress_dto.stars_unlocked)
	#$map_preview.text=map_name

func _on_pressed():
	var picker = SceneHandler.get_scene_instance(SceneHandler.Scene.BATTLE_SLOT_PICKER)
	picker.map_dto = _map_dto
	SceneHandler.change_scene(picker, SceneHandler.TransitionEffect.SWIPE_RIGHT)
