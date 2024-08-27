extends Panel
class_name ItemPermutator

var last_focused_item
var focused_item
var selected_item
var selected_object

func _ready():
	
	for item in $HBoxContainer.get_children():
		item.queue_free()
	
	var textures = [load("res://Assets/Monsters/Monster_BLUE.png"), load("res://Assets/Monsters/Monster_GREEN.png"), load("res://Assets/Monsters/Monster_RED.png"), load("res://Assets/Monsters/Monster_YELLOW.png")]
	for i in 4:
		var item = load("res://menu_scenes/LevelEditor/Settings/ItemPermutator/item_permutator_item.tscn").instantiate()
		item.mouse_entered.connect(func(): focused_item = item)
		item.mouse_exited.connect(func(): focused_item = null)
		item.index = i
		item.set_object(PermutationObject.new(null, textures[i]))
		$HBoxContainer.add_child(item)

func _input(event):
	if focused_item == null and selected_item == null:
		return
		
	if InputUtils.is_action_just_pressed(event, "left_click"):
		if selected_item == null:
			selected_item = focused_item
			selected_object = selected_item.get_object()
		else:
			selected_item.set_object(selected_object)
			selected_item = null
	
	if selected_item != null:
		#We hovered over a new item
		if focused_item != null and last_focused_item != focused_item:
			_move_items()
			last_focused_item = focused_item
			selected_item = focused_item
			selected_item.clear_object()

func _move_items():
	var move_items_left = focused_item.index > selected_item.index
	var items = $HBoxContainer.get_children()
	#items.sort_custom(func(a, b): return a.index < b.index)
	
	if move_items_left: #Move items to the left
		for i in range(selected_item.index, focused_item.index):
			items[i].set_object(items[i+1].get_object())
	else: #Move items to the right
		for i in range(selected_item.index, focused_item.index, -1):
			items[i].set_object(items[i-1].get_object())
			

class PermutationObject:
	var object
	var texture: Texture2D
	func _init(object, texture: Texture2D):
		self.object = object
		self.texture = texture
