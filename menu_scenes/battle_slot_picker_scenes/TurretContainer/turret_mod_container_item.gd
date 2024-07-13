extends Panel

@export var color: Stats.TurretColor
@onready var style_box: StyleBoxFlat = get_theme_stylebox("panel").duplicate()

var item_handler: ItemBlockSelectorHandler
var selected_item: ItemBlockDTO
var is_focused = false
signal placed
signal focused

func _ready():
	item_handler = ItemBlockSelectorHandler.new($Board, [])
	style_box.set("border_color", _get_color_from_turret_color(color))
	add_theme_stylebox_override("panel", style_box)
	$Board.set_cell(ItemBlockConstants.BLOCK_LAYER, Vector2(0,1), ItemBlockConstants.BLUE_TILE_ID, Vector2(0, 0))
	

func _process(delta):
	$Board.clear_layer(ItemBlockConstants.PREVIEW_LAYER)
	var board_pos = _get_mouse_position_on_board()
	if is_focused:
		print(board_pos)
	if board_pos.x < 0 or board_pos.x > 3 or board_pos.y < 0 or board_pos.y > 3:
		if is_focused: focused.emit(false) #Focus now lost
		is_focused = false
		return
	
	if not is_focused: focused.emit(true) #Focus now gained
	is_focused = true
	
	if selected_item == null: return
	item_handler.draw_item_block(selected_item, board_pos, ItemBlockConstants.PREVIEW_LAYER)
	
func _input(event):
	if selected_item == null or not is_focused: return

	if event.is_action_released("left_click"):
		var board_pos = _get_mouse_position_on_board()
		item_handler.place_item_block(selected_item, board_pos)
		selected_item = null
		placed.emit()
	elif event.is_action_released("right_click"):
		item_handler.rotate_item(selected_item)
		

func _get_mouse_position_on_board() -> Vector2:
	#return $Board.local_to_map(get_local_mouse_position() / $Board.scale)
	return $Board.local_to_map($Board.to_local(get_local_mouse_position()))

func set_selected_item(item: ItemBlockDTO):
	selected_item = item

func _get_color_from_turret_color(color: Stats.TurretColor) -> Color:
	match (color):
		Stats.TurretColor.WHITE: return Color.WEB_GRAY
		Stats.TurretColor.GREEN: return Color.LAWN_GREEN
		Stats.TurretColor.RED: return Color.CRIMSON
		Stats.TurretColor.YELLOW: return Color.YELLOW
		Stats.TurretColor.BLUE: return Color.DODGER_BLUE
	return Color.BLACK
