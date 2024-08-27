extends Panel

var _object: ItemPermutator.PermutationObject
var index: int

func set_object(object: ItemPermutator.PermutationObject):
	_object = object
	$Sprite2D.texture = object.texture

func show_object():
	$Sprite2D.texture = _object.texture

func hide_object():
	$Sprite2D.texture = null

func get_object() -> ItemPermutator.PermutationObject:
	return _object
