extends Panel

var item_handler: ItemBlockSelectorHandler
var selected_item: ItemBlockDTO
@onready var block_grid_container = $BlockScrollContainer/BlockGridContainer

func _ready():
	item_handler = ItemBlockSelectorHandler.new($Board, [])
	
	var item_blocks = [
		ItemBlockDTO.new(Stats.BlockShape.O, 0, ItemBlockConstants.RED_TILE_ID),
		ItemBlockDTO.new(Stats.BlockShape.O, 0, ItemBlockConstants.BLUE_TILE_ID),
		ItemBlockDTO.new(Stats.BlockShape.O, 0, ItemBlockConstants.GREEN_TILE_ID)
	]
	
	for item_block in item_blocks:
		var item = load("res://menu_scenes/battle_slot_picker_scenes/ItemBlockSelector/item_block_selector_item.tscn").instantiate()
		block_grid_container.add_child(item)
		item.set_item_block(item_block)
		item.clicked.connect(func(item_block): selected_item = item_block)
	
	
func _process(delta):
	$Board.clear_layer(ItemBlockConstants.SELECTION_LAYER)
	var board_pos = _get_mouse_position_on_board()
	item_handler.draw_item_block(selected_item, board_pos, ItemBlockConstants.SELECTION_LAYER)
	
	
func _unhandled_input(event):
	if event.is_action_released("left_click"):
		var board_pos = _get_mouse_position_on_board()
		item_handler.place_item_block(selected_item, board_pos)
		selected_item = null
	elif event.is_action_released("right_click"):
		item_handler.rotate_item(selected_item)

func _get_mouse_position_on_board() -> Vector2:
	return $Board.local_to_map(get_global_mouse_position() / $Board.scale)
