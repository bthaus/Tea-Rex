extends Node2D

@onready var level_container = $LevelScrollContainer/LevelVBoxContainer


func _ready():
	for item in level_container.get_children():
		item.queue_free()
	
	var chapters=MapChapterDTO.new()
	chapters.restore()
	
	for chapter in chapters.chapter_dictionary.keys():
		for name in chapters.get_mapnames_from_chapter(chapter):
			var item = load("res://menu_scenes/LevelEditor/Menu/level_editor_menu_item.tscn").instantiate()
			item.set_map(name)
			level_container.add_child(item)


func _on_new_level_button_pressed(): 
	MainMenu.change_content(MainMenu.level_editor)
