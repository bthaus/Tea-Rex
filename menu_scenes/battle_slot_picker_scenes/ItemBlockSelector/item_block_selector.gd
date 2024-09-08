extends Node2D

var map: MapDTO
var item_handler: ItemBlockSelectorHandler
var selected_item: ItemBlockDTO
var item_origin: ItemOrigin
var focused_container
var selected_containers: Array[TurretModContainerDTO] = []
var _sandbox_mode = false

var preview

func _ready():
	item_handler = ItemBlockSelectorHandler.new($Board, [])

	for container in $TurretModGridContainer.get_children():
		container.focused.connect(_on_container_focus_changed)
		container.placed.connect(_on_item_placed)
		container.picked_up.connect(_on_item_picked_up)
		container.selected.connect(_on_container_selected)
	
	$ItemBlockSelectorContainer.item_selected.connect(_on_item_selected)

func enable_sandbox_mode():
	_sandbox_mode = true
	for container in $TurretModGridContainer.get_children():
		container.clear_mods()
	
	$ItemBlockSelectorContainer.enable_sandbox_mode()

func set_map(map: MapDTO):
	self.map = map
	_update_battle_slot_amount_label()

func _on_container_focus_changed(sender):
	$Board.clear_layer(ItemBlockConstants.MapLayer.BLOCK_LAYER)
	if sender == null:
		item_handler.draw_item_block(selected_item, Vector2(0,0), ItemBlockConstants.MapLayer.BLOCK_LAYER)
	
	focused_container = sender

func _set_selected_item(item_block: ItemBlockDTO):
	selected_item = item_block
	for container in $TurretModGridContainer.get_children():
		container.set_selected_item(item_block)

func _on_container_selected(sender, selected: bool):
	if selected:
		if selected_containers.size() < map.battle_slots.amount:
			sender.set_selected_state(true)
			selected_containers.append(sender.container)
		else:
			sender.set_selected_state(false)
	else:
		sender.set_selected_state(false)
		for i in selected_containers.size():
			if selected_containers[i] == sender.container:
				selected_containers.remove_at(i)
				break

	_update_battle_slot_amount_label()

func _on_item_selected(item_block: ItemBlockDTO):
	if selected_item != null: #We have already an item in our hand
		#if item_origin != null: item_origin.restore_item_block() #The item was previously in a container, restore it
		
		pass
	_set_selected_item(item_block)
	_draw_item_block_hand(selected_item)
	item_origin = null

func _on_item_placed():
	$Board.clear_layer(ItemBlockConstants.MapLayer.BLOCK_LAYER)
	_set_selected_item(null)
	item_origin = null

func _on_item_picked_up(sender, map_position: Vector2, item_block: ItemBlockDTO):
	_set_selected_item(item_block)
	item_origin = ItemOrigin.new(sender, item_block.clone())

func _input(event):
	$Board.position = get_global_mouse_position()
	if selected_item == null: return
	
	if event.is_action_released("right_click"):
		item_handler.rotate_item(selected_item)
		if focused_container == null: #No container has currently the focus
			_draw_item_block_hand(selected_item)
			
	if event.is_action_released("interrupt"):
		if item_origin == null: #No origin yet, place mod back to selector TODO!
			pass
		else: #Restore item block in container
			item_origin.restore_item_block()
		
		_draw_item_block_hand(null)
		_set_selected_item(null)
		item_origin = null
	
func _draw_item_block_hand(item_block: ItemBlockDTO):
	$Board.clear_layer(ItemBlockConstants.MapLayer.BLOCK_LAYER)
	if item_block != null:
		item_handler.draw_item_block(item_block, Vector2(0,0), ItemBlockConstants.MapLayer.BLOCK_LAYER)

func _update_battle_slot_amount_label():
	$BattleSlotsAmountLabel.text = str("Slots selected: ", selected_containers.size(), "/", map.battle_slots.amount)

func _on_tree_entered():
	
	preview = load("res://menu_scenes/turret_preview/Turret_preview_scene.tscn").instantiate() as Simulation
	preview.map_name = "preview_map"
	#preview.auto_start = false
	#preview.scale = Vector2(0.5, 0.5)
	
	#preview.turret_position = Vector2(0, 2)
	$TurretPreview.add_child(preview)
	
func _on_tree_exited():
	util.erase(preview)

class ItemOrigin:
	var container
	var item_block: ItemBlockDTO
	func _init(container, item_block: ItemBlockDTO):
		self.container = container
		self.item_block = item_block
	
	func restore_item_block():
		container.place_item(item_block)
