extends Button

var _item_block: ItemBlock
signal clicked

func set_item_block(item_block: ItemBlock):
	for piece in item_block.pieces:
		$TileMap.set_cell(ItemBlockConstants.BLOCK_LAYER, piece.position, piece.tile_id, Vector2(0, 0))
	_item_block = item_block

func _on_pressed():
	$TileMap.clear()
	clicked.emit(_item_block)
