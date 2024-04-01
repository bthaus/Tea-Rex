extends Node2D
class_name Projectile
static var blue_default_bullet_pool=[]
static var bdi=0;
static var blue_laser_bullet_pool=[]
static var bli=0;
static var red_laser_bullet_pool=[]
static var rli=0;
static var green_default_bullet_pool=[]
static var gdi=0;
static var green_poison_bullet_pool=[]
static var gpi=0;
static var yellow_default_bullet_pool=[]
static var ydi=0;
var index;
var shot=false;
var damage;
var direction:Vector2;
var type;
var ext;
var oneshot;
var oneshotoriginal;
var color;
var pool;
var target:Monster
static var counter=0;
enum asd {DEFAULT=1,REDLASER=2, BLUELASER=3, YELLOWCATAPULT=4, GREENPOISON=5};
enum asdsa {GREY=1, GREEN=2, RED=3, YELLOW=4,BLUE=5};
static func getPool(color:Stats.TurretColor,type:Stats.TurretExtension):
	match color:
		2: match type:
			1: return green_default_bullet_pool
			5: return green_poison_bullet_pool
		3: match type:
			1: return null
			2: return red_laser_bullet_pool
		4: match type:
			1: return yellow_default_bullet_pool
		5: match type:
			1: return blue_default_bullet_pool
			3: return blue_laser_bullet_pool
	return 1
	
	
static func create(type:Stats.TurretColor, damage,speed,root,extension:Stats.TurretExtension=Stats.TurretExtension.DEFAULT)-> Projectile:
	var temp;
	var pool=getPool(type,extension) 
	
	if 	pool==null||pool.size()==0:
		temp=load("res://TurretScripts/Projectiles/Base_projectile.tscn").instantiate() as Projectile;
		temp.type=type;
		temp.ext=extension;	
		root.add_child(temp);
	else:
		temp=pool.pop_back()
		var index;
		match type:
			2: match extension:
				1:  index=gdi+1
				5:  index=gpi
			3: match extension:
				1:  index=1
				2:  index=rli
			4: match extension:
				1:  index=ydi
			5: match extension:
				1:  index=bdi
				3:  index=bli+1
		if index>=pool.size():
			index=0;
			bli=0;
		
		
	
	
	temp.pool=pool
	temp.setup()
	
	return temp;
# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.texture=load("res://Assets/Turrets/Projectiles/"+Stats.getStringFromEnum(type)+Stats.getStringFromEnumExtension(ext)+"_projectile.png");
	$shot.stream=load("res://Sounds/Soundeffects/"+Stats.getStringFromEnum(type)+Stats.getStringFromEnumExtension(ext)+"_shot.wav")
	$hit.stream=load("res://Sounds/Soundeffects/"+Stats.getStringFromEnum(type)+Stats.getStringFromEnumExtension(ext)+"_hit.wav")
	#BulletManager.allBullets.append(self)
	pass # Replace with function body.

func remove():
	
	if pool==null:
		queue_free()
		return;
	shot=false;
	$Area2D/CollisionShape2D.set_deferred("disabled",true)
	global_position=Vector2(3000,3000);
	$PointLight2D.visible=false
	pool.push_back(self)
	pass;	
func setup():
	
	$PointLight2D.visible=Stats.getGlowing(type,ext)
	oneshot=Stats.getOneshotType(type,ext);
	damage=Stats.getDamage(type,ext);
	
	pass;
func shoot(target):
	$shot.play();
	$Area2D/CollisionShape2D.set_deferred("disabled",false)
	direction=(target.global_position-self.global_position).normalized();
	if type==Stats.TurretColor.BLUE:
		ConeFlash.flash(self.global_position,0.1,get_tree().get_root(),direction.angle() + PI / 2.0,0.2);
	
	self.target=target;	
	global_rotation=direction.angle() + PI / 2.0
	shot=true;
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	if shot:
		translate(direction*delta*Stats.getMissileSpeed(type,ext));
		
	if abs(global_position.x)>1500||abs(global_position.y)>1500:
		remove()
	pass
func playHitSound():
	if !$hit.playing:
		$hit.play();
	pass;
	

func _on_area_2d_area_entered(area):
	var en=area.get_parent();
	if en is Monster:
		hitEnemy(en)
			
	pass # Replace with function body.
func hitEnemy(enemy:Monster):
	playHitSound();
	if(enemy is Monster):
		
		oneshot=oneshot-1;
		applySpecials(enemy)
		enemy.hit(type,damage);
		
		if oneshot<=0&&oneshot>-100000:
			remove()
	pass;	
	
func applySpecials(enemy:Monster):
		if type==Stats.TurretColor.RED&&ext==Stats.TurretExtension.REDLASER:
			applyRedLaser(enemy)
		if type==Stats.TurretColor.GREEN&&ext==Stats.TurretExtension.DEFAULT:
			Explosion.create(type,damage,global_position,get_tree().get_root(),Stats.green_explosion_range);
		if type==Stats.TurretColor.GREEN&&ext==Stats.TurretExtension.GREENPOISON:
			applyPoison(enemy)
		
		pass;
		
func applyRedLaser(enemy:Monster):
	
	var temp=false;
	for a in enemy.get_children():
		if a is DamageStacker:
			temp=true;
			damage=damage+a.hit()
	if !temp:
		enemy.add_child(DamageStacker.new());
	pass
func applyPoison(enemy:Monster):
	var temp=false;
	for a in enemy.get_children():
		if a is Poison&&a.decay==Stats.green_poison_decay:
			temp=true;
			a.apply(Stats.green_poison_damage_stack)
	if !temp:
		enemy.add_child(Poison.create(damage,Stats.green_poison_decay));
	pass
