extends GameObject2D

var block_handler: BlockHandler

func set_block(block: Block, spawn_turrets: bool):
	
	clear_preview()
	if block_handler == null:
		block_handler = BlockHandler.new($TileMap, GameObjectHolder.new())
	#block_handler.draw_block(block, Vector2(0,0))
	var turrets=[]
	if spawn_turrets:
		for piece in block.pieces:
			if piece.color == Turret.Hue.WHITE:
				continue
			var turret = Turret.create(piece.color, piece.level, piece.extension)
			turret.position = $TileMap.map_to_local(Vector2(piece.position.x, piece.position.y))
			turret.placed=false;
			add_child(turret)

func clear_preview():
	$TileMap.clear_layer(GameboardConstants.MapLayer.BLOCK_LAYER)
	for child in get_children():
		if child is Turret:
			child.queue_free()
