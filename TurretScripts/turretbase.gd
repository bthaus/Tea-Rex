
extends Node2D
class_name Turret

@export var range = 1;
@export var isBasic = true;
@export var type: Stats.TurretColor;
@export var stacks: int = 1;
@export var extension: Stats.TurretExtension;

var shooter;
var projectile;

var onCooldown = false;
var direction: Vector2;

var speed;
var cooldown;
var cdt;
var damage;
var turretRange;
var trueRangeSquared;
var speedfactor = 1;
var damagefactor = 1;
var cooldownfactor = 1;

var lightamount = 1.5;
var killcount = 0;
var damagedealt = 0
var doFunction:Callable
var rowcounterstart=0;
var rowcounterend=0

static var camera;
var instantHit = false;
var baseinstantHit = false;
static var baseFactory: BaseFactory = load("res://base_factory.tscn").instantiate() as BaseFactory
var base: Base;
var placed = true;
static var turrets = []
var coveredCells=[]
var recentCells=[]
var cardBuddys=[]
static func create(color: Stats.TurretColor, lvl: int, type: Stats.TurretExtension=Stats.TurretExtension.DEFAULT) -> Turret:
	var turret = load("res://TurretScripts/turretbase.tscn").instantiate() as Turret;
	if turret.collisionReference==null:
		turret.collisionReference=GameState.gameState.collisionReference
	turret.type = color;
	turret.stacks = lvl;
	turret.extension = type;
	return turret;
	
var id;
static var counter = 0;
static var collisionReference:CollisionReference;
var waitingDelayed=false;
static var inhandTurrets=[]
# Called when the node enters the scene tree for the first time.
func _ready():
	if placed:
		turrets.append(self)
	else:
		inhandTurrets.append(self)
		
	counter = counter + 1;
	print(str(counter) + "turrets built")
	id = counter;
	#if not placed:
		#$Button.mouse_filter=2
	
	setUpTower();
	if not placed:
		z_index=1;	
		base.z_index=1;
		$LVL.visible=false;
	GameState.gameState.start_combat_phase.connect(func():
		globlight=false;
		melight=false;
		resetLight()
		waitingForMinions=false;
		waitingDelayed=true;
		get_tree().create_timer(5).timeout.connect(func():waitingDelayed=false)
		
		)
	GameState.gameState.start_build_phase.connect(func():
		resetLight()
		waitingForMinions=true;
		)	
	pass # Replace with function body.
func resetLight():
	$Tile.modulate=Color(1+lightamount,1+lightamount,1+lightamount)
	pass;	
func checkPosition(off):
	if !placed:return
	$Tile.visible=!off;
	base.visible=!off;
	$Button.visible=!off;
	$VisibleOnScreenNotifier2D.visible=true;
	pass ;
	
func _notification(what):
	if (what == NOTIFICATION_PREDELETE)&&projectile != null:
		projectile.free()
var mapPosition;
var referenceCells=[]		
func setupCollision(clearing):
	if not placed: return;
	if type==Stats.TurretColor.YELLOW: return;
	
	if clearing:coveredCells.clear()
	recentCells.clear()
	
	if type==Stats.TurretColor.RED and extension==Stats.TurretExtension.DEFAULT:
		coveredCells.append_array(collisionReference.getNeighbours(global_position,referenceCells))
		
	else:
		coveredCells.append_array(collisionReference.getCellReferences(global_position,turretRange,self,referenceCells))
	pass;	
	
func setupDoCall():
	if extension==Stats.TurretExtension.DEFAULT:
		doFunction=get(Stats.TurretColor.find_key(type)+"_do")
		print("setting up for: "+Stats.TurretColor.find_key(type)+"_do")
		
	else:
		doFunction=get(Stats.TurretExtension.find_key(extension)+"_do")	
		print("setting up for: "+Stats.TurretExtension.find_key(extension)+"_do")
		
	
	pass;		
