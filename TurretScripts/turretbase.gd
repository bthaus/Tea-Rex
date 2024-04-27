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
var cdt;
var damage;

var speedfactor=1;
var damagefactor=1;
var cooldownfactor=1;

static var camera;
var instantHit=false;


static func create(color:Stats.TurretColor, lvl:int, type:Stats.TurretExtension=Stats.TurretExtension.DEFAULT)->Turret:
	var turret=load("res://TurretScripts/turretbase.tscn").instantiate() as Turret;
	turret.type=color;
	turret.stacks=lvl;
	turret.extension=type;
	return turret;
	

# Called when the node enters the scene tree for the first time.
func _ready():
	setUpTower();	
	
	pass # Replace with function body.

func setUpTower():
	if extension==0:
		extension=Stats.TurretExtension.DEFAULT;
	var text=load("res://Assets/Turrets/Bases/"+Stats.getStringFromEnum(type)+Stats.getStringFromEnumExtension(extension)+"_base.png")
	$Base.texture=text
	var barreltext=load("res://Assets/Turrets/Barrels/"+Stats.getStringFromEnum(type)+Stats.getStringFromEnumExtension(extension)+"_barrel.png")
	$Barrel.texture=barreltext;
	$Barrel/second.texture=barreltext;
	$Barrel/third.texture=barreltext;
	$AudioStreamPlayer2D.stream=load("res://Sounds/Soundeffects/"+Stats.getStringFromEnum(type)+Stats.getStringFromEnumExtension(extension)+"_shot.wav")
	match type:
		#1:$PointLight2D.color=Color(Color.BLUE)
		#2: $PointLight2D.color=Color(Color.GREEN)
		#3: $PointLight2D.color=Color(Color.RED)
		4: #$PointLight2D.color=Color(Color.YELLOW); 
			instantHit=true;
	cooldown=Stats.getCooldown(type,extension);
	damage=Stats.getDamage(type,extension);
	speed=Stats.getMissileSpeed(type,extension);
	projectile=Projectile.create(type,damage*damagefactor,speed*speedfactor,self,extension);
	if type==Stats.TurretColor.RED:
		
		
		projectile.visible=false;
		projectile.z_index=-1;
		projectile.visible=true;
		$AudioStreamPlayer2D.finished.connect(func(): if inRange():$AudioStreamPlayer2D.play)
	if type==Stats.TurretColor.RED and extension==Stats.TurretExtension.REDLASER:
		$Base.visible=false
		$Barrel.scale=Vector2(-1,-1)
		$Barrel.offset=Vector2(-0,15)
		$Barrel/second.position=$Barrel/second.position*1.5
		$Barrel/third.position=$Barrel/third.position*1.5
		
		
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
	if Stats.TurretColor.YELLOW==type:
		draw_SniperLine()	
	pass;
func draw_SniperLine():
		if target!=null:
			targetposition=target;
		if target==null&&buildup<=0:
			return
		
		direction=(targetposition-self.global_position).normalized();
		$Barrel.rotation=direction.angle() + PI / 2.0;
		var color=Color(1,1,1,1*buildup)
		var thickness=1*buildup;

		draw_line($Barrel/BulletPosition.position.rotated($Barrel.rotation),-(global_position-targetposition),color,thickness,true)
		draw_line($Barrel/BulletPosition.position.rotated($Barrel.rotation),-(global_position-targetposition),color,thickness,true)
		
		if stacks>=2:
			draw_line(($Barrel/second.position+$Barrel/second/BulletPosition.position).rotated($Barrel.rotation),-(global_position-(targetposition)-($Barrel/second.position-$Barrel/second/BulletPosition.position).rotated($Barrel.rotation)),color,thickness,true)
			draw_line(($Barrel/second.position+$Barrel/second/BulletPosition.position).rotated($Barrel.rotation),-(global_position-(targetposition)-($Barrel/second.position-$Barrel/second/BulletPosition.position).rotated($Barrel.rotation)),color,thickness,true)
		if stacks>=3:
			draw_line(($Barrel/third.position+$Barrel/third/BulletPosition.position).rotated($Barrel.rotation),-(global_position-(targetposition)-($Barrel/third.position-$Barrel/third/BulletPosition.position).rotated($Barrel.rotation)),color,thickness,true)
			draw_line(($Barrel/third.position+$Barrel/third/BulletPosition.position).rotated($Barrel.rotation),-(global_position-(targetposition)-($Barrel/third.position-$Barrel/third/BulletPosition.position).rotated($Barrel.rotation)),color,thickness,true)
		
		pass;
	
	
func draw_redlaser():
	if target!=null:
		targetposition=target.global_position;
	if target==null&&buildup<=0:
		return
	var thickness=5;
	if buildup>0&&Stats.TurretColor.RED==type:
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
	
