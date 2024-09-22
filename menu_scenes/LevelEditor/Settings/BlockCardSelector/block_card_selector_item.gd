extends Button

var _block: Block
signal clicked

func set_block(block: Block):
	_block = block
	$BlockPreview.set_block(block, false)

func get_block() -> Block:
	return _block

func set_title(text: String):
	$Title.text = text

func _on_pressed():
	clicked.emit(_block)