var minions;
func setUpTower():
	minions=GameState.gameState.get_node("MinionHolder")
	#GameState.gameState.getCamera().scrolled.connect(checkPosition)
	#if not placed:
	#	$Button.queue_free()
		#$Button.mouse_filter=2
		
	GameState.gameState.start_combat_phase.connect(func():
		resetLight()
		return )
	GameState.gameState.start_build_phase.connect(func():
		if GameState.gameState.wave%5==0:
			setupCollision(false)
		return )	
	if extension == 0:
		extension = Stats.TurretExtension.DEFAULT;
	if base != null:
		base.queue_free()
	#else:
		#$EnemyDetector.setRange(Stats.getRange(type, extension)*2.5)
	base = baseFactory.getBase(type, extension);
	add_child(base)
	base.global_position = global_position
	base.setLevel(stacks)
	$LVL.text = str(stacks)
	$AudioStreamPlayer2D.stream = load("res://Sounds/Soundeffects/" + Stats.getStringFromEnum(type) + Stats.getStringFromEnumExtension(extension) + "_shot.wav")
	instantHit = Stats.getInstantHit(type, extension);
	baseinstantHit = instantHit;
	turretRange=Stats.getRange(type, extension);
	trueRangeSquared=turretRange*Stats.block_size
	trueRangeSquared=trueRangeSquared*trueRangeSquared;
	cooldown = Stats.getCooldown(type, extension);
	damage = Stats.getDamage(type, extension);
	speed = Stats.getMissileSpeed(type, extension);
	if projectile == null: projectile = Projectile.create(type, damage * damagefactor, speed * speedfactor, self, extension);
	projectile.visible = false;
	if type == Stats.TurretColor.RED:
		projectile.scale = Vector2(1, 1)
		projectile.z_index = 0;
		projectile.visible = placed
		projectile.modulate = Color(1, 1, 1, 1)
		$AudioStreamPlayer2D.finished.connect(func(): if inRange(): $AudioStreamPlayer2D.play)
	$Tile.texture=load("res://Assets/Tiles/tile_"+Stats.getStringFromEnumLowercase(type)+".png")
	if placed:
		lightamount = GameState.gameState.lightThresholds.getLight(global_position.y)*stacks
		
		$Tile.modulate=Color(1+lightamount,1+lightamount,1+lightamount)
	
	#$Ambient.energy=lightamount/ambientDropOff
	util.p("my light amount is: " + str(lightamount))
	resetLight()
	$Drawpoint.base = base
	point.type = type
	setupCollision(true)
	setupDoCall()
	pass ;

var target;
var buildup = 0;
var targetposition;
static var sounds = 0;
var ambientDropOff = 3;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _draw():
	if type == Stats.TurretColor.RED&&extension == Stats.TurretExtension.REDLASER:
		draw_laser()
	if	type == Stats.TurretColor.BLUE&&extension == Stats.TurretExtension.BLUEFREEZER:
		draw_laser()
	if Stats.TurretColor.YELLOW == type:
		draw_SniperLine()
	pass ;
func addKill():
	killcount = killcount + 1;
	pass ;
func draw_SniperLine():
	if target != null: targetposition = target.global_position;
	if buildup==0: return;	
	if targetposition==null:return;
	if buildup < 0: buildup=0
		
	
	direction = (targetposition - self.global_position).normalized();
	#$Barrel.rotation=direction.angle() + PI / 2.0;
	var color = Color(1, 1, 1, 1 * buildup)
	var thickness = 1 * buildup;
	for b in base.getBarrels():
		var bgp = b.get_child(0).global_position;
		var bp = b.get_child(0).position;
		draw_line((b.position + bp).rotated(base.rotation), -(global_position - (targetposition) - (b.position - bp).rotated(base.rotation)), color, thickness, true)
		draw_line((b.position + bp).rotated(base.rotation), -(global_position - (targetposition) - (b.position - bp).rotated(base.rotation)), color, thickness, true)
	
	pass ;
	
@onready var point = $Drawpoint
func draw_laser():
	
	
	if target != null:
		targetposition = target.global_position;
	if target == null&&buildup < 0:
		buildup=0;
		point.buildup = buildup
		point.queue_redraw();
		return
	point.type=extension	
	point.target = target
	point.buildup = buildup
	point.targetposition = targetposition
	point.direction = direction
	point.queue_redraw();
	return

	pass ;
	
