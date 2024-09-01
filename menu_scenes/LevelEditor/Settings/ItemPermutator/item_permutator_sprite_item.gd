extends Panel

var _object: ItemPermutator.PermutationObject
var _parent: Control
signal input_enabled
signal duplicated

func set_object(object: ItemPermutator.PermutationObject):
	_object = object
	$Sprite2D.texture = object.node

func show_object():
	$Sprite2D.texture = _object.node

func hide_object():
	$Sprite2D.texture = null
	
func enable_focus(enable: bool):
	pass

func set_parent(parent: Control):
	_parent = parent

func get_object() -> ItemPermutator.PermutationObject:
	return _object
