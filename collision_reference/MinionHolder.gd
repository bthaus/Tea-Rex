extends GameObject2D
class_name MinionSetter
var board:TileMap
var reference:CollisionReference
# Called when the node enters the scene tree for the first time.
func _ready():

	reference=GameState.collisionReference
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func do(delta):
	for m:Monster in get_children():
		m.translateTowardEdge(delta)
			
		
		var pos=board.local_to_map(m.global_position)
		if pos.x!=m.oldpos.x||pos.y!=m.oldpos.y:
			if m==null:continue
			reference.setMinion(m.oldpos.x,m.oldpos.y,pos.x,pos.y,m)
			m.cell_traversed()
			if GameState.gameState.deathscalling:return;
			if m==null:continue
			m.oldpos=pos
			#print("minion pos is: "+str(pos))
			
			
	pass
