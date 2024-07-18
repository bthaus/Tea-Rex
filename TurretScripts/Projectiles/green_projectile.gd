extends Projectile


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _shoot_duplicate(projectile,angle):
	projectile.offset=util.rotate_vector(Vector2(100,0),angle*2)
	super(projectile,angle)
	pass;
	
var offset=Vector2(0,0)
func shoot(target):
	var pos=target.global_position+offset
	global_position = pos;
	self.target=target
	visible=true;
	penetrations=penetrations-1
	get_tree().create_timer(1).timeout.connect(func():
		Explosion.create(Turret.Hue.GREEN, damage, pos, self, 0.5)
		remove()
	)
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
