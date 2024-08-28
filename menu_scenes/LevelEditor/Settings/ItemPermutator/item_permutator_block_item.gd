extends Panel

var _object: ItemPermutator.PermutationObject
signal input_enabled

func set_object(object: ItemPermutator.PermutationObject):
	_object = object
	$Content/BlockPreview.set_block(object.value, false)

func show_object():
	$Content.visible = true

func hide_object():
	$Content.visible = false

func get_object() -> ItemPermutator.PermutationObject:
	return _object

func open_editor():
	input_enabled.emit(false)
	var editor = load("res://menu_scenes/LevelEditor/Settings/block_editor.tscn").instantiate()
	editor.set_block(_object.value)
	editor.closed.connect(_on_editor_closed)
	editor.position = Vector2(200, 200)
	get_tree().root.add_child(editor)
	
func _on_editor_closed(block: Block):
	_object.value = block
	set_object(_object)
	input_enabled.emit(true)

func _on_edit_button_pressed():
	open_editor()

func _on_delete_button_pressed():
	queue_free()
