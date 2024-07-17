extends GameObject2D
class_name Projectile

var index;
var shot = false;
var damage;
var direction: Vector2;
var type;
var ext;
var penetrations;
var oneshotoriginal;
var pool;
var speed;
var target: Monster
var associate;
var playerDied = false;
var emitter
var ignore_next_enemy=false;
static var gamestate: GameState;
static var camera;
static var factory=load("res://TurretScripts/Projectiles/projectile_factory.tscn").instantiate()
var oldpos=Vector2(0,0)


static func create(type: Turret.Hue, damage, speed, root:TurretCore, extension: Turret.Extension=Turret.Extension.DEFAULT, penetrations:int=1) -> Projectile:
	return factory.get_bullet(type,damage,speed,root,penetrations,extension)	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	
	if gamestate == null:
		gamestate = GameState.gameState;
	if camera == null:
		camera = gamestate.getCamera();

	pass # Replace with function body.
func on_remove():
	
	pass;
func remove():
	associate.on_projectile_removed(self)
	#if associate != null: global_position = associate.global_position
	if pool == null:
		return ;
	shot = false;
	_remove_from_tree()
	
	pool.push_back(self)
	pass ;
func _remove_from_tree():
	global_position=Vector2(-1000,-1000)
	
	#get_parent().remove_child(self)
	pass;
func shoot(target):
	if not is_instance_valid(target):
		direction=Vector2(1,1)
	else: direction = (target.global_position - self.global_position).normalized();
	self.target = target;
	global_rotation = direction.angle() + PI / 2.0

	shot = true;
	pass ;

func move(delta):
	translate(direction * delta * speed);
	pass;
func cell_traversed():
	if associate!=null: associate.on_fly(self)
	pass;	
	
func hitEnemy(enemy: Monster):
	if ignore_next_enemy:ignore_next_enemy=false;return
	penetrations = penetrations - 1;
	var killed=enemy.hit(type, damage)
	on_hit(enemy)
	if associate != null: associate.on_hit(enemy,damage,type,killed,self)
	if penetrations <= 0&&penetrations > - 100000:
		remove()
	
	pass ;
func _toggle_emission(b):
	emitter.emitting=b
	pass;
func on_hit(enemy: Monster):
		if type == Turret.Hue.RED&&ext == Turret.Extension.REDLASER:
			applyRedLaser(enemy)
		if type == Turret.Hue.GREEN&&ext == Turret.Extension.GREENPOISON:
			applyPoison(enemy)
		if type == Turret.Hue.YELLOW&&ext == Turret.Extension.YELLOWMORTAR:
			applyMortarExplosion(enemy)
		if ext==Turret.Extension.BLUEFREEZER:
			applyBlueFreezer(enemy)
		pass ;
func applyBlueFreezer(enemy:Monster):
	var temp = false;
	for a in enemy.get_children():
		if a is Slower and a.factor==GameplayConstants.blue_freezer_slow_amount:
			temp = true;
			a.reapply()
	if !temp:
		enemy.add_child(Slower.create(GameplayConstants.blue_freezer_slow_duration,GameplayConstants.blue_freezer_slow_amount));
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
		if a is Poison&&a.decay == GameplayConstants.green_poison_decay:
			temp = true;
			a.apply(GameplayConstants.green_poison_damage_stack)
	if !temp:
		enemy.add_child(Poison.create(damage, associate, GameplayConstants.green_poison_decay));
	pass

func applyMortarExplosion(enemy: Monster):
	var pos = enemy.global_position
	gamestate.mortarWorkaround(damage, pos, associate)
	pass ;