func reduceCooldown(delta):

	#if GameState.gameState.phase==Stats.GamePhase.BUILD:
	#	light.energy=1;
	#	return
	var ml = lightamount ;
	if not onCooldown:
		return ;
	var increase = (ml / cooldown) * delta
	$Tile.modulate=Color($Tile.modulate.r+increase,$Tile.modulate.r+increase,$Tile.modulate.r+increase)
	#light.energy = light.energy + increase
	#if light.energy > ml: light.energy = ml;
	
	#$Ambient.energy=$Ambient.energy+increase
	#if$Ambient.energy>ml/ambientDropOff: $Ambient.energy=ml/ambientDropOff;
	
	remap(255, 0, 0, 1, 254)
	cdt = cdt - delta;
	if cdt < 0:
		onCooldown = false;
	pass

var oldval = 1;
static var globlight = false;
var melight = false;
func highlight(delta):
	if GameState.gameState.phase == Stats.GamePhase.BATTLE: return
	globlight = true;
	melight = true;
	#create_tween().tween_property(light, "energy", 3, 1)
	#if light.energy>=3:return
	
	#light.energy=light.energy+9*delta;
	pass
	
func de_highlight(delta):
	if GameState.gameState.phase == Stats.GamePhase.BATTLE: return
	globlight = false;
	melight = false;
	#create_tween().tween_property(light, "energy", lightamount, 1)
	#light.energy=lightamount
	pass
	
func checkLight(delta):
	if GameState.gameState.phase == Stats.GamePhase.BATTLE: return
	
	if !placed:
		lightamount = GameState.gameState.lightThresholds.getLight(global_position.y)
	
	#if light.energy<=0:light.energy=0;return
	#if globlight&&!melight:
		#create_tween().tween_property(light, "energy", 0, 1)
	#if !globlight&&light.energy < lightamount:
		#print(light.energy)
		#light.energy = lightamount
		#create_tween().tween_property(light, "energy", lightamount, 1)
		#light.energy=light.energy-9*delta;
	
	#if !globlight&&light.energy < lightamount:
	#	create_tween().tween_property(light, "energy", lightamount, 1)
		##light.energy = lightamount
	#	#return
	#if melight:
		#return	
	
	#light.energy=light.energy-9*delta;
	pass ;
	
func _input(event):
	if placed: return ;
	if event is InputEventMouseMotion:
		
		print("processing?")
		
		
	pass ;
var waitingForMinions=false;

func searchForMinionsInRecent()-> bool:
	for cell in recentCells:
		if not cell.is_empty():
			target=cell.back()
			if target!=null:
				return true;
			else:
				for m in cell:
					if not is_instance_valid(m):
						print("nullreference removed")
						cell.erase(m)
					else:
						target=m	
	return false;					
	pass;	
func getTarget():
	if type==Stats.TurretColor.YELLOW and minions.get_child_count()>0:
		#there might be nullvalues inside there, because the minions are freed and might not be properly removed from the array. so this should be fixed, becuase the pick random would
		#return a nullvalue, which is a sign of "im not responsible for a target"
		target=minions.get_children().pick_random()
		
		return
	if minions.get_child_count()==0:
		return;
	#check cells where minions have been found recently
	if searchForMinionsInRecent():return
				
	#check if any minions are in covered rows		
	#var minionpresent=false;		
	#for i in range (rowcounterend-rowcounterstart):
	#	if collisionReference.rowCounter[rowcounterstart+i]	> 0:
	#		minionpresent=true;
	#		break;	
	#if not minionpresent:
	#	waitingForMinions=true;
		#get_tree().create_timer(0.21).timeout.connect(func(): waitingForMinions=false)
		#return		
	#go through all covered cells as fallback. potential opt: traverse pathcells first, traverse rows where rowcounter >0 first		
	for cell in coveredCells:
		if !cell.is_empty():
			target=cell.back()
			if target!=null:
				if recentCells.find(cell)==-1:
					recentCells.push_back(cell)
				return;
			else:
				for m in cell:
					if not is_instance_valid(m):
						print("nullreference removed")
						cell.erase(m)
					else:
						target=m
	pass;
