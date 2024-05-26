extends Node2D
class_name Projectile
static var blue_default_bullet_pool = []
static var bdi = 0;
static var blue_laser_bullet_pool = []
static var bli = 0;
static var red_default_bullet_pool = []
static var red_laser_bullet_pool = []
static var rli = 0;
static var green_default_bullet_pool = []
static var gdi = 0;
static var green_poison_bullet_pool = []
static var gpi = 0;
static var yellow_default_bullet_pool = []
static var ydi = 0;
static var yello_mortar_bullet_pool = []
static var blue_freezer_bullet_pool=[]
var index;
var shot = false;
var damage;
var direction: Vector2;
var type;
var ext;
var oneshot;
var oneshotoriginal;
var color;
var pool;
var speed;
var target: Monster
var associate;
var playerDied = false;
static var shotsplayed = 0;
static var hitsplayed = 0;
static var counter = 0;
static var gamestate: GameState;
static var camera;
var timesShot = 0;
static var numProjs = 0
var oldpos=Vector2(0,0)

enum asd {DEFAULT = 1, REDLASER = 2, BLUELASER = 3, YELLOWMORTAR = 4, GREENPOISON = 5};
enum asdsa {GREY = 1, GREEN = 2, RED = 3, YELLOW = 4, BLUE = 5};
static func getPool(color: Stats.TurretColor, type: Stats.TurretExtension):
	match color:
		2: match type:
			1: return green_default_bullet_pool
			5: return green_poison_bullet_pool
		3: match type:
			1: return red_default_bullet_pool
			2: return red_laser_bullet_pool
		4: match type:
			1: return yellow_default_bullet_pool
			4: return yello_mortar_bullet_pool
		5: match type:
			1: return blue_default_bullet_pool
			3: return blue_laser_bullet_pool
			6: return blue_freezer_bullet_pool
	return 1
	
static func create(type: Stats.TurretColor, damage, speed, root, extension: Stats.TurretExtension=Stats.TurretExtension.DEFAULT) -> Projectile:
	var temp;
	var pool = getPool(type, extension)
	
	if pool != null&&pool.size() != 0:
		temp = pool.pop_back()
		if temp == null:
			temp = load("res://TurretScripts/Projectiles/Base_projectile.tscn").instantiate() as Projectile;
			temp.type = type;
			temp.ext = extension;
			GameState.gameState.bulletHolder.add_child(temp)
			
		temp.visible = true;
		
	else:
		temp = load("res://TurretScripts/Projectiles/Base_projectile.tscn").instantiate() as Projectile;
		temp.type = type;
		temp.ext = extension;
		GameState.gameState.bulletHolder.add_child(temp)
	if type==Stats.TurretColor.GREEN and extension==Stats.TurretExtension.DEFAULT:
		temp.get_node("PArticles").visible=true;
		temp.get_node("PArticles/shiny").emitting=true;
		temp.get_node("PArticles/smoke").emitting=true;
		
	temp.global_position = root.global_position
	temp.associate = root
	temp.damage = damage;
	temp.speed = speed;
	temp.pool = pool
	temp.setup()
	
	return temp;
# Called when the node enters the scene tree for the first time.
func _ready():
	numProjs = numProjs + 1;
	print(str(numProjs) + "projectiles generated")
	GameState.gameState.player_died.connect(func(): free())
	$Sprite2D.texture = load("res://Assets/Turrets/Projectiles/" + Stats.getStringFromEnum(type) + Stats.getStringFromEnumExtension(ext) + "_projectile.png");
	#$shot.stream = load("res://Sounds/Soundeffects/" + Stats.getStringFromEnum(type) + Stats.getStringFromEnumExtension(ext) + "_shot.wav")
	#$hit.stream = load("res://Sounds/Soundeffects/" + Stats.getStringFromEnum(type) + Stats.getStringFromEnumExtension(ext) + "_hit.wav")
	oneshot = Stats.getOneshotType(type, ext);
	if gamestate == null:
		gamestate = GameState.gameState;
	if camera == null:
		camera = gamestate.getCamera();
	if ext == Stats.TurretExtension.BLUELASER:
		scale = Vector2(1, 1)
	if color == Stats.TurretColor.RED and ext == Stats.TurretExtension.DEFAULT:
		$Sprite2D.modulate = Color(1, 1, 1, 1)
	if color == Stats.TurretColor.BLUE and ext == Stats.TurretExtension.DEFAULT:
		$Sprite2D.modulate = Color(1, 1, 1, 1).lightened(5)	
	#BulletManager.allBullets.append(self)
	pass # Replace with function body.

