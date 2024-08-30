extends Panel

@onready var grid_container = $ScrollContainer/GridContainer
signal block_selected
signal custom_selected

func _ready():
	for shape in Block.BlockShape.keys():
		var block = BlockUtils.get_block_from_shape(Block.BlockShape.get(shape), Turret.Hue.WHITE)
		var title = util.format_name_string(shape)
		var item = load("res://menu_scenes/LevelEditor/Settings/BlockSelector/block_selector_item.tscn").instantiate()
		item.set_block(block)
		item.set_title(title)
		item.clicked.connect(_on_block_selected)
		grid_container.add_child(item)


func _on_block_selected(block: Block):
	block_selected.emit(block)
	queue_free()

func _on_custom_button_pressed():
	custom_selected.emit()
	queue_free()

func _on_cancel_button_pressed():
	queue_free()
