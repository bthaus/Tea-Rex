extends GameObject2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func duplicate_bullet(bullet:Projectile)->Projectile:
	return get_bullet(bullet.type,bullet.damage,bullet.speed,bullet.associate,bullet.penetrations,bullet.ext)
	
	
	pass;
func get_bullet(color:Stats.TurretColor,damage, speed, turret, penetrations,extension:Stats.TurretExtension)->Projectile:
	var temp
	var pool=turret.bullets
	
	if pool.size() != 0:
		temp = pool.pop_back()
		temp.visible = true;
		
	else:
		
		if extension==Stats.TurretExtension.BLUELASER:
			temp= $blue_laser_projectile.duplicate()
		elif color==Stats.TurretColor.GREEN:
			temp= $rocket_projectile.duplicate()
		elif color==Stats.TurretColor.RED:
			temp=$red_saw.duplicate()	
		else:
			temp= $base_projectile.duplicate()
				
	temp.type = color;
	temp.ext = extension;
	#temp.global_position = turret.global_position
	temp.associate = turret
	temp.damage = damage;
	temp.speed = speed;
	temp.pool=pool
	temp.penetrations=penetrations
	GameState.gameState.bulletHolder.add_child(temp)
	temp.visible=true
	
	return temp
	
	
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
