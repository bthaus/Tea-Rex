extends Node
class_name SceneNavigation

@export var navigate_to: SceneHandler.Scene
@export var transition_effect: SceneHandler.TransitionEffect

var target: Button

func _ready():
	target = get_parent()
	target.pressed.connect(_on_pressed)

func _on_pressed():
	SceneHandler.change_scene(SceneHandler.get_scene_instance(navigate_to), transition_effect)
