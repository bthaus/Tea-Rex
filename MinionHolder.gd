extends Node2D
class_name MinionSetter
var board:TileMap
var reference:CollisionReference
# Called when the node enters the scene tree for the first time.
func _ready():

	reference=GameState.collisionReference
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for m:Monster in get_children():
		if m.hp>0:
			var direction=(m.nav.get_next_path_position()-m.global_position).normalized()
			m.translate(Stats.enemy_base_speed*direction*delta*m.speedfactor)
		
		var pos=board.local_to_map(m.global_position)
		if pos.x!=m.oldpos.x||pos.y!=m.oldpos.y:
			if m==null:continue
			reference.setMinion(m.oldpos.x,m.oldpos.y,pos.x,pos.y,m)
			if GameState.gameState.deathscalling:return;
			if m==null:continue
			m.oldpos=pos
			#print("minion pos is: "+str(pos))
			
			
	pass
