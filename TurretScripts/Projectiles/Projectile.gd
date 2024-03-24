extends Node2D
class_name Projectile
var shot=false;
var damage;
var direction:Vector2;
var type;
var ext="";
var oneshot:bool;
static func create(type)-> Projectile:
	var temp=load("res://TurretScripts/Projectiles/Base_projectile.tscn").instantiate() as Projectile;
	temp.type=type;
	
	return temp;
# Called when the node enters the scene tree for the first time.
func _ready():
	setup();
	pass # Replace with function body.
func setup():
	$Sprite2D.texture=load("res://Assets/Turrets/Projectiles/"+Stats.getStringFromEnum(type)+ext+"_projectile.png");
	$shot.stream=load("res://Sounds/Soundeffects/"+Stats.getStringFromEnum(type)+ext+"_shot.wav")
	$hit.stream=load("res://Sounds/Soundeffects/"+Stats.getStringFromEnum(type)+ext+"_hit.wav")
	oneshot=Stats.getOneshotType(type);
	damage=Stats.getDamage(type);
	pass;
func shoot(target,damage):
	$shot.play();
	
	self.damage=damage;
	
	direction=(target.global_position-self.global_position).normalized();
	if type==Stats.TurretColor.BLUE:
		ConeFlash.flash(self.global_position,0.1,get_tree().get_root(),direction.angle() + PI / 2.0,0.2);
	
	global_rotation=direction.angle() + PI / 2.0
	shot=true;
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shot:
		translate(direction*delta*Stats.getMissileSpeed(type));
	pass

func playHitSound():
	if !$hit.playing:
		$hit.play();
	pass;
func _on_area_2d_area_entered(area):
	playHitSound();
	if(area.get_parent() is Monster):
		area.get_parent().hit(type,self.damage);
		if type==Stats.TurretColor.GREEN:
			Explosion.create(type,damage,global_position,get_tree().get_root(),Stats.green_explosion_range);
		if oneshot:
			queue_free();
	
	
	pass # Replace with function body.
