extends Button

var _item_block: ItemBlockDTO
signal clicked

func set_item_block(item_block: ItemBlockDTO):
	var positions = Stats.getPositionsFromBlockShape(item_block.block_shape)
	for pos in positions:
		$TileMap.set_cell(ItemBlockConstants.BLOCK_LAYER, pos + Vector2(2,2), item_block.tile_id, Vector2(0, 0))
	_item_block = item_block

func _on_pressed():
	$TileMap.clear()
	clicked.emit(_item_block)
