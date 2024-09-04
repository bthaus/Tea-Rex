extends TileMap


func get_turret_base_tile_id(color: Turret.Hue, level: int):
	return color * 100 + level

func set_turret(turret: Turret):
	var map_position = Vector2(0, 4)
	set_cell(GameboardConstants.MapLayer.BLOCK_LAYER, map_position, get_turret_base_tile_id(turret.color, turret.level), Vector2(0, 0))
	turret.global_position = map_to_local(Vector2(0, 0))
	add_child(turret)
