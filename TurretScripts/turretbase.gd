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

static var camera;



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
	$AudioStreamPlayer2D.stream=load("res://Sounds/Soundeffects/"+Stats.getStringFromEnum(type)+Stats.getStringFromEnumExtension(extension)+"_shot.wav")
	
	
	cooldown=Stats.getCooldown(type,extension);
	damage=Stats.getDamage(type,extension);
	speed=Stats.getMissileSpeed(type,extension);
	
	if type==Stats.TurretColor.RED:
		projectile=Projectile.create(type,damage*damagefactor,speed*speedfactor,self,extension);
		projectile.z_index=-1;
		$AudioStreamPlayer2D.finished.connect(func(): if inRange():$AudioStreamPlayer2D.play)
	
		
	$EnemyDetector.setRange(Stats.getRange(type,extension))
	pass;

var target;
var buildup=0;
var targetposition;
static var sounds=0;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _draw():
	if type==Stats.TurretColor.RED&&extension==Stats.TurretExtension.REDLASER:
		draw_redlaser()
		
	pass;
func draw_redlaser():
	if target!=null:
		targetposition=target.global_position;
	if target==null&&buildup<=0:
		return
	var thickness=5;
	if buildup>0:
		direction=(targetposition-self.global_position).normalized();
		$Barrel.rotation=direction.angle() + PI / 2.0;
		var color=Color(500,0.2+(0.2*buildup*sin(Time.get_ticks_usec())),0.2+(0.2*buildup*sin(Time.get_ticks_usec())),buildup)
		color=color.lightened(0.5*sin(Time.get_ticks_usec()))
		
		draw_line($Barrel/BulletPosition.position.rotated($Barrel.rotation),-(global_position-targetposition),color,thickness*buildup,true)
		draw_line($Barrel/BulletPosition.position.rotated($Barrel.rotation),-(global_position-targetposition),color,thickness*buildup+(3*buildup*sin(Time.get_ticks_usec())),true)
		
		if stacks>=2:
			draw_line(($Barrel/second.position+$Barrel/second/BulletPosition.position).rotated($Barrel.rotation),-(global_position-(targetposition)-($Barrel/second.position-$Barrel/second/BulletPosition.position).rotated($Barrel.rotation)),color,thickness/2*buildup,true)
			draw_line(($Barrel/second.position+$Barrel/second/BulletPosition.position).rotated($Barrel.rotation),-(global_position-(targetposition)-($Barrel/second.position-$Barrel/second/BulletPosition.position).rotated($Barrel.rotation)),color,thickness*buildup+(3*buildup*sin(Time.get_ticks_usec())),true)
		if stacks>=3:
			draw_line(($Barrel/third.position+$Barrel/third/BulletPosition.position).rotated($Barrel.rotation),-(global_position-(targetposition)-($Barrel/third.position-$Barrel/third/BulletPosition.position).rotated($Barrel.rotation)),color,thickness/2*buildup,true)
			draw_line(($Barrel/third.position+$Barrel/third/BulletPosition.position).rotated($Barrel.rotation),-(global_position-(targetposition)-($Barrel/third.position-$Barrel/third/BulletPosition.position).rotated($Barrel.rotation)),color,thickness*buildup+(3*buildup*sin(Time.get_ticks_usec())),true)
		
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
				
				if camera!=null:
					var mod=camera.zoom.y-3;
					$AudioStreamPlayer2D.volume_db=mod*10
					
				if !$AudioStreamPlayer2D.playing&&sounds<25:
					$AudioStreamPlayer2D.play()
					sounds=sounds+1
					
				self.target=target;
				projectile.hitEnemy(target)
				
				queue_redraw()
				$Timer.start(cooldown*cooldownfactor);
				onCooldown=true;
				return
			
			shoot(target);
	elif buildup>0:
		buildup=buildup-2*delta;		
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


func _on_audio_stream_player_2d_finished():
	sounds=sounds-1
	pass # Replace with function body.
