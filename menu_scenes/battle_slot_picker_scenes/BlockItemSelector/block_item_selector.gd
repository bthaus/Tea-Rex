extends Panel

var item_handler: BlockItemSelectorHandler

func _ready():
	item_handler = BlockItemSelectorHandler.new($Board)
	
func _unhandled_input(event):
	pass
