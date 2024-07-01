extends Node2D
class_name Turret

@export var range = 1;
@export var isBasic = true;
@export var type: Stats.TurretColor;
@export var stacks: int = 1;
@export var extension: Stats.TurretExtension;


var rowcounterstart = 0;
var rowcounterend = 0
var lightamount=1
static var camera;

static var coreFactory: TurretCoreFactory
var base: TurretCore;
var placed = true;
static var turrets = []
var cardBuddys = []


var on_destroy: Array[Callable] = []
var on_built: Array[Callable] = [setUpTower]
var on_build_phase_started: Array[Callable] = []
var on_battle_phase_started: Array[Callable] = []

static func create(color: Stats.TurretColor, lvl: int, type: Stats.TurretExtension=Stats.TurretExtension.DEFAULT) -> Turret:
	var turret = load("res://TurretScripts/turretbase.tscn").instantiate() as Turret;
	if turret.collisionReference == null:
		turret.collisionReference = GameState.gameState.collisionReference
	turret.type = color;
	turret.stacks = lvl;
	turret.extension = type;
	return turret;
	
var id;
static var counter = 0;
static var collisionReference: CollisionReference;
var waitingDelayed = false;
static var inhandTurrets = []
# Called when the node enters the scene tree for the first time.
func do_all(tasks: Array[Callable]):
	for t in tasks:
		t.call()
	pass ;
func _ready():
	coreFactory=TurretCoreFactory.get_instance()
	do_all(on_built)
	
	if placed:
		turrets.append(self)
	else:
		inhandTurrets.append(self)
		
	counter = counter + 1;
	id = counter;
	if not placed:
		z_index = 1;
		base.z_index = 1;
		$LVL.visible = false;
		
	GameState.gameState.start_combat_phase.connect(func():
		do_all(on_battle_phase_started)
		globlight=false;
		melight=false;
		resetLight()
		waitingForMinions=false;
		waitingDelayed=true;
		get_tree().create_timer(5).timeout.connect(func(): waitingDelayed=false)
		
		)
	GameState.gameState.start_build_phase.connect(func():
		do_all(on_build_phase_started)
		resetLight()
		waitingForMinions=true;
		)
	pass # Replace with function body.
func resetLight():
	$Tile.modulate = Color(1 + lightamount, 1 + lightamount, 1 + lightamount)
	pass ;
func checkPosition(off):
	if !placed: return
	$Tile.visible = !off;
	base.visible = !off;
	$Button.visible = !off;
	$VisibleOnScreenNotifier2D.visible = true;
	pass ;
	
func _notification(what):
	if (what == NOTIFICATION_PREDELETE):
		do_all(on_destroy)
		
		
var mapPosition;



func setUpTower():

	on_battle_phase_started.append(resetLight)


	base = coreFactory.getBase(type, extension);
	add_child(base)
	base.global_position = global_position
	base.setLevel(stacks)
	base.setUpTower(self)
	base.placed=placed
	
	$LVL.text = str(stacks)
	$AudioStreamPlayer2D.stream = load("res://Sounds/Soundeffects/" + Stats.getStringFromEnum(type) + Stats.getStringFromEnumExtension(extension) + "_shot.wav")
	if placed:
		lightamount = GameState.gameState.lightThresholds.getLight(global_position.y)*stacks
	
	#if type == Stats.TurretColor.RED:
	#	projectile.scale = Vector2(1, 1)
	#	projectile.z_index = 0;
	#	projectile.visible = placed
	#	projectile.modulate = Color(1, 1, 1, 1)
	#	$AudioStreamPlayer2D.finished.connect(func(): if inRange(): $AudioStreamPlayer2D.play)
	$Tile.texture = load("res://Assets/Tiles/tile_" + Stats.getStringFromEnumLowercase(type) + ".png")
	if placed:
		lightamount = GameState.gameState.lightThresholds.getLight(global_position.y) * stacks
		$Tile.modulate = Color(1 + lightamount, 1 + lightamount, 1 + lightamount)
	
	if placed: resetLight()
	$Drawpoint.base = base
	point.type = type

	pass ;



# Called every frame. 'delta' is the elapsed time since the previous frame.


#func draw_SniperLine():
	#if target != null: targetposition = target.global_position;
	#if buildup == 0: return ;
	#if targetposition == null: return ;
	#if buildup < 0: buildup = 0
	#
	#direction = (targetposition - self.global_position).normalized();
	##$Barrel.rotation=direction.angle() + PI / 2.0;
	#var color = Color(1, 1, 1, 1 * buildup)
	#var thickness = 1 * buildup;
	#for b in base.getBarrels():
		#var bgp = b.get_child(0).global_position;
		#var bp = b.get_child(0).position;
		#draw_line((b.position + bp).rotated(base.rotation), -(global_position - (targetposition) - (b.position - bp).rotated(base.rotation)), color, thickness, true)
		#draw_line((b.position + bp).rotated(base.rotation), -(global_position - (targetposition) - (b.position - bp).rotated(base.rotation)), color, thickness, true)
	#
	#pass ;
	#
@onready var point = $Drawpoint
#func draw_laser():
	#
	#if target != null:
		#targetposition = target.global_position;
	#if target == null&&buildup < 0:
		#buildup = 0;
		#point.buildup = buildup
		#point.queue_redraw();
		#return
	#point.type = extension
	#point.target = target
	#point.buildup = buildup
	#point.targetposition = targetposition
	#point.direction = direction
	#point.queue_redraw();
	#return
	#