func checkTarget():
	if type==Stats.TurretColor.YELLOW:
		return
	var distancesquared=abs(global_position.distance_squared_to(target.global_position))
	if distancesquared>abs(trueRangeSquared):
		target=null;
	
	pass;	
func RED_do(delta):
	#check if blade should be rotating
	if buildup > 0&&projectile != null:
			projectile.rotate((180 * buildup * - 1) * 2 * delta);
	#if no target, slowly stop rotating the blade 	
	if target==null && buildup > 0:
		buildup = buildup - 0.01 * delta;
	#if no target is present, stop the rest	
	if target==null: return	
	#if target present and buildup is lower than maxrotation, start rotating		
	if buildup < 0.01:
		buildup = buildup + 0.01 * delta;
	#if not on cooldown, deal damage	
	if !onCooldown:
			for cell in coveredCells:
				for e in cell:
					if !is_instance_valid(e):continue
					if e.hit(type, self.damage * stacks): addKill()
					addDamage(self.damage*stacks)
					projectile.playHitSound();
			startCooldown(cooldown * cooldownfactor)		
	
						
	pass;
func base_do():
	if target!=null:
		if !onCooldown:
			shoot(target);	
		
	pass;			
func BLUE_do(delta):
	base_do()
	pass;	
func GREEN_do(delta):
	base_do()
	pass;	
func YELLOW_do(delta):
	if type == Stats.TurretColor.YELLOW&&extension == Stats.TurretExtension.DEFAULT:
		buildup = buildup - 4 * delta;
	if target!=null:
		if!onCooldown:
				if camera != null:
					var mod = camera.zoom.y - 3;
					$AudioStreamPlayer2D.volume_db = 10 + mod * 10
					
				#if !$AudioStreamPlayer2D.playing&&sounds<25:
				$AudioStreamPlayer2D.play()
				sounds = sounds + 1
				projectile.hitEnemy(target)
				buildup = 1;
				queue_redraw()
				startCooldown(cooldown * cooldownfactor)
				onCooldown = true;
	if buildup > 0 and target==null:
			buildup = buildup - 2 * delta;
		
	queue_redraw()				
		
	pass;	
func REDLASER_do(delta):
	
	if !$AudioStreamPlayer2D.playing and buildup > 0:
		$AudioStreamPlayer2D.play()
	if buildup < 0.1:
		$AudioStreamPlayer2D.stop()
		
	if target!=null and buildup <= 1:
		buildup = buildup + 1 * delta * 2;	
	if target==null and buildup > 0 :
		buildup = buildup - 2 * delta;		
	
	
	queue_redraw()		
	base_do()	
func BLUEFREEZER_do(delta):
	if target!=null and buildup <= 1:
		buildup = buildup + 1 * delta * 2;	
	if target==null and buildup > 0 :
		buildup = buildup - 2 * delta;		
	queue_redraw()		
	base_do()	
	pass;	
	
		
				
	pass;	
func BLUELASER_do(delta):
	base_do()
	pass;	
func GREENPOISON_do(delta):
	base_do()
	pass;	
func YELLOWMORTAR_do(delta):
	base_do()
	pass;
func do(delta):

	#größter pfusch auf erden. wenn ein block in der hand ist soll er seine range anzeigen, wenn nicht dann nicht.
	#der turm weiß nur nie ob er in der hand ist oder nicht -> card intercepten
	if !placed:
		if Card.contemplatingInterrupt: $Button.mouse_filter = 2
		else:
			$Button.mouse_filter = 0;
	#checkDetectorVisibility(delta)
	if GameState.gameState == null: return
	if not placed:return
	reduceCooldown(delta)
	
	if !onCooldown:
		if target!=null:checkTarget()	
		if target==null:getTarget()
		if projectile == null: projectile = Projectile.create(type, damage, speed, self, extension)
			
	if target!=null:
		direction = (target.global_position - self.global_position).normalized();
		base.rotation = direction.angle() + PI / 2.0;
	doFunction.call(delta)	
	
	pass ;