func reduceCooldown(delta):
	var ml=1.5*stacks;
	if not onCooldown:
		return;
		
	$PointLight2D.energy=$PointLight2D.energy+(ml/cooldown)*delta
	if$PointLight2D.energy>ml: $PointLight2D.energy=ml;
	
	remap(255,0,0,1,254)
	cdt=cdt-delta;
	if cdt<0:
		onCooldown=false;
	pass
func _process(delta):
	reduceCooldown(delta)
	if type==Stats.TurretColor.YELLOW&&extension==Stats.TurretExtension.DEFAULT:
		buildup=buildup-4*delta;	

	if inRange():
		if projectile==null:
			projectile=Projectile.create(type,damage,speed,self,extension)
		
	
		if buildup<=1 and (type==Stats.TurretColor.RED&&extension==Stats.TurretExtension.REDLASER):
			buildup=buildup+1*delta*2;
		var target=$EnemyDetector.enemiesInRange[0];
		
		direction=(target.global_position-self.global_position).normalized();
		$Barrel.rotation=direction.angle() + PI / 2.0;
		$Base.rotation=direction.angle() + PI / 2.0;
		
		if type==Stats.TurretColor.RED&&extension==Stats.TurretExtension.DEFAULT:
			projectile.rotate(360*2*delta);
		if !onCooldown:
			if type==Stats.TurretColor.RED&&extension==Stats.TurretExtension.DEFAULT:
				for e in $EnemyDetector.enemiesInRange:
					e.hit(type,self.damage)
					projectile.playHitSound();	
				startCooldown(cooldown*cooldownfactor)		
				
				return;
			if (type==Stats.TurretColor.RED&&extension==Stats.TurretExtension.REDLASER):
				
				if camera!=null:
					var mod=camera.zoom.y-3;
					$AudioStreamPlayer2D.volume_db=mod*10
					
				if !$AudioStreamPlayer2D.playing&&sounds<25:
					$AudioStreamPlayer2D.play()
					sounds=sounds+1
					
				self.target=target;
				projectile.hitEnemy(target)
				
				queue_redraw()
				startCooldown(cooldown*cooldownfactor)
				return
			if (type==Stats.TurretColor.YELLOW&&extension==Stats.TurretExtension.DEFAULT):
				if camera!=null:
					var mod=camera.zoom.y-3;
					$AudioStreamPlayer2D.volume_db=mod*10
					
				if !$AudioStreamPlayer2D.playing&&sounds<25:
					$AudioStreamPlayer2D.play()
					sounds=sounds+1
					
				self.target=target.global_position;
				projectile.hitEnemy(target)
				buildup=1;
				queue_redraw()
				startCooldown(cooldown*cooldownfactor)
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
func startCooldown(time):
	$PointLight2D.energy=0
	cdt=time;
	onCooldown=true;
	pass;
func shoot(target):
	
	var shot=Projectile.create(type,damage*damagefactor,speed*speedfactor,self,extension);
	#add_child(shot);
	shot.global_position=$Barrel/BulletPosition.global_position;
	if type==Stats.TurretColor.YELLOW&&Stats.TurretExtension.YELLOWMORTAR==extension:
			Explosion.create(Stats.TurretColor.YELLOW,0,$Barrel/BulletPosition.global_position,self,0.1)
	if instantHit:
		projectile.global_position=target.global_position
		projectile.hitEnemy(target)
		projectile.global_position=global_position
	else:
		shot.shoot(target);
	
	if stacks>1:
		if type==Stats.TurretColor.YELLOW&&Stats.TurretExtension.YELLOWMORTAR==extension:
			Explosion.create(Stats.TurretColor.YELLOW,0,$Barrel/second/BulletPosition.global_position,self,0.3)
	
		
		if instantHit:
			projectile.global_position=target.global_position
			projectile.hitEnemy(target)
			projectile.global_position=global_position
		else:
			var sshot=Projectile.create(type,damage*damagefactor,speed*speedfactor,self,extension);
			sshot.global_position=$Barrel/second/BulletPosition.global_position;
			sshot.shoot(target);
			
	if stacks>2:
		if type==Stats.TurretColor.YELLOW&&Stats.TurretExtension.YELLOWMORTAR==extension:
			Explosion.create(Stats.TurretColor.YELLOW,0,$Barrel/third/BulletPosition.global_position,self,0.3)
	
		if instantHit:
			projectile.global_position=target.global_position
			projectile.hitEnemy(target)
			projectile.global_position=global_position
		else:
			var tshot=Projectile.create(type,damage*damagefactor,speed*speedfactor,self,extension);
			tshot.global_position=$Barrel/third/BulletPosition.global_position;
			shot.shoot(target);
		
	startCooldown(cooldown*cooldownfactor)
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
