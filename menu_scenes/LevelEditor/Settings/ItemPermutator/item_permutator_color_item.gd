extends Panel
class_name ItemPermutatorColorItem

var _object: ColorPermutationObject
var _parent: Control
signal input_enabled
signal duplicated

func set_object(object: ColorPermutationObject):
	_object = object
	$Sprite2D.texture = object.texture

func show_object():
	$Sprite2D.texture = _object.texture

func hide_object():
	$Sprite2D.texture = null
	
func enable_focus(enable: bool):
	pass

func set_parent(parent: Control):
	_parent = parent

func get_object() -> ColorPermutationObject:
	return _object

class ColorPermutationObject extends ItemPermutator.PermutationObject:
	var color: Turret.Hue
	var texture: Texture2D
	func _init(color, texture: Texture2D):
		self.color = color
		self.texture = texture
