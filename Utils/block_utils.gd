extends GameObjectCounted
class_name BlockUtils

static func get_block_from_shape(block_shape: Block.BlockShape, color: Turret.Hue, level: int = 1, extension: Turret.Extension = Turret.Extension.DEFAULT) -> Block:
	var pieces = []
	var positions = get_positions_from_block_shape(block_shape)
	for pos in positions:
		pieces.append(Block.Piece.new(pos, color, level, extension))
	
	var b = Block.new(pieces)
	b.shape=block_shape;
	b.color=color;
	b.extension=extension
	return b
	
static func get_positions_from_block_shape(block_shape: Block.BlockShape) -> PackedVector2Array:
	var positions: PackedVector2Array = []
	match block_shape:
		Block.BlockShape.O:
			positions = [Vector2(0,0), Vector2(-1,0), Vector2(-1,-1), Vector2(0,-1)]
		Block.BlockShape.I:
			positions = [Vector2(0,0), Vector2(0,1), Vector2(0,-1), Vector2(0,-2)]
		Block.BlockShape.S:
			positions = [Vector2(0,0), Vector2(-1,0), Vector2(0,-1), Vector2(1,-1)]
		Block.BlockShape.Z:
			positions = [Vector2(0,0), Vector2(1,0), Vector2(0,-1), Vector2(-1,-1)]
		Block.BlockShape.L:
			positions = [Vector2(0,0), Vector2(0,1), Vector2(0,-1), Vector2(1,1)]
		Block.BlockShape.J:
			positions = [Vector2(0,0), Vector2(0,1), Vector2(0,-1), Vector2(-1,1)]
		Block.BlockShape.T:
			positions = [Vector2(0,0), Vector2(-1,0), Vector2(1,0), Vector2(0,1)]
		Block.BlockShape.TINY:
			positions = [Vector2(0,0)]
		Block.BlockShape.SMALL:
			positions = [Vector2(0,0), Vector2(0,-1)]
		Block.BlockShape.ARROW:
			positions = [Vector2(0,0), Vector2(-1,0), Vector2(0,1)]
		Block.BlockShape.CROSS:
			positions = [Vector2(0,0), Vector2(0,-1), Vector2(1,0), Vector2(0,1), Vector2(-1,0)]
	
	return positions
