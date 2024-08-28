extends Panel
class_name ItemPermutator

@onready var grid_container = $ScrollContainer/GridContainer

var focused_item
var selected_item
var selected_object

func _ready():
	for item in grid_container.get_children():
		item.queue_free()
	
	var textures = [load("res://Assets/Monsters/Monster_BLUE.png"), load("res://Assets/Monsters/Monster_GREEN.png"), load("res://Assets/Monsters/Monster_RED.png"), load("res://Assets/Monsters/Monster_YELLOW.png")]
	set_sprite_objects([PermutationObject.new(1, textures[0]), PermutationObject.new(2, textures[1]), PermutationObject.new(3, textures[2]), PermutationObject.new(4, textures[3])])

func set_block_objects(objects: Array[PermutationObject]):
	pass#_set_objects()

func set_sprite_objects(objects: Array[PermutationObject]):
	_set_objects("res://menu_scenes/LevelEditor/Settings/ItemPermutator/item_permutator_sprite_item.tscn", objects)

func _set_objects(path, objects: Array[PermutationObject]):
	for item in grid_container.get_children():
		item.queue_free()
	
	var idx = 0
	for object in objects:
		var item = load(path).instantiate()
		item.mouse_entered.connect(func(): focused_item = item)
		item.mouse_exited.connect(func(): focused_item = null)
		item.index = idx
		item.set_object(object)
		grid_container.add_child(item)
		idx += 1

func get_objects() -> Array[PermutationObject]:
	var items = grid_container.get_children()
	var objects: Array[PermutationObject] = []
	for item in grid_container.get_children():
		objects.append(item.get_object())
	#objects.sort_custom(func(a, b): return a.index < b.index)
	return objects

func _input(event):
	if focused_item == null and selected_item == null:
		return
	
	$SelectedNode.position = get_local_mouse_position() + Vector2(10, 10)
	
	if InputUtils.is_action_just_pressed(event, "left_click"):
		if selected_item == null:
			selected_item = focused_item

			for child in $SelectedNode.get_children(): child.queue_free()
			$SelectedNode.add_child(selected_item.duplicate())
			
			selected_item.hide_object()
		else:
			_deselect_items()
	
	if selected_item != null:
		#We hovered over a new item
		if focused_item != null and selected_item != focused_item:
			_move_items()
			selected_item = focused_item
			selected_item.hide_object()

func _move_items():
	var move_items_left = focused_item.index > selected_item.index
	var items = grid_container.get_children()
	#items.sort_custom(func(a, b): return a.index < b.index)
	
	var object = selected_item.get_object() #Store object before overriding
	if move_items_left: #Move items to the left
		for i in range(selected_item.index, focused_item.index):
			items[i].set_object(items[i+1].get_object())
	else: #Move items to the right
		for i in range(selected_item.index, focused_item.index, -1):
			items[i].set_object(items[i-1].get_object())
	
	focused_item.set_object(object)

func _on_mouse_exited():
	_deselect_items()

func _deselect_items():
	for item in grid_container.get_children():
		item.show_object()
	selected_item = null
	for child in $SelectedNode.get_children(): child.queue_free()

class PermutationObject:
	var value #Any value that will be assigned to this object
	var node #Any node that might be used for display
	func _init(value, node):
		self.value = value
		self.node = node


