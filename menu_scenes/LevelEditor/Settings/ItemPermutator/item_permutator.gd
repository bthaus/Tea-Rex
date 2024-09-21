extends Panel
class_name ItemPermutator

@onready var grid_container = $ScrollContainer/GridContainer
@export var parent: Control

var focused_item
var selected_item
var selected_object
var input_enabled = true

func set_objects(scene_path, objects: Array[PermutationObject]):
	for item in grid_container.get_children(): item.queue_free()
	for obj in objects:
		append_object(scene_path, obj)
		
func append_object(scene_path, object: PermutationObject):
	var item = load(scene_path).instantiate()
	grid_container.add_child(item)
	item.mouse_entered.connect(func(): focused_item = item)
	item.mouse_exited.connect(func(): focused_item = null)
	item.input_enabled.connect(func(enabled: bool): input_enabled = enabled)
	item.duplicated.connect(_on_item_duplicated)
	item.set_parent(parent)
	item.set_object(object)
	return item

func insert_object_at(scene_path, object: PermutationObject, index: int):
	var item = append_object(scene_path, object)
	grid_container.move_child(item, index)


func _on_item_duplicated(sender):
	var items = grid_container.get_children()
	for i in items.size():
		if items[i] == sender:
			var object = sender.get_object().clone()
			insert_object_at(sender.scene_file_path, object, i+1)
			return

func get_objects() -> Array[PermutationObject]:
	var objects: Array[PermutationObject] = []
	for item in grid_container.get_children():
		objects.append(item.get_object())
	#objects.sort_custom(func(a, b): return a.index < b.index)
	return objects

func get_item_node(index: int):
	return grid_container.get_child(index)

func _input(event):
	if not input_enabled or (focused_item == null and selected_item == null):
		return
		
	$SelectedNode.position = get_local_mouse_position() - Vector2(20, 20)
	
	if InputUtils.is_action_just_pressed(event, "left_click"):
		if selected_item == null:
			selected_item = focused_item
			_set_selected_node()
			for item in grid_container.get_children(): item.enable_focus(false)
			selected_item.hide_object()
		else:
			_deselect_items()
	
	if selected_item != null:
		#We hovered over a new item
		if focused_item != null and selected_item != focused_item:
			_move_items()
			selected_item = focused_item
			selected_item.hide_object()

func _set_selected_node():
	for child in $SelectedNode.get_children(): child.queue_free()
	var held_item = selected_item.duplicate()
	held_item.scale = Vector2(0.75, 0.75)
	held_item.enable_focus(false)
	held_item.mouse_filter = MOUSE_FILTER_IGNORE #I HATE YOU FILTER, EAT SAND
	$SelectedNode.add_child(held_item)

func _move_items():
	var items = grid_container.get_children()
	var selected_item_index: int
	var focused_item_index: int
	for i in items.size():
		if items[i] == selected_item: selected_item_index = i
		if items[i] == focused_item: focused_item_index = i
		
	var move_items_left = focused_item_index > selected_item_index
	#items.sort_custom(func(a, b): return a.index < b.index)
	
	var object = selected_item.get_object() #Store object before overriding
	if move_items_left: #Move items to the left
		for i in range(selected_item_index, focused_item_index):
			items[i].set_object(items[i+1].get_object())
			items[i].show_object()
	else: #Move items to the right
		for i in range(selected_item_index, focused_item_index, -1):
			items[i].set_object(items[i-1].get_object())
			items[i].show_object()
	
	focused_item.set_object(object)
	focused_item.show_object()

func _on_mouse_exited():
	_deselect_items()

func _deselect_items():
	for item in grid_container.get_children():
		item.show_object()
	selected_item = null
	for child in $SelectedNode.get_children(): child.queue_free()
	for item in grid_container.get_children(): item.enable_focus(true)

class PermutationObject:
	func clone() -> PermutationObject:
		return null
