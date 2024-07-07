extends Node
class_name ItemBlockSelectorHandler

var board: TileMap
var item_blocks: Array

func _init(board: TileMap, item_blocks: Array):
	self.board = board
	self.item_blocks = item_blocks

#Simply draws an item block on the board
func draw_item_block(item_block: ItemBlock, map_position: Vector2, layer: int):
	if item_block == null: return
	for piece in item_block.pieces:
		board.set_cell(layer, map_position + piece.position, piece.tile_id, Vector2(0, 0))

#Places an item on the board, and adds it to the list of items if possible
func place_item_block(item_block: ItemBlock, map_position: Vector2):
	if item_block == null: return
	if not can_place_item_block(item_block, map_position): return
	draw_item_block(item_block, map_position, ItemBlockConstants.BLOCK_LAYER)
	item_block.map_position = map_position
	item_blocks.append(item_block)

func remove_item_block(item_block: ItemBlock):
	var idx = _get_item_block_idx(item_block)
	if idx == -1: return
	for piece in item_block.pieces:
		board.set_cell(ItemBlockConstants.BLOCK_LAYER, item_block.map_position + piece.position, -1, Vector2(0, 0))
		
	item_blocks.remove_at(idx)

func _get_item_block_idx(item_block: ItemBlock) -> int:
	for i in item_blocks.size():
		if item_blocks[i] == item_block:
			return i
	return -1

func get_item_block_at(map_position: Vector2) -> ItemBlock:
	for item in item_blocks:
		for piece in item.pieces:
			if map_position == item.map_position + piece.position:
				return item
	return null

func can_place_item_block(item_block: ItemBlock, map_position: Vector2) -> bool:
	for piece in item_block.pieces:
		if board.get_cell_source_id(ItemBlockConstants.BLOCK_LAYER, map_position + piece.position) != -1:
			return false
	return true
