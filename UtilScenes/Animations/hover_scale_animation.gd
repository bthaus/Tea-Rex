extends Node
class_name HoverScaleAnimation

@export var hover_scale: Vector2 = Vector2(1.2, 1.2)
@export var time: float = 0.2
@export var transition_type: Tween.TransitionType = Tween.TRANS_LINEAR
	
var target: Control
var default_scale: Vector2


func _ready():
	target = get_parent()
	target.mouse_entered.connect(_on_mouse_entered)
	target.mouse_exited.connect(_on_mouse_exited)
	call_deferred("_setup")

func _setup():
	#Take center of target
	target.pivot_offset = target.size / 2
	default_scale = target.scale

func _on_mouse_entered():
	_add_tween("scale", hover_scale, time)

func _on_mouse_exited():
	_add_tween("scale", default_scale, time)

func _add_tween(property: String, value, seconds: float):
	var tween = get_tree().create_tween()
	Tween.EASE_IN
	tween.tween_property(target, property, value, seconds).set_trans(transition_type)
