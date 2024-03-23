@tool
extends Node2D
@export var range=1;
@export var isBasic=true;
@export var type: Stats.TurretColor;

@export var stacks:int=1;
var shooter;
var projectile;
var cooldown;
var damage;
var onCooldown=false;
var direction:Vector2;



# Called when the node enters the scene tree for the first time.
func _ready():
	getStats();
	
	if isBasic:
		setUpTower();
	else:
		util.p("Turret has been marked non basic and no impl has been done","IMPORTANT","Bodo");
	pass # Replace with function body.


func setUpTower():
	$Base.texture=load("res://Assets/Turrets/Bases/"+Stats.getStringFromEnum(type)+"_base.png")
	$Barrel.texture=load("res://Assets/Turrets/Barrels/"+Stats.getStringFromEnum(type)+"_barrel.png")
	projectile=load("res://TurretScripts/Projectiles/"+Stats.getStringFromEnum(type)+"_projectile.tscn");
	cooldown=Stats.getCooldown(type);
	damage=Stats.getDamage(type);
	$EnemyDetector.setRange(Stats.getRange(type))
	util.p("setup completed")
	
	pass;
func getStats():
	$EnemyDetector.setRange(Stats.getRange(type));
	if type==Stats.TurretColor.YELLOW:
		util.p("implement custom yellow range","Bodo","potential");
		
	
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	if inRange():
		var target=$EnemyDetector.enemiesInRange[0];
		direction=(target.global_position-self.global_position).normalized();
		$Barrel.rotation=direction.angle() + PI / 2.0;
		
		if !onCooldown:
			shoot(target);
	#debugg
	if stacks>1:
		$Barrel/second.visible=true;
	
	if stacks>2:
		$Barrel/third.visible=true;	
	
	pass;

func shoot(target):
	
	var shot=projectile.instantiate();
	add_child(shot);
	shot.global_position=$Barrel/BulletPosition.global_position;
	shot.shoot(target,damage);
	
	if stacks>1:
		var sshot=projectile.instantiate();
		add_child(sshot);
		sshot.global_position=$Barrel/second/BulletPosition.global_position;
		sshot.shoot(target,damage);
	if stacks>2:
		var tshot=projectile.instantiate();
		add_child(tshot);
		tshot.global_position=$Barrel/third/BulletPosition.global_position;
		tshot.shoot(target,damage);
	$Timer.start(cooldown);
	onCooldown=true;
	pass;
func inRange():
	return $EnemyDetector.enemiesInRange.size()>0;
	
func _get_configuration_warnings():
	var arr=PackedStringArray([])
	var children=get_children();
	var detector=false;
	var sprite=false;
	var missile=false;
	for a in children:
		if a.name=="EnemyDetector":
			detector=true;
	if !detector:
		arr.append("Add a detector to your turret");		
	return arr;

func levelup():
	stacks=stacks+1;
	if stacks==2:
		$Barrel/second.visible=true;
	
	if stacks==3:
		$Barrel/third.visible=true;		
	pass;
func _on_timer_timeout():
	onCooldown=false;
	pass # Replace with function body.
