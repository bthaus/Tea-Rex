extends Panel

var _object: ItemPermutator.PermutationObject
var index: int

func set_object(object: ItemPermutator.PermutationObject):
	_object = object
	$Sprite2D.texture = object.texture

func clear_object():
	_object = null
	$Sprite2D.texture = null

func get_object():
	return _object
