@tool
extends Node2D
class_name Turret

@export var range=1;
@export var isBasic=true;
@export var type: Stats.TurretColor;
@export var stacks:int=1;
@export var extension:Stats.TurretExtension;

var shooter;
var projectile;

var onCooldown=false;
var direction:Vector2;


var speed;
var cooldown;
var damage;

var speedfactor=1;
var damagefactor=1;
var cooldownfactor=1;



static func create(color:Stats.TurretColor, lvl:int,type:String="DEFAULT")->Turret:
	var turret=load("res://TurretScripts/turretbase.tscn").instantiate() as Turret;
	turret.type=color;
	turret.stacks=lvl;
	turret.extension=type;
	if type!="DEFAULT":
		turret.isBasic=false;
		util.p("a non basic turret has been created, impl rquired","Bodo","Not good");
	
	return turret;
	

# Called when the node enters the scene tree for the first time.
func _ready():
	setUpTower();	
	
	pass # Replace with function body.


func setUpTower():
	if extension==0:
		extension=Stats.TurretExtension.DEFAULT;
	$Base.texture=load("res://Assets/Turrets/Bases/"+Stats.getStringFromEnum(type)+Stats.getStringFromEnumExtension(extension)+"_base.png")
	var barreltext=load("res://Assets/Turrets/Barrels/"+Stats.getStringFromEnum(type)+Stats.getStringFromEnumExtension(extension)+"_barrel.png")
	$Barrel.texture=barreltext;
	$Barrel/second.texture=barreltext;
	$Barrel/third.texture=barreltext;
	
	
	cooldown=Stats.getCooldown(type,extension);
	damage=Stats.getDamage(type,extension);
	speed=Stats.getCooldown(type,extension);
	
	if type==Stats.TurretColor.RED&&extension==Stats.TurretExtension.DEFAULT:
		projectile=Projectile.create(type,damage*damagefactor,speed*speedfactor,self,extension);
		projectile.z_index=-1;
	else:
		projectile=Projectile.create(type,damage*damagefactor,speed*speedfactor,self,extension)	
		
	$EnemyDetector.setRange(Stats.getRange(type,extension))
	pass;

var target;
var buildup=0;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _draw():
	if target==null:
		return
	
	if inRange():
		
		draw_line(Vector2(0,0),-(global_position-target.global_position),Color(5*sin(Time.get_ticks_usec()),0.2*sin(Time.get_ticks_usec()),0.5*sin(Time.get_ticks_usec()),buildup),10*buildup*sin(Time.get_ticks_usec()),true)
	
		
	pass;
func _process(delta):
	

	if inRange():
		
		
		if buildup<=1:
			buildup=buildup+1*delta*2;
		var target=$EnemyDetector.enemiesInRange[0];
		direction=(target.global_position-self.global_position).normalized();
		$Barrel.rotation=direction.angle() + PI / 2.0;
		
		if type==Stats.TurretColor.RED&&extension==Stats.TurretExtension.DEFAULT:
			projectile.rotate(360*2*delta);
		if !onCooldown:
			if type==Stats.TurretColor.RED&&extension==Stats.TurretExtension.DEFAULT:
				for e in $EnemyDetector.enemiesInRange:
					e.hit(type,self.damage)
					projectile.playHitSound();	
				$Timer.start(cooldown*cooldownfactor);		
				onCooldown=true;
				return;
			if type==Stats.TurretColor.RED&&extension==Stats.TurretExtension.REDLASER:
				
				var sound=projectile.get_node("shot")
				sound.play()
				self.target=target;
				projectile.hitEnemy(target)
				queue_redraw()
				$Timer.start(cooldown*cooldownfactor);
				onCooldown=true;
				return
			
			shoot(target);
	else:
		
		self.target=null;
		buildup=0;		
	queue_redraw()		
	#debugg
	if stacks>1:
		$Barrel/second.visible=true;
	
	if stacks>2:
		$Barrel/third.visible=true;	
	
	pass;

func shoot(target):
	
	var shot=Projectile.create(type,damage*damagefactor,speed*speedfactor,self,extension);
	#add_child(shot);
	shot.global_position=$Barrel/BulletPosition.global_position;
	shot.shoot(target);
	
	if stacks>1:
		var sshot=Projectile.create(type,damage*damagefactor,speed*speedfactor,self,extension);
		#add_child(sshot);
		sshot.global_position=$Barrel/second/BulletPosition.global_position;
		sshot.shoot(target);
	if stacks>2:
		var tshot=Projectile.create(type,damage*damagefactor,speed*speedfactor,self,extension);
		#add_child(tshot);
		tshot.global_position=$Barrel/third/BulletPosition.global_position;
		tshot.shoot(target);
		
	$Timer.start(cooldown*cooldownfactor);
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
