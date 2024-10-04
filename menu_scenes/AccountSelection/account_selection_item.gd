extends Button

var _account_dto: AccountInfoDTO

func set_account(account_dto: AccountInfoDTO):
	_account_dto = account_dto
	$Name.text = account_dto.account_name


func _on_pressed():
	Global.set_account(_account_dto)
	SceneHandler.change_scene(SceneHandler.get_scene_instance(SceneHandler.Scene.CHAPTER_SELECTION), SceneHandler.TransitionEffect.SWIPE_LEFT)
