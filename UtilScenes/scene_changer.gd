extends Node

const GAME_STATE_PATH = "res://Game/main_scene.tscn"
const CHAPTER_SELECTION_PATH = "res://menu_scenes/ChapterSelection/chapter_selection.tscn"
const LEVEL_SELECTION_PATH = "res://menu_scenes/LevelSelection/level_selection.tscn"
const BATTLE_SLOT_PICKER_PATH = "res://menu_scenes/battle_slot_picker_scenes/battle_slot_picker.tscn"
const ACCOUNTS_PATH = "res://menu_scenes/account_tab_scenes/accounts_tab.tscn"
const LEVEL_EDITOR_MENU_PATH = "res://menu_scenes/LevelEditor/Menu/level_editor_menu.tscn"
const LEVEL_EDITOR_PATH = "res://menu_scenes/LevelEditor/level_editor.tscn"
const WIN_SCREEN_PATH = "res://menu_scenes/win_screen_scenes/win_scene.tscn"
const CHAPTER_EDITOR_PATH = "res://menu_scenes/chapter_editor_scenes/chapter_editor.tscn"


var current_scene = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count()-1)
	
func get_scene_instance(scene_path: String):
	return load(scene_path).instantiate()
	
func change_scene(scene):
	current_scene.queue_free()
	current_scene = scene
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
