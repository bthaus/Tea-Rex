extends Button

var _item_block: ItemBlockDTO
signal clicked

func set_item(item_block: ItemBlockDTO):
	_item_block = item_block
	#TODO set texture etc.

func _on_pressed():
	clicked.emit(_item_block)
