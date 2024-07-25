extends GameObject2D
class_name  BulletMover
var board:TileMap
var reference:CollisionReference
# Called when the node enters the scene tree for the first time.
func _ready():

	reference=GameState.collisionReference	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func do(delta):
	for b in get_children():
		if b.shot:
			var precision=1
			if b.associate!=null and is_instance_valid(b.associate):
				precision=b.associate.projectile_precision 
			for i in range(precision):
				b.move(delta/precision)
				var pos=b.get_map()
				if pos.x==b.oldpos.x&&pos.y==b.oldpos.y: continue
				b.oldpos=pos
				b.cell_traversed()
				if pos.y>GameState.gameState.board_height || pos.y<0 || pos.x<-9 || pos.x >21:
					b.remove()
					break;
				if b.hit_wall():
					b.remove()
					break	
				var moornot=reference.get_monster(pos)
				if moornot!=null:
					b.hitEnemy(moornot)
			
		
		
	pass
