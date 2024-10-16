extends Node

enum Scene { 
	MAIN_MENU,
	ACCOUNTS,
	CHAPTER_SELECTION,
	LEVEL_SELECTION,
	BATTLE_SLOT_PICKER,
	MAIN_SCENE,
	WIN_SCREEN,
	LEVEL_EDITOR_MENU,
	LEVEL_EDITOR,
	CHAPTER_EDITOR,
	LEVEL_BROWSER_MENU,
	LEVEL_BROWSER,
	WEB_LEVEL_PREVIEW
	}

enum TransitionEffect { NONE, SWIPE_LEFT, SWIPE_RIGHT }

var transition_effect_interval = 0.65
var is_transitioning = false

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
		Scene.LEVEL_BROWSER_MENU: return "res://menu_scenes/LevelBrowser/Menu/level_browser_menu.tscn"
		Scene.LEVEL_BROWSER: return "res://menu_scenes/LevelBrowser/level_browser.tscn"
		Scene.WEB_LEVEL_PREVIEW: return "res://menu_scenes/LevelBrowser/WebLevel/web_level_preview.tscn"
		
	return ""

var current_scene = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count()-1)
	
func get_scene_instance(scene: Scene):
	var scene_path = get_scene_path(scene)
	return load(scene_path).instantiate()
	
func change_scene(scene, effect: TransitionEffect = TransitionEffect.NONE, callback: Callable = func(): pass): #Use together with get_scene_instance
	call_deferred("_change_scene", scene, effect, callback)

func _change_scene(scene, effect: TransitionEffect = TransitionEffect.NONE, callback: Callable = func(): pass): #Callback will be called once the new scene is ready
	if is_transitioning: return
	is_transitioning = true
	get_tree().root.add_child(scene)
	if not scene.is_node_ready(): await scene.ready()
	callback.call()
	
	match(effect):
		TransitionEffect.NONE:
			_switch_scene(current_scene, scene)
		TransitionEffect.SWIPE_LEFT:
			var width = get_viewport().size.x
			scene.position.x = width
			var tween = get_tree().create_tween()
			tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_property(scene, "position:x", 0, transition_effect_interval)
			tween.parallel().tween_property(current_scene, "position:x", -width, transition_effect_interval)
			tween.tween_callback(func(): _switch_scene(current_scene, scene))
		TransitionEffect.SWIPE_RIGHT:
			var width = get_viewport().size.x
			scene.position.x = -width
			var tween = get_tree().create_tween()
			tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_property(scene, "position:x", 0, transition_effect_interval)
			tween.parallel().tween_property(current_scene, "position:x", width, transition_effect_interval)
			tween.tween_callback(func(): _switch_scene(current_scene, scene))

func _switch_scene(old_scene, new_scene):
	current_scene.queue_free()
	current_scene = new_scene
	get_tree().current_scene = current_scene
	is_transitioning = false
