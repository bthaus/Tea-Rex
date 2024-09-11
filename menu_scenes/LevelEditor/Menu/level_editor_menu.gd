extends Node2D

@onready var level_container = $LevelScrollContainer/LevelVBoxContainer
@onready var level_name = $NewLevel/LevelName


func _ready():
	$NewLevel.hide()
	for item in level_container.get_children():
		item.queue_free()
	
	var chapters=MapChapterDTO.new()
	chapters.restore()
	
	for chapter in chapters.chapter_dictionary.keys():
		for map_name in chapters.get_mapnames_from_chapter(chapter):
			var map_dto = MapDTO.new()
			map_dto.restore(map_name)
			var item = load("res://menu_scenes/LevelEditor/Menu/level_editor_menu_item.tscn").instantiate()
			item.set_map(map_dto)
			level_container.add_child(item)


func _on_new_level_button_pressed(): 
	$NewLevel.show()

func _on_create_button_pressed():
	var level_editor = SceneChanger.get_scene_instance(SceneChanger.LEVEL_EDITOR_PATH)
	level_editor.map_name = level_name.text
	SceneChanger.change_scene(level_editor)

func _on_cancel_button_pressed():
	$NewLevel.hide()
