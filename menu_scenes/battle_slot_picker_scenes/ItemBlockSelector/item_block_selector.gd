extends Panel

var item_handler: ItemBlockSelectorHandler

func _ready():
	item_handler = ItemBlockSelectorHandler.new($Board)
	
	
func _unhandled_input(event):
	pass
