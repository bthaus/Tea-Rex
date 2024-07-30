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
	for b:Projectile in get_children():
		
		if b.shot:
			var precision=1
			if b.associate!=null and is_instance_valid(b.associate):
				precision=b.associate.projectile_precision 
			for i in range(precision):
				b.move(delta/precision)
				var pos=b.get_map()
				
				if pos!=b.oldpos: 
					b.oldpos=pos
					b.cell_traversed()
					if pos.y>GameState.gameState.board_height || pos.y<0 || pos.x<-9 || pos.x >21:
						b.remove()
					elif b.hit_wall():
						b.remove()
				if is_instance_valid(b):b.hit_cell()		
						
				
			
		
		
	pass
