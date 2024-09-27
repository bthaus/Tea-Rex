extends Node2D

@onready var map_preview: Node2D = $Panel/SubViewportContainer/SubViewport/MapPreview

var _level

func set_level(level):
	self._level = level
	map_preview.set_map(level["map_dto"])

func _on_play_button_pressed() -> void:
	var picker = SceneHandler.get_scene_instance(SceneHandler.Scene.BATTLE_SLOT_PICKER)
	picker.map_dto = _level["map_dto"]
	SceneHandler.change_scene(picker)
