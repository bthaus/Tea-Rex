extends Panel

@export var color: Turret.Hue
@onready var style_box: StyleBoxFlat = get_theme_stylebox("panel").duplicate()

@onready var checked_style_box = load("res://Styles/checked_button.tres")
@onready var unchecked_style_box = load("res://Styles/unchecked_button.tres")

var item_handler: ItemBlockSelectorHandler
var selected_item: ItemBlockDTO
var is_focused = false
var container_selected = false
var container

signal placed
signal picked_up
signal focused
signal selected

func _ready():
	var mods
	for c in MainMenu.get_account_dto().turret_mod_containers:
		if c.color == color:
			mods = c.turret_mods
			container = c
			break
	
	item_handler = ItemBlockSelectorHandler.new($Board, mods)
	style_box.set("border_color", _get_color_from_turret_color(color))
	add_theme_stylebox_override("panel", style_box)

func _process(delta):
	$Board.clear_layer(ItemBlockConstants.PREVIEW_LAYER)
	var board_pos = _get_mouse_position_on_board()
	if board_pos.x < 0 or board_pos.x > 3 or board_pos.y < 0 or board_pos.y > 3:
		if is_focused: focused.emit(false) #Focus now lost
		is_focused = false
		return
	
	if not is_focused: focused.emit(true) #Focus now gained
	is_focused = true
	
	if selected_item == null: return
	var can_place = item_handler.can_place_item_block(selected_item, board_pos)
	var id = ItemBlockConstants.LEGAL_PLACEMENT_TILE_ID if can_place else ItemBlockConstants.ILLEGAL_PLACEMENT_TILE_ID
	item_handler.draw_item_block_with_id(selected_item, id, board_pos, ItemBlockConstants.PREVIEW_LAYER)
	
func _input(event):
	if not is_focused: return
	if event.is_action_released("left_click"):
		var board_pos = _get_mouse_position_on_board()
		#Place down
		if selected_item != null:
			if item_handler.can_place_item_block(selected_item, board_pos):
				item_handler.place_item_block(selected_item, board_pos)
				placed.emit()
		#Pick up
		else:
			var item = item_handler.get_item_block_at(board_pos)
			if item != null:
				item_handler.remove_item_block(item)
				picked_up.emit(item)

func _get_mouse_position_on_board() -> Vector2:
	#return $Board.local_to_map($Board.to_local(get_local_mouse_position())) - $Board.local_to_map($Board.to_local($Board.position))
	return $Board.local_to_map((get_local_mouse_position() - $Board.position) / $Board.scale)

func set_selected_item(item: ItemBlockDTO):
	selected_item = item

func _on_selected_button_pressed():
	selected.emit(self, not container_selected)

func set_selected_state(selected: bool):
	container_selected = selected
	var style = checked_style_box if selected else unchecked_style_box
	$SelectedButton.add_theme_stylebox_override("normal", style)
	$SelectedButton.add_theme_stylebox_override("hover", style)
	$SelectedButton.add_theme_stylebox_override("pressed", style)
	$SelectedButton.add_theme_stylebox_override("disabled", style)
	$SelectedButton.add_theme_stylebox_override("focus", style)

func _get_color_from_turret_color(color: Turret.Hue) -> Color:
	match (color):
		Turret.Hue.WHITE: return Color.GHOST_WHITE
		Turret.Hue.GREEN: return Color.LAWN_GREEN
		Turret.Hue.RED: return Color.CRIMSON
		Turret.Hue.YELLOW: return Color.YELLOW
		Turret.Hue.BLUE: return Color.DODGER_BLUE
		Turret.Hue.MAGENTA: return Color.MAGENTA
	return Color.BLACK
