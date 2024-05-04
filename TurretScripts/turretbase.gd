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

var lightamount=1.5;
var killcount=0;
var damagedealt=0
static var camera;
var instantHit=false;
static var baseFactory:BaseFactory=load("res://base_factory.tscn").instantiate() as BaseFactory
var base:Base;
var placed=true;

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
	if not placed:
		$Button.queue_free()
	
	if extension==0:
		extension=Stats.TurretExtension.DEFAULT;
	base=baseFactory.getBase(type,extension);
	add_child(base)
	base.global_position=global_position
	$AudioStreamPlayer2D.stream=load("res://Sounds/Soundeffects/"+Stats.getStringFromEnum(type)+Stats.getStringFromEnumExtension(extension)+"_shot.wav")
	instantHit=Stats.getInstantHit(type,extension);
	cooldown=Stats.getCooldown(type,extension);
	damage=Stats.getDamage(type,extension);
	speed=Stats.getMissileSpeed(type,extension);
	projectile=Projectile.create(type,damage*damagefactor,speed*speedfactor,self,extension);
	projectile.visible=false;
	if type==Stats.TurretColor.RED:
		projectile.visible=false;
		projectile.z_index=-1;
		projectile.visible=true;
		$AudioStreamPlayer2D.finished.connect(func(): if inRange():$AudioStreamPlayer2D.play)
	match type:
		2:$EnemyDetector.modulate=Color(0,1,0)
		3:$EnemyDetector.modulate=Color(1,0,0)
		4:$EnemyDetector.modulate=Color(1,1,0)
		5:$EnemyDetector.modulate=Color(0,1,1)
		
	lightamount=GameState.gameState.lightThresholds.getLight(global_position.y)
	#$Ambient.energy=lightamount/ambientDropOff
	util.p("my light amount is: "+str(lightamount  ))
	$PointLight2D.energy=lightamount	
	$EnemyDetector.setRange(Stats.getRange(type,extension))
	pass;

var target;
var buildup=0;
var targetposition;
static var sounds=0;
var ambientDropOff=3;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _draw():
	if type==Stats.TurretColor.RED&&extension==Stats.TurretExtension.REDLASER:
		draw_redlaser()
	if Stats.TurretColor.YELLOW==type:
		draw_SniperLine()	
	pass;
func addKill():
	killcount=killcount+1;
	pass;	
func draw_SniperLine():
		if target!=null:
			targetposition=target;
		if target==null&&buildup<=0:
			return
		
		direction=(targetposition-self.global_position).normalized();
		#$Barrel.rotation=direction.angle() + PI / 2.0;
		var color=Color(1,1,1,1*buildup)
		var thickness=1*buildup;
		for b in base.getBarrels():
			var bgp=b.get_child(0).global_position;
			var bp=b.get_child(0).position;
			draw_line((b.position+bp).rotated(base.rotation),-(global_position-(targetposition)-(b.position-bp).rotated(base.rotation)),color,thickness,true)
			draw_line((b.position+bp).rotated(base.rotation),-(global_position-(targetposition)-(b.position-bp).rotated(base.rotation)),color,thickness,true)
		
		
		pass;
	
	
func draw_redlaser():
	
	if target!=null:
		targetposition=target.global_position;
	if target==null&&buildup<=0:
		return
	var thickness=3;
	if buildup>0&&Stats.TurretColor.RED==type:
		direction=(targetposition-self.global_position).normalized();
	#	$Barrel.rotation=direction.angle() + PI / 2.0;
		var color=Color(500,0.2+(0.2*buildup*sin(Time.get_ticks_usec())),0.2+(0.2*buildup*sin(Time.get_ticks_usec())),buildup)
		color=color.lightened(0.5*sin(Time.get_ticks_usec()))
		var it=0;
		for b in base.getBarrels():
			it=it+1;
			if it==1:
				thickness=5;
			else:
				thickness=1
			var bgp=b.get_child(0).global_position;
			var bp=b.get_child(0).position;
			draw_line((b.position+bp).rotated(base.rotation),-(global_position-(targetposition)-(b.position-bp).rotated(base.rotation)),color,thickness/2*buildup,true)
			draw_line((b.position+bp).rotated(base.rotation),-(global_position-(targetposition)-(b.position-bp).rotated(base.rotation)),color,thickness*buildup+(3*buildup*sin(Time.get_ticks_usec())),true)
		
	pass;
	