func remove():
	if associate != null: global_position = associate.global_position
	
	if pool == null:
		return ;
	
	shot = false;
	global_position=Vector2(-5000,-5000)
	if not (type==Stats.TurretColor.GREEN and ext==Stats.TurretExtension.DEFAULT): visible = false;
	pool.push_back(self)
	pass ;
func setup():
	
	pass ;
func shoot(target):
	#playShootSound()
	
	direction = (target.global_position - self.global_position).normalized();
	#if type==Stats.TurretColor.BLUE:
	#	ConeFlash.flash(self.global_position,0.1,get_tree().get_root(),direction.angle() + PI / 2.0,0.2);
	timesShot = timesShot + 1;
	self.target = target;
	global_rotation = direction.angle() + PI / 2.0
	shot = true;
	pass ;

# Called every frame. 'delta' is the elapsed time since the previous frame.

func playHitSound():
	#if(hitsplayed>25):
		#return
	if camera != null:
		var mod = GameState.gameState.getCamera().zoom.y - 3;
	#	$hit.volume_db = 10 + mod * 1
	#if !$hit.playing:
	#	$hit.play();
	#	hitsplayed = hitsplayed + 1
	pass ;
func playShootSound():
	#if(shotsplayed>25):
		#return
	if camera != null:
		var mod = camera.zoom.y - 3;
		#$shot.volume_db = mod * 15
	
	#$shot.play();
	shotsplayed = shotsplayed + 1;
	pass ;

func hitEnemy(enemy: Monster):
	
	if (enemy is Monster):
		
		oneshot = oneshot - 1;
		applySpecials(enemy)
		
		if oneshot <= 0&&oneshot > - 100000:
			remove()
		if associate == null: return
		if enemy.hit(type, damage): associate.addKill()
		associate.addDamage(damage)
	
	pass ;

func applySpecials(enemy: Monster):
		if type == Stats.TurretColor.RED&&ext == Stats.TurretExtension.REDLASER:
			applyRedLaser(enemy)
		if type == Stats.TurretColor.GREEN&&ext == Stats.TurretExtension.DEFAULT:
			Explosion.create(type, damage, enemy.global_position, associate, Stats.green_explosion_range);
		if type == Stats.TurretColor.GREEN&&ext == Stats.TurretExtension.GREENPOISON:
			applyPoison(enemy)
		if type == Stats.TurretColor.YELLOW&&ext == Stats.TurretExtension.YELLOWMORTAR:
			applyMortarExplosion(enemy)
		if ext==Stats.TurretExtension.BLUEFREEZER:
			applyBlueFreezer(enemy)
		pass ;
func applyBlueFreezer(enemy:Monster):
	var temp = false;
	for a in enemy.get_children():
		if a is Slower and a.factor==Stats.blue_freezer_slow_amount:
			temp = true;
			a.reapply()
	if !temp:
		enemy.add_child(Slower.create(Stats.blue_freezer_slow_duration,Stats.blue_freezer_slow_amount));
	pass;		
func applyRedLaser(enemy: Monster):
	
	var temp = false;
	for a in enemy.get_children():
		if a is DamageStacker:
			temp = true;
			damage = damage + a.hit()
	if !temp:
		enemy.add_child(DamageStacker.new());
	pass
func applyPoison(enemy: Monster):
	var temp = false;
	for a in enemy.get_children():
		if a is Poison&&a.decay == Stats.green_poison_decay:
			temp = true;
			a.apply(Stats.green_poison_damage_stack)
	if !temp:
		enemy.add_child(Poison.create(damage, associate, Stats.green_poison_decay));
	pass

func applyMortarExplosion(enemy: Monster):
	var pos = enemy.global_position
	gamestate.mortarWorkaround(damage, pos, associate)
	pass ;
func _on_shot_finished():
	shotsplayed = shotsplayed - 1;
	pass # Replace with function body.

func _on_hit_finished():
	hitsplayed = hitsplayed - 1;
	pass # Replace with function body.
