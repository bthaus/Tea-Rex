extends Panel

var item_handler: ItemBlockSelectorHandler
var selected_item: ItemBlockDTO
var has_focus = true
@onready var turret_mod_grid_container = $ScrollContainer/TurretModGridContainer

func _ready():
	item_handler = ItemBlockSelectorHandler.new($Board, [])

	for container in turret_mod_grid_container.get_children():
		container.focused.connect(_on_container_focus_changed)
		container.placed.connect(_on_item_placed)
		container.picked_up.connect(_on_item_picked_up)
	
	$ItemBlockSelectorContainer.item_selected.connect(_on_item_selected)

func _on_container_focus_changed(container_focused: bool):
	$Board.clear_layer(ItemBlockConstants.BLOCK_LAYER)
	if not container_focused:
		item_handler.draw_item_block(selected_item, Vector2(0,0), ItemBlockConstants.BLOCK_LAYER)
	
	has_focus = not container_focused

func _on_item_selected(item_block: ItemBlockDTO):
	selected_item = item_block
	_draw_item_block_hand(selected_item)
	for container in turret_mod_grid_container.get_children():
		container.set_selected_item(item_block)

func _on_item_placed():
	$Board.clear_layer(ItemBlockConstants.BLOCK_LAYER)
	selected_item = null
	for container in turret_mod_grid_container.get_children():
		container.set_selected_item(null)

func _on_item_picked_up(item_block: ItemBlockDTO):
	selected_item = item_block
	for container in turret_mod_grid_container.get_children():
		container.set_selected_item(item_block)


func _input(event):
	if event.is_action_released("right_click"):
		item_handler.rotate_item(selected_item)
		if has_focus:
			_draw_item_block_hand(selected_item)
		
	#$Board.clear_layer(ItemBlockConstants.PREVIEW_LAYER)
	#var board_pos = _get_mouse_position_on_board()
	#item_handler.draw_item_block(selected_item, Vector2(0,0), ItemBlockConstants.PREVIEW_LAYER)
	$Board.position = get_global_mouse_position()

func _draw_item_block_hand(item_block: ItemBlockDTO):
	$Board.clear_layer(ItemBlockConstants.BLOCK_LAYER)
	item_handler.draw_item_block(item_block, Vector2(0,0), ItemBlockConstants.BLOCK_LAYER)

func _get_mouse_position_on_board() -> Vector2:
	return $Board.local_to_map(get_global_mouse_position() / $Board.scale)
