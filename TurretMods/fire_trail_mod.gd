extends TurretBaseMod
class_name FireTrailMod

var board=GameState.board

func on_shoot(projectile:Projectile):
	var fire = Fire.get_fire()
	fire.initialise()
	fire.register_bullet(projectile)
	GameState.gameState.add_child(fire)
	super(projectile)
	pass;
# Called when the node enters the scene tree for the first time.
#func on_cell_traversal(projectile:Projectile):
	#var map=board.local_to_map(projectile.global_position)
	#if GameState.gameState.collisionReference.get_entity(projectile.global_position)!=null:return
	#var fire=Fire.get_fire()
	#
	#fire.global_position=board.map_to_local(map)
	#fire.map_position=map
	#GameState.gameState.add_child(fire)
	#GameState.gameState.collisionReference.register_entity(fire)
	#pass;

