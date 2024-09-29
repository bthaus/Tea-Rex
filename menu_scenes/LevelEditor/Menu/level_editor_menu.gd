extends Node2D

@onready var level_container = $LevelScrollContainer/LevelVBoxContainer
@onready var level_name = $NewLevel/LevelName
@onready var new_level = $NewLevel
@onready var new_level_animation = $NewLevel/OpenCloseScaleAnimation
@onready var delete_warning = $DeleteWarning
@onready var delete_warning_animation = $DeleteWarning/OpenCloseScaleAnimation
@onready var delete_warning_title = $DeleteWarning/Title

var selected_item
var chapters: MapChapterDTO

func _ready():
	new_level.hide()
	delete_warning.hide()
	for item in level_container.get_children():
		item.queue_free()
	
	chapters=MapChapterDTO.new()
	chapters.restore()
	
	for map_name in chapters.get_mapnames_from_chapter(GameplayConstants.CUSTOM_LEVELS_CHAPTER_NAME):
		var map_dto = MapDTO.new()
		map_dto.restore(map_name)
		var item = load("res://menu_scenes/LevelEditor/Menu/level_editor_menu_item.tscn").instantiate()
		item.set_map(map_dto)
		item.delete.connect(_on_item_delete)
		level_container.add_child(item)


func _on_item_delete(sender):
	selected_item = sender
	delete_warning_title.text = str("Delete \"", sender.map_dto.map_name, "\"?")
	delete_warning_animation.open()

func _on_new_level_button_pressed(): 
	new_level_animation.open()

func _on_create_button_pressed():
	var level_editor = SceneHandler.get_scene_instance(SceneHandler.Scene.LEVEL_EDITOR)
	level_editor.map_name = level_name.text
	SceneHandler.change_scene(level_editor)

func _on_cancel_button_pressed():
	new_level_animation.close(new_level.hide)

func _on_warning_delete_button_pressed():
	selected_item.map_dto.delete()
	level_container.remove_child(selected_item)
	selected_item.queue_free()
	delete_warning_animation.close(delete_warning.hide)


func _on_warning_cancel_button_pressed():
	delete_warning_animation.close(delete_warning.hide)
