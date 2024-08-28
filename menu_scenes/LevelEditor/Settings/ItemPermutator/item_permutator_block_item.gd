extends Panel

var _object: ItemPermutator.PermutationObject

func set_object(object: ItemPermutator.PermutationObject):
	_object = object
	$Content/BlockPreview.set_block(object.value, false)

func show_object():
	$Content.visible = true

func hide_object():
	$Content.visible = false

func get_object() -> ItemPermutator.PermutationObject:
	return _object


func _on_edit_button_pressed():
	pass # Replace with function body.


func _on_delete_button_pressed():
	queue_free()
