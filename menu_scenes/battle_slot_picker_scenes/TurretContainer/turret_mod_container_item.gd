extends Panel

@export var color: Stats.TurretColor
@onready var style_box: StyleBoxFlat = get_theme_stylebox("panel").duplicate()

var item_handler: ItemBlockSelectorHandler
var selected_item: ItemBlockDTO
signal placed

func _ready():
	item_handler = ItemBlockSelectorHandler.new($Board, [])
	style_box.set("border_color", _get_color_from_turret_color(color))
	add_theme_stylebox_override("panel", style_box)

func _process(delta):
	if selected_item == null: return
	$Board.clear_layer(ItemBlockConstants.PREVIEW_LAYER)
	var board_pos = _get_mouse_position_on_board()
	item_handler.draw_item_block(selected_item, board_pos, ItemBlockConstants.PREVIEW_LAYER)
	
func _unhandled_input(event):
	if selected_item == null: return
	if event.is_action_released("left_click"):
		var board_pos = _get_mouse_position_on_board()
		item_handler.place_item_block(selected_item, board_pos)
		selected_item = null
		placed.emit()
	elif event.is_action_released("right_click"):
		item_handler.rotate_item(selected_item)

func _get_mouse_position_on_board() -> Vector2:
	return $Board.local_to_map(get_global_mouse_position() / $Board.scale)

func set_selected_item(item: ItemBlockDTO):
	selected_item = item

func _get_color_from_turret_color(color: Stats.TurretColor) -> Color:
	match (color):
		Stats.TurretColor.GREY: return Color.WEB_GRAY
		Stats.TurretColor.GREEN: return Color.LAWN_GREEN
		Stats.TurretColor.RED: return Color.CRIMSON
		Stats.TurretColor.YELLOW: return Color.YELLOW
		Stats.TurretColor.BLUE: return Color.DODGER_BLUE
	return Color.BLACK
