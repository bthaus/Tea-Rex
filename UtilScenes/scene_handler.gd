extends Node

enum Scene {MAIN_MENU, ACCOUNTS, CHAPTER_SELECTION, LEVEL_SELECTION, BATTLE_SLOT_PICKER, MAIN_SCENE, WIN_SCREEN, LEVEL_EDITOR_MENU, LEVEL_EDITOR,  CHAPTER_EDITOR}

func get_scene_path(scene: Scene) -> String:
	match(scene):
		Scene.MAIN_MENU: return "res://menu_scenes/MainMenu/main_menu.tscn"
		Scene.ACCOUNTS: return "res://menu_scenes/AccountSelection/account_selection.tscn"
		Scene.CHAPTER_SELECTION: return "res://menu_scenes/ChapterSelection/chapter_selection.tscn"
		Scene.LEVEL_SELECTION: return "res://menu_scenes/LevelSelection/level_selection.tscn"
		Scene.BATTLE_SLOT_PICKER: return "res://menu_scenes/battle_slot_picker_scenes/battle_slot_picker.tscn"
		Scene.MAIN_SCENE: return "res://Game/main_scene.tscn"
		Scene.WIN_SCREEN: return "res://menu_scenes/win_screen_scenes/win_scene.tscn"
		Scene.LEVEL_EDITOR_MENU: return "res://menu_scenes/LevelEditor/Menu/level_editor_menu.tscn"
		Scene.LEVEL_EDITOR: return "res://menu_scenes/LevelEditor/level_editor.tscn"
		Scene.CHAPTER_EDITOR: return "res://menu_scenes/chapter_editor_scenes/chapter_editor.tscn"
	
	return ""

var current_scene = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count()-1)
	
func get_scene_instance(scene: Scene):
	var scene_path = get_scene_path(scene)
	return load(scene_path).instantiate()
	
func change_scene(scene): #Use together with get_scene_instance
	current_scene.queue_free()
	current_scene = scene
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
