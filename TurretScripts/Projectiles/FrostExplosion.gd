extends Explosion
class_name FrostExplosion

	
static func create(type, damage, position, root, scale=1, noise=true):
	var temp;
	
	if cache.size() == 0:
		temp = load("res://TurretScripts/Projectiles/Explosion.tscn").instantiate()
		temp.set_script(load("res://TurretScripts/Projectiles/FrostExplosion.gd"))
		
		
		GameState.gameState.add_child(temp);
		#root.add_child(temp);
		#temp.tree_entered.connect(temp.playSound)
		temp.visible = true;
		
	else:
		temp = cache.pop_back();
		#root.add_child(temp);
		#GameState.gameState.call_deferred("add_child", temp);
		GameState.gameState.add_child(temp);
		temp.scale = Vector2(scale, scale)
		temp.visible = true;
	temp.type = type;
	temp.scale = Vector2(scale, scale)
	#temp.apply_scale(Vector2(scale,scale));
	temp.damage = damage;	
	temp.range=scale;
	#temp.get_node("Area2D").monitoring = true;
	temp.get_node("AnimatedSprite2D").visible = true
	temp.global_position = position;
	temp.get_node("AnimatedSprite2D").play("default")
	temp.get_node("AnimationPlayer").play("lightup")
	temp.associate = root;
	temp.noise = noise
	
	#GameState.gameState.getCamera().shake(0.03,0.1,position,1)
	
	temp.cam = GameState.gameState.getCamera()
	
	pass ;	
func hit():
	
	var ms=[]
	if range<=1:
		ms=GameState.gameState.collisionReference.getMinionsAroundPosition(global_position)
	else:
		range=int(range)
		var cells=GameState.gameState.collisionReference.getCellReferences(global_position,range+1,null,[],true)
		for c in cells:
			ms.append_array(c)	
	for m in ms:
		if not is_instance_valid(m):continue
		var frost=FrostDebuff.new(1,self,1,9999)
		frost.register(m)
	var turrets=GameState.gameState.collisionReference.get_cells_around_pos(global_position,range,false)
	for cell in turrets:
		if !util.valid(cell.turret):continue
		var frost=FreezeTowerDebuff.new()
		frost.register(cell.turret)	
	pass;
