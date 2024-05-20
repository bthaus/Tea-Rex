extends Node2D

var board:TileMap
var reference:CollisionReference
# Called when the node enters the scene tree for the first time.
func _ready():

	reference=GameState.collisionReference
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for m:Monster in get_children():
		var pos=board.local_to_map(m.global_position)
		if pos.x!=m.oldpos.x||pos.y!=m.oldpos.y:
			reference.setMinion(m.oldpos.x,m.oldpos.y,pos.x,pos.y,m)
			m.oldpos=pos
			#print("minion pos is: "+str(pos))
			
			
	pass
