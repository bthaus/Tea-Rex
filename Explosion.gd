extends Node2D
class_name Explosion
static var cache = []
static var scene = load("res://TurretScripts/Projectiles/Explosion.tscn")

var damage;
var type
var associate;
var sound;
var cam
var noise;
var range

static var counter = 0;
func _ready():
	counter = counter + 1;

	pass ;
static func create(type, damage, position, root, scale=1, noise=true):
	var temp;
	
	if cache.size() == 0:
		temp = scene.instantiate() as Explosion;
		
		GameState.gameState.call_deferred("add_child", temp);
		#root.add_child(temp);
		#temp.tree_entered.connect(temp.playSound)
		temp.visible = true;
		
	else:
		temp = cache.pop_back();
		#root.add_child(temp);
		GameState.gameState.call_deferred("add_child", temp);
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
func playSound():
	
	if noise:
		if sound==null:
			
			print("creating new audioinstance")
			sound = AudioStreamPlayer2D.new()
			add_child(sound)
			sound.stream = Sounds.explosionSounds.pick_random().duplicate()
			#sound.stream = load("res://Sounds/Soundeffects/FIREBALL_sound.wav")
		#sound.stop()
		
		if sound.get_parent()==null:
			add_child(sound)
		
		#sound.play(0.10)
	pass ;
static func addToCache(done):
	var temp = scene.instantiate();

	cache.push_back(temp)
	done.call()
	pass ;
static func pushCache(done: Callable):
	Explosion.new().call_deferred("addToCache", done)

	pass ;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func hit():
	
	var ms=[]
	if range<=1:
		ms=GameState.gameState.collisionReference.getMinionsAroundPosition(global_position)
	else:
		range=int(range)
		var cells=GameState.gameState.collisionReference.getCellReferences(global_position,range+1)
		for c in cells:
			ms.append_array(c)	
	for m in ms:
		if not is_instance_valid(m):continue
		if m.hit(type, damage)&&associate != null:
			associate.addKill()
		if associate != null&&associate.has_method("addDamage"):
			associate.addDamage(damage)
	pass;
func _process(delta):
	
	if cam != null and sound != null:
		var mod = cam.zoom.y - 3;
		sound.volume_db = 20 + mod * 15

	pass

var num = 0;
func _on_area_2d_area_entered(area):
	if (area.get_parent() is Monster):
		
		num = num + 1;
		if area.get_parent().hit(type, damage)&&associate != null:
			associate.addKill()
		if associate != null&&associate.has_method("addDamage"):
			associate.addDamage(damage)
	
	pass # Replace with function body.

func _on_animated_sprite_2d_animation_finished():
	$AnimatedSprite2D.visible = false;
	get_parent().remove_child(self)
	cache.push_back(self)
	pass # Replace with function body.

func _on_sound_finished():
	
	pass # Replace with function body.

func _on_visible_on_screen_notifier_2d_screen_entered():
	#$AnimatedSprite2D.visible = true
	pass # Replace with function body.

func _on_visible_on_screen_notifier_2d_screen_exited():
	#$AnimatedSprite2D.visible = false;
	pass # Replace with function body.