func reduceCooldown(delta):
	

	#if GameState.gameState.phase==Stats.GamePhase.BUILD:
	#	$PointLight2D.energy=1;
	#	return
	var ml=lightamount*stacks;
	if not onCooldown:
		return;
	var increase=(ml/cooldown)*delta
	
	
	$PointLight2D.energy=$PointLight2D.energy+increase
	if$PointLight2D.energy>ml: $PointLight2D.energy=ml;
	
	#$Ambient.energy=$Ambient.energy+increase
	#if$Ambient.energy>ml/ambientDropOff: $Ambient.energy=ml/ambientDropOff;
	
	remap(255,0,0,1,254)
	cdt=cdt-delta;
	if cdt<0:
		onCooldown=false;
	pass
func _process(delta):
	if not placed:
		return;
	reduceCooldown(delta)
	if type==Stats.TurretColor.YELLOW&&extension==Stats.TurretExtension.DEFAULT:
		buildup=buildup-4*delta;	

	if inRange():
		base.setLevel(stacks)
		if projectile==null:
			projectile=Projectile.create(type,damage,speed,self,extension)
		
	
		if buildup<=1 and (type==Stats.TurretColor.RED&&extension==Stats.TurretExtension.REDLASER):
			buildup=buildup+1*delta*2;
		var target=$EnemyDetector.enemiesInRange[0];
		
		direction=(target.global_position-self.global_position).normalized();
		base.rotation=direction.angle() + PI / 2.0;
		
		if type==Stats.TurretColor.RED&&extension==Stats.TurretExtension.DEFAULT:
			projectile.rotate(360*2*delta);
		if !onCooldown:
			if type==Stats.TurretColor.RED&&extension==Stats.TurretExtension.DEFAULT:
				for e in $EnemyDetector.enemiesInRange:
					if e.hit(type,self.damage):addKill()
					addDamage(self.damage)
					projectile.playHitSound();	
				startCooldown(cooldown*cooldownfactor)		
				
				return;
			if (type==Stats.TurretColor.RED&&extension==Stats.TurretExtension.REDLASER):
				
				if camera!=null:
					var mod=camera.zoom.y-3;
					$AudioStreamPlayer2D.volume_db=mod*10
					
				#if !$AudioStreamPlayer2D.playing&&sounds<25:
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
					
				#if !$AudioStreamPlayer2D.playing&&sounds<25:
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
	
	
	pass;
func startCooldown(time):
	$PointLight2D.energy=0
	#$Ambient.energy=0
	cdt=time;
	onCooldown=true;
	pass;
func shoot(target):
	var barrels=base.getBarrels();
	for b in barrels:
		var bp=b.get_child(0).global_position;
		var shot=Projectile.create(type,damage*damagefactor,speed*speedfactor,self,extension);
	#add_child(shot);
		shot.global_position=bp;
		if type==Stats.TurretColor.YELLOW&&Stats.TurretExtension.YELLOWMORTAR==extension:
				Explosion.create(Stats.TurretColor.YELLOW,0,bp,self,0.1)
		if instantHit:
			projectile.global_position=target.global_position
			projectile.hitEnemy(target)
			projectile.global_position=global_position
		else:
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

func levelup(lvl:int=1):
	stacks=lvl;
	base.setLevel(stacks)
	pass;
func _on_timer_timeout():
	onCooldown=false;
	pass # Replace with function body.


func _on_audio_stream_player_2d_finished():
	sounds=sounds-1
	pass # Replace with function body.


func _on_button_mouse_entered():
	var field=GameState.gameState.menu.get_node("CanvasLayer/UI/Description")
	if extension!=1:
		field.text=Stats.getDescription(Stats.TurretExtension.keys()[extension-1])
	else:
		field.text=Stats.getDescription(Stats.getStringFromEnum(type))
	
	$EnemyDetector.visible=true
	GameState.gameState.showCount(killcount,damagedealt)
	pass # Replace with function body.
func addDamage(Damage):
	damagedealt=damagedealt+Damage;
	
	pass;

func _on_button_mouse_exited():
	GameState.gameState.menu.get_node("CanvasLayer/UI/Description").text=" "
	$EnemyDetector.visible=false
	GameState.gameState.hideCount()
	pass # Replace with function body.
