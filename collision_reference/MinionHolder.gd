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
		if !util.valid(m):continue
		m.do(delta)
			
		
		var pos=board.local_to_map(m.global_position)
		
		if pos.x!=m.oldpos.x||pos.y!=m.oldpos.y:
			reference.setMinion(m.oldpos.x,m.oldpos.y,pos.x,pos.y,m)
			if GameState.gameState.HP<=0:return
			if !util.valid(m):continue
			m.cell_traversed()
			if GameState.gameState.deathscalling:return;
			
			m.oldpos=pos
			#print("minion pos is: "+str(pos))
			
			
	pass
