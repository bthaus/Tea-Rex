extends Button

var _item_block: ItemBlockDTO
signal clicked

func _ready():
	$TileMap.tile_set.tile_size = Vector2(GameboardConstants.TILE_SIZE, GameboardConstants.TILE_SIZE)

func set_item(item_block: ItemBlockDTO):
	var block = BlockUtils.get_block_from_shape(item_block.block_shape, Turret.Hue.WHITE)
	$TileMap.clear_layer(ItemBlockConstants.MapLayer.BLOCK_LAYER)
	for piece in block.pieces:
		$TileMap.set_cell(ItemBlockConstants.MapLayer.BLOCK_LAYER, piece.position, item_block.tile_id, Vector2(0, 0))
	_item_block = item_block

func _on_pressed():
	clicked.emit(_item_block)