func startCooldown(time):
	#light.energy = 0
	$Tile.modulate=Color(1,1,1)
	cdt = time;
	onCooldown = true;
	pass ;
func shoot(target):
	var barrels = base.getBarrels();
	for b in barrels:
		var bp = b.get_child(0).global_position;
		var shot = Projectile.create(type, damage * damagefactor, speed * speedfactor, self, extension);
		shot.global_position = bp;
		if type == Stats.TurretColor.YELLOW&&Stats.TurretExtension.YELLOWMORTAR == extension:
				Explosion.create(Stats.TurretColor.YELLOW, 0, bp, self, 0.1)
		if instantHit:
			shot.global_position = target.global_position
			shot.hitEnemy(target)
			shot.global_position = global_position
		else:
			shot.shoot(target);
	startCooldown(cooldown * cooldownfactor)
	pass ;
func inRange():
	#return $EnemyDetector.enemiesInRange.size() > 0;
	pass
	
	


func levelup(lvl: int=1):
	lightamount=lightamount/stacks
	stacks = lvl;
	lightamount=lightamount*stacks
	
	setUpTower()
	$LVL.text = str(stacks)
	base.setLevel(stacks)
	pass ;

func _on_timer_timeout():
	onCooldown = false;
	pass # Replace with function body.

func _on_audio_stream_player_2d_finished():
	sounds = sounds - 1
	pass # Replace with function body.
func showRangeOutline():
	if type==Stats.TurretColor.YELLOW:
		return
	if placed:
		if type!=Stats.TurretColor.YELLOW:
			for c in referenceCells:
				var pos=collisionReference.getGlobalFromReference(c)
				GameState.gameState.gameBoard.show_outline(pos)
				
	else:	
		
		var showCells=[]
		if type==Stats.TurretColor.RED&&Stats.TurretExtension.DEFAULT==extension:
			collisionReference.getNeighbours(global_position,showCells)
		else:
			collisionReference.getCellReferences(global_position,turretRange,self,showCells,true)
		for c in showCells:
			var pos=collisionReference.getGlobalFromReference(c)
			GameState.gameState.gameBoard.show_outline(pos)
	pass;
func _on_button_mouse_entered():
	showRangeOutline()
	for t in cardBuddys:
		t.showRangeOutline()
	if placed:
		GameState.gameState.menu.showDescription("This turret defeated " + str(str(killcount) + " minions and dealt " + str(int(damagedealt)) + "damage."))
		
	elif extension != 1:
		GameState.gameState.menu.showDescription(Stats.getDescription(Stats.TurretExtension.keys()[extension - 1]))
	else:
		GameState.gameState.menu.showDescription(Stats.getDescription(Stats.getStringFromEnum(type)))
	
	GameState.gameState.showCount(killcount, damagedealt)
	
	
	#create_tween().tween_property(enemydetector,"modulate",)
	pass # Replace with function body.
var detectorvisible = false;

var m = 0;

func checkDetectorVisibility(delta):
	
	if (detectorvisible and m >= 1) or (not detectorvisible and m <= 0):
		return ;
		
	if detectorvisible:
		m = m + 1.5 * delta;
	else:
		m = m - 4 * delta;
	m = clamp(m, 0, 1)
	
	#$EnemyDetector.modulate.a = m
	pass
func addDamage(Damage):
	damagedealt = damagedealt + Damage;
	
	pass ;

func _on_button_mouse_exited():
	GameState.gameState.menu.hideDescription()
	detectorvisible = false;
	GameState.gameState.hideCount()
	GameState.gameState.gameBoard.clear_range_outline()
	pass # Replace with function body.

func _on_button_pressed():
	#if its a buildaction
	
	resetLight()
	
	if Card.isCardSelected: return ;
	
	pass # Replace with function body.

func _on_visible_on_screen_notifier_2d_screen_exited():
	checkPosition(true)
	pass # Replace with function body.

func _on_visible_on_screen_notifier_2d_screen_entered():
	checkPosition(false)
	pass # Replace with function body.
