extends Node
class_name OpenCloseScaleAnimation

@export var time: float = 0.4
@export var opening_transition_type: Tween.TransitionType = Tween.TRANS_BACK
@export var closing_transition_type: Tween.TransitionType = Tween.TRANS_BACK
	
var target: Control
var default_scale: Vector2

func _ready():
	target = get_parent()
	call_deferred("_setup")
	
func open():
	target.scale = Vector2(0, 0)
	target.show()
	_add_tween("scale", Vector2(1, 1), time, opening_transition_type, Tween.EASE_OUT)

func close():
	var tween = _add_tween("scale", Vector2(0, 0), time, closing_transition_type, Tween.EASE_IN)
	tween.tween_callback(func(): target.hide())

func _setup():
	#Take center of target
	target.pivot_offset = target.size / 2
	default_scale = target.scale

func _add_tween(property: String, value, seconds: float, transition_type: Tween.TransitionType, ease_tye: Tween.EaseType) -> Tween:
	var tween = get_tree().create_tween()
	tween.tween_property(target, property, value, seconds).set_trans(transition_type).set_ease(ease_tye)
	return tween
