extends Node
class_name ItemBlockSelectorHandler

var board: TileMap
var item_blocks: Array[ItemBlockDTO]

func _init(board: TileMap, item_blocks: Array[ItemBlockDTO]):
	self.board = board
	self.item_blocks = item_blocks
	for item in item_blocks:
		draw_item_block(item, item.map_position, ItemBlockConstants.BLOCK_LAYER)

#Simply draws an item block on the board
func draw_item_block(item_block: ItemBlockDTO, map_position: Vector2, layer: int):
	if item_block == null: return
	var positions = BlockUtils.get_positions_from_block_shape(item_block.block_shape)
	positions = rotate_positions(positions, item_block.rotation)
	for pos in positions:
		board.set_cell(layer, map_position + pos, item_block.tile_id, Vector2(0, 0))

#Simply draws an item block on the board using an id
func draw_item_block_with_id(item_block: ItemBlockDTO, tile_id: int, map_position: Vector2, layer: int):
	if item_block == null: return
	var positions = BlockUtils.get_positions_from_block_shape(item_block.block_shape)
	positions = rotate_positions(positions, item_block.rotation)
	for pos in positions:
		board.set_cell(layer, map_position + pos, tile_id, Vector2(0, 0))

#Places an item on the board, and adds it to the list of items if possible
func place_item_block(item_block: ItemBlockDTO, map_position: Vector2):
	if item_block == null: return
	if not can_place_item_block(item_block, map_position): return
	draw_item_block(item_block, map_position, ItemBlockConstants.BLOCK_LAYER)
	item_block.map_position = map_position
	item_blocks.append(item_block)

func rotate_item(item_block: ItemBlockDTO):
	item_block.rotation = (item_block.rotation + 1) % 4
	
#Rotates all positions from the origin point (0,0). Rotation parameter can be 0, 1, 2 or 3
func rotate_positions(positions: PackedVector2Array, rotation: int) -> PackedVector2Array:
	var rotated_positions: PackedVector2Array = []
	for pos in positions:
		pos.y *= -1 #Vector has positive side upwards, exactly opposite of tilemap
		pos = pos.rotated(deg_to_rad(-90*rotation)) #This method rotates counter-clockwise, so we need to add the sign
		pos.y *= -1 #Convert back
		pos.x = round(pos.x) #Dont ask me, i hate it
		pos.y = round(pos.y)
		rotated_positions.append(pos)
	return rotated_positions

func remove_item_block(item_block: ItemBlockDTO):
	var idx = _get_item_block_idx(item_block)
	if idx == -1: return
	var positions = BlockUtils.get_positions_from_block_shape(item_block.block_shape)
	for pos in positions:
		board.set_cell(ItemBlockConstants.BLOCK_LAYER, item_block.map_position + pos, -1, Vector2(0, 0))
		
	item_blocks.remove_at(idx)

func _get_item_block_idx(item_block: ItemBlockDTO) -> int:
	for i in item_blocks.size():
		if item_blocks[i] == item_block:
			return i
	return -1

func get_item_block_at(map_position: Vector2) -> ItemBlockDTO:
	for item in item_blocks:
		var positions = BlockUtils.get_positions_from_block_shape(item.block_shape)
		for pos in positions:
			if map_position == item.map_position + pos:
				return item
	return null

func can_place_item_block(item_block: ItemBlockDTO, map_position: Vector2) -> bool:
	var positions = BlockUtils.get_positions_from_block_shape(item_block.block_shape)
	positions = rotate_positions(positions, item_block.rotation)
	for pos in positions:
		var board_pos = map_position + pos
		
		#No ground present
		if board.get_cell_source_id(ItemBlockConstants.GROUND_LAYER, board_pos) == -1:
			return false
		
		#Block is already present
		if board.get_cell_source_id(ItemBlockConstants.BLOCK_LAYER, board_pos) != -1:
			return false
		
		#If the piece is white and we passed until here, continue
		if item_block.color == Turret.Hue.WHITE:
			continue
			
		#Check near mismatching colors
		for row in range(-1,2):
			for col in range(-1,2):
				var cell_pos = Vector2(board_pos.x+col, board_pos.y+row)
				var neighbour_color = ItemBlockConstants.get_color_from_tile(board, ItemBlockConstants.BLOCK_LAYER, cell_pos)
				if neighbour_color == null or neighbour_color == Turret.Hue.WHITE: #Checking surrounding pieces is only for colored blocks neccessary
					continue 
				
				if neighbour_color != item_block.color:
					return false
		
	return true
