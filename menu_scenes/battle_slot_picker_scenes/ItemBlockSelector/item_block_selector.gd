extends Panel

var item_handler: ItemBlockSelectorHandler
var selected_item: ItemBlockDTO
@onready var turret_mod_grid_container = $ScrollContainer/TurretModGridContainer

func _ready():
	item_handler = ItemBlockSelectorHandler.new($Board, [])
		
	for container in turret_mod_grid_container.get_children():
		container.focused.connect(on_container_focus_changed)

func on_container_focus_changed(container_focused: bool):
	if container_focused:
		$Board.clear_layer(ItemBlockConstants.BLOCK_LAYER)
	else:
		item_handler.draw_item_block(selected_item, Vector2(0,0), ItemBlockConstants.BLOCK_LAYER)

func on_item_selected(item_block: ItemBlockDTO):
	selected_item = item_block
	item_handler.draw_item_block(selected_item, Vector2(0,0), ItemBlockConstants.BLOCK_LAYER)
	for container in turret_mod_grid_container.get_children():
		container.set_selected_item(item_block)

func _input(event):
	#$Board.clear_layer(ItemBlockConstants.PREVIEW_LAYER)
	#var board_pos = _get_mouse_position_on_board()
	#item_handler.draw_item_block(selected_item, Vector2(0,0), ItemBlockConstants.PREVIEW_LAYER)
	$Board.position = get_global_mouse_position()

func _get_mouse_position_on_board() -> Vector2:
	return $Board.local_to_map(get_global_mouse_position() / $Board.scale)
