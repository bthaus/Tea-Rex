extends Node2D
class_name  BulletMover
var board:TileMap
var reference:CollisionReference
# Called when the node enters the scene tree for the first time.
func _ready():

	reference=GameState.collisionReference	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for b in get_children():
		if b.shot:
			b.translate(b.direction * delta * b.speed);
			var pos=board.local_to_map(b.global_position);
			if pos.x==b.oldpos.x&&pos.y==b.oldpos.y: continue
			b.oldpos=pos
			
			if pos.y>GameState.gameState.board_height || pos.y<0 || pos.x<-9 || pos.x >21:
				b.remove()
				continue
			var moornot=reference.get_monster(pos)
			
			if moornot!=null:
				
				b.hitEnemy(moornot)
			
		
		
	pass
