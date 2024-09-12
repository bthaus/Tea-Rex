extends GameObject2D
class_name BattleSlotPicker
var map_name
var map

@onready var camera = $Panel/SubViewportContainer/SubViewport/Camera2D
@onready var map_preview = $Panel/SubViewportContainer/SubViewport/MapPreview


# Called when the node enters the scene tree for the first time.
func _ready():
	var map_dto=MapDTO.new()
	map_dto.restore(map_name)
	map=map_dto
	
	$BlockSelector.set_map(map)
	camera.max_zoom_in = 2
	camera.max_zoom_out = 0.2
	map_preview.set_map(map)

func enable_sandbox_mode():
	$BlockSelector.enable_sandbox_mode()

func _on_start_button_pressed():
	var gamestate = SceneHandler.get_scene_instance(SceneHandler.Scene.MAIN_SCENE)
	gamestate.map_dto = map
	gamestate.register_battle_slot_containers($BlockSelector.selected_containers)
	SceneHandler.change_scene(gamestate)


func _on_back_button_pressed():
	var scene = SceneHandler.Scene.LEVEL_EDITOR_MENU if Global.is_playing_custom_level else SceneHandler.Scene.LEVEL_SELECTION
	SceneHandler.change_scene(SceneHandler.get_scene_instance(scene))
