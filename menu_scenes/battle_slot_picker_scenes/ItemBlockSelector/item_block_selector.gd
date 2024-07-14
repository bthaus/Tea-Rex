extends Panel

var item_handler: ItemBlockSelectorHandler
var selected_item: ItemBlockDTO
@onready var item_block_container = $ItemBlockScrollContainer/ItemBlockGridContainer
@onready var turret_mod_grid_container = $ScrollContainer/TurretModGridContainer

func _ready():
	item_handler = ItemBlockSelectorHandler.new($Board, [])
	
	var item_blocks = [
		ItemBlockDTO.new(Turret.Hue.RED, Block.BlockShape.O, 0, ItemBlockConstants.RED_TILE_ID),
		ItemBlockDTO.new(Turret.Hue.BLUE, Block.BlockShape.O, 0, ItemBlockConstants.BLUE_TILE_ID),
		ItemBlockDTO.new(Turret.Hue.GREEN, Block.BlockShape.O, 0, ItemBlockConstants.GREEN_TILE_ID)
	]
	
	for item_block in item_blocks:
		var item = load("res://menu_scenes/battle_slot_picker_scenes/ItemBlockSelector/item_block_selector_item.tscn").instantiate()
		item_block_container.add_child(item)
		item.set_item_block(item_block)
		item.clicked.connect(on_item_selected)
		
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
