extends Node2D
class_name Projectile
var shot=false;
var damage;
var direction:Vector2;
var type;
var ext;
var oneshot;
static func create(type:Stats.TurretColor, damage,speed,extension:Stats.TurretExtension=Stats.TurretExtension.DEFAULT)-> Projectile:
	var temp=load("res://TurretScripts/Projectiles/Base_projectile.tscn").instantiate() as Projectile;
	temp.type=type;
	temp.ext=extension;
	
	
	return temp;
# Called when the node enters the scene tree for the first time.
func _ready():
	setup();
	pass # Replace with function body.
func setup():
	$Sprite2D.texture=load("res://Assets/Turrets/Projectiles/"+Stats.getStringFromEnum(type)+Stats.getStringFromEnumExtension(ext)+"_projectile.png");
	$shot.stream=load("res://Sounds/Soundeffects/"+Stats.getStringFromEnum(type)+Stats.getStringFromEnumExtension(ext)+"_shot.wav")
	$hit.stream=load("res://Sounds/Soundeffects/"+Stats.getStringFromEnum(type)+Stats.getStringFromEnumExtension(ext)+"_hit.wav")
	oneshot=Stats.getOneshotType(type,ext);
	damage=Stats.getDamage(type,ext);
	pass;
func shoot(target):
	$shot.play();
	
	direction=(target.global_position-self.global_position).normalized();
	if type==Stats.TurretColor.BLUE:
		ConeFlash.flash(self.global_position,0.1,get_tree().get_root(),direction.angle() + PI / 2.0,0.2);
	
		
	global_rotation=direction.angle() + PI / 2.0
	shot=true;
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shot:
		translate(direction*delta*Stats.getMissileSpeed(type,ext));
	pass

func playHitSound():
	if !$hit.playing:
		$hit.play();
	pass;
	

func _on_area_2d_area_entered(area):
	var enemy=area.get_parent();
	playHitSound();
	if(enemy is Monster):
		oneshot=oneshot-1;
		applySpecials(enemy)
		print(damage)
		enemy.hit(type,damage);
		if type==Stats.TurretColor.GREEN:
			Explosion.create(type,damage,global_position,get_tree().get_root(),Stats.green_explosion_range);
		
		if oneshot<=0&&oneshot>-100000:
			queue_free();
	
	
	
	pass # Replace with function body.
	
	
func applySpecials(enemy:Monster):
		if type==Stats.TurretColor.RED&&ext==Stats.TurretExtension.REDLASER:
			applyRedLaser(enemy)
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
