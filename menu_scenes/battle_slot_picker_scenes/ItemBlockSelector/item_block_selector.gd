extends Panel

var item_handler: ItemBlockSelectorHandler
var selected_item: ItemBlockDTO
@onready var turret_mod_grid_container = $ScrollContainer/TurretModGridContainer

func _ready():
	item_handler = ItemBlockSelectorHandler.new($Board, [])

	for container in turret_mod_grid_container.get_children():
		var mods
		for mod_container in MainMenu.get_account_dto().turret_mod_containers:
			if mod_container.color == container.color:
				mods = mod_container.turret_mods
				break
		container.set_mods(mods)
		container.focused.connect(_on_container_focus_changed)
		container.placed.connect(_on_item_placed)
	
	$ItemBlockSelectorContainer.item_selected.connect(_on_item_selected)

func _on_container_focus_changed(container_focused: bool):
	$Board.clear_layer(ItemBlockConstants.BLOCK_LAYER)
	if not container_focused:
		item_handler.draw_item_block(selected_item, Vector2(0,0), ItemBlockConstants.BLOCK_LAYER)

func _on_item_selected(item_block: ItemBlockDTO):
	selected_item = item_block
	$Board.clear_layer(ItemBlockConstants.BLOCK_LAYER)
	item_handler.draw_item_block(selected_item, Vector2(0,0), ItemBlockConstants.BLOCK_LAYER)
	for container in turret_mod_grid_container.get_children():
		container.set_selected_item(item_block)

func _on_item_placed():
	$Board.clear_layer(ItemBlockConstants.BLOCK_LAYER)
	selected_item = null
	for container in turret_mod_grid_container.get_children():
		container.set_selected_item(null)

func _input(event):
	#$Board.clear_layer(ItemBlockConstants.PREVIEW_LAYER)
	#var board_pos = _get_mouse_position_on_board()
	#item_handler.draw_item_block(selected_item, Vector2(0,0), ItemBlockConstants.PREVIEW_LAYER)
	$Board.position = get_global_mouse_position()

func _get_mouse_position_on_board() -> Vector2:
	return $Board.local_to_map(get_global_mouse_position() / $Board.scale)