func reduceCooldown(delta):

	var ml = lightamount;
	if not base.onCooldown:
		return ;
	var increase = (ml / base.cooldown) * delta
	$Tile.modulate = Color($Tile.modulate.r + increase, $Tile.modulate.r + increase, $Tile.modulate.r + increase)
	
	remap(255, 0, 0, 1, 254)

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

	pass ;

var waitingForMinions = false;


#
#func RED_do(delta):
	##check if blade should be rotating
	#if buildup > 0&&projectile != null:
			#projectile.rotate((180 * buildup * - 1) * 2 * delta);
	##if no target, slowly stop rotating the blade 	
	#if target == null&&buildup > 0:
		#buildup = buildup - 0.01 * delta;
	##if no target is present, stop the rest	
	#if target == null: return
	##if target present and buildup is lower than maxrotation, start rotating		
	#if buildup < 0.01:
		#buildup = buildup + 0.01 * delta;
	##if not on cooldown, deal damage	
	#if !onCooldown:
			#for cell in coveredCells:
				#for e in cell:
					#if !is_instance_valid(e): continue
					#if e.hit(type, self.damage * stacks): addKill()
					#addDamage(self.damage * stacks)
					#projectile.playHitSound();
			#startCooldown(cooldown * cooldownfactor)
						#
	#pass ;
#
#func BLUE_do(delta):
	#base_do()
	#pass ;
#func GREEN_do(delta):
	#base_do()
	#pass ;
#func YELLOW_do(delta):
	#if type == Stats.TurretColor.YELLOW&&extension == Stats.TurretExtension.DEFAULT:
		#buildup = buildup - 4 * delta;
	#if target != null:
		#if !onCooldown:
				#if camera != null:
					#var mod = camera.zoom.y - 3;
					#$AudioStreamPlayer2D.volume_db = 10 + mod * 10
					#
				##if !$AudioStreamPlayer2D.playing&&sounds<25:
				#$AudioStreamPlayer2D.play()
				#sounds = sounds + 1
				#projectile.hitEnemy(target)
				#buildup = 1;
				#queue_redraw()
				#startCooldown(cooldown * cooldownfactor)
				#onCooldown = true;
	#if buildup > 0 and target == null:
			#buildup = buildup - 2 * delta;
		#
	#queue_redraw()
		#
	#pass ;
#func REDLASER_do(delta):
	#
	#if !$AudioStreamPlayer2D.playing and buildup > 0:
		#$AudioStreamPlayer2D.play()
	#if buildup < 0.1:
		#$AudioStreamPlayer2D.stop()
		#
	#if target != null and buildup <= 1:
		#buildup = buildup + 1 * delta * 2;
	#if target == null and buildup > 0:
		#buildup = buildup - 2 * delta;
	#
	#queue_redraw()
	#base_do()
#func BLUEFREEZER_do(delta):
	#if target != null and buildup <= 1:
		#buildup = buildup + 1 * delta * 2;
	#if target == null and buildup > 0:
		#buildup = buildup - 2 * delta;
	#queue_redraw()
	#base_do()
	#pass ;
				#
	#pass ;
#func BLUELASER_do(delta):
	#base_do()
	#pass ;
#func GREENPOISON_do(delta):
	#base_do()
	#pass ;
#func YELLOWMORTAR_do(delta):
	#base_do()
	#pass ;
func do(delta):

	#größter pfusch auf erden. wenn ein block in der hand ist soll er seine range anzeigen, wenn nicht dann nicht.
	#der turm weiß nur nie ob er in der hand ist oder nicht -> card intercepten
	if !placed:
		if Card.contemplatingInterrupt: $Button.mouse_filter = 2
		else:
			$Button.mouse_filter = 0;
			
	if GameState.gameState == null or not placed: return
	base.do(delta)
	
	pass ;



func levelup(lvl: int=1):
	lightamount = lightamount / stacks
	stacks = lvl;
	lightamount = lightamount * stacks
	
	setUpTower()
	$LVL.text = str(stacks)
	base.setLevel(stacks)
	pass ;




func _on_button_mouse_entered():
	base.showRangeOutline()
	for t in cardBuddys:
		t.showRangeOutline()
	if placed:
		GameState.gameState.menu.showDescription("This turret defeated " + str(str(base.killcount) + " minions and dealt " + str(int(base.damagedealt)) + "damage."))
		
	elif extension != 1:
		GameState.gameState.menu.showDescription(Stats.getDescription(Stats.TurretExtension.keys()[extension - 1]))
	else:
		GameState.gameState.menu.showDescription(Stats.getDescription(Stats.getStringFromEnum(type)))
	
	GameState.gameState.showCount(base.killcount, base.damagedealt)
	
	pass # Replace with function body.
var detectorvisible = false;

var m = 0;



func _on_button_mouse_exited():
	GameState.gameState.menu.hideDescription()
	detectorvisible = false;
	GameState.gameState.hideCount()
	GameState.gameState.gameBoard.clear_range_outline()
	pass # Replace with function body.

func _on_button_pressed():
	resetLight()
	pass # Replace with function body.

func _on_visible_on_screen_notifier_2d_screen_exited():
	checkPosition(true)
	pass # Replace with function body.

func _on_visible_on_screen_notifier_2d_screen_entered():
	checkPosition(false)
	pass # Replace with function body.
