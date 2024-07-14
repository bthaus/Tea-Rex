extends GameObject2D
class_name Turret

@export var range = 1;
@export var isBasic = true;
@export var color: Turret.Hue;
@export var level: int = 1;
@export var extension: Turret.Extension;
enum Hue {WHITE=1, GREEN=2, RED=3, YELLOW=4, BLUE=5, MAGENTA=6};
enum Extension {DEFAULT=1,REDLASER=2, BLUELASER=3, YELLOWMORTAR=4, GREENPOISON=5,BLUEFREEZER=6};


var rowcounterstart = 0;
var rowcounterend = 0
var lightamount=1
static var camera;

static var coreFactory: TurretCoreFactory
var base: TurretCore;
var placed = true;
static var turrets = []
var cardBuddys = []


var on_built: Array[Callable] = [setUpTower]
var on_build_phase_started: Array[Callable] = []
var on_battle_phase_started: Array[Callable] = []

static func create(color: Turret.Hue, lvl: int, type: Turret.Extension=Turret.Extension.DEFAULT,placed=false) -> Turret:
	var turret = load("res://TurretScripts/turretbase.tscn").instantiate() as Turret;
	if turret.collisionReference == null:
		turret.collisionReference = GameState.gameState.collisionReference
	turret.color = color;
	turret.level = lvl;
	turret.extension = type;
	turret.placed=placed
	return turret;
	
var id;
static var counter = 0;
static var collisionReference: CollisionReference;
var waitingDelayed = false;
static var inhandTurrets = []

func _on_destroy():
	if not is_instance_valid(self):return;
	if is_instance_valid(base.projectile):base.projectile.queue_free()
	if is_instance_valid(GameState.gameState.gameBoard): 
		GameState.gameState.gameBoard.clear_range_outline()
		if placed:collisionReference.unregister_turret(self)
	pass;
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
	#$Button.visible = !off;
	$VisibleOnScreenNotifier2D.visible = true;
	pass ;
	
func _notification(what):
	if (what == NOTIFICATION_PREDELETE):
		_on_destroy()
		
		
var mapPosition;



func setUpTower():

	on_battle_phase_started.append(resetLight)


	base = coreFactory.getBase(color, extension);
	base.placed=placed
	base.setLevel(level)
	if placed:
		collisionReference.register_turret(self)
	add_child(base)
	base.setUpTower(self)
	$LVL.text = str(level)
	$AudioStreamPlayer2D.stream = load("res://Sounds/Soundeffects/" + util.getStringFromEnum(color) + util.getStringFromEnumExtension(extension) + "_shot.wav")
	if placed:
		lightamount = GameState.gameState.lightThresholds.getLight(global_position.y)*level
	
	$Tile.texture = load("res://Assets/Tiles/tile_" + util.getStringFromEnumLowercase(color) + ".png")
	if placed:
		lightamount = GameState.gameState.lightThresholds.getLight(global_position.y) * level
		$Tile.modulate = Color(1 + lightamount, 1 + lightamount, 1 + lightamount)
	
	if placed: resetLight()
	$Drawpoint.base = base
	point.type = color

	pass ;



# Called every frame. 'delta' is the elapsed time since the previous frame.

@onready var point = $Drawpoint

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
	if GameState.gameState.phase == GameState.GamePhase.BATTLE: return
	globlight = true;
	melight = true;
	#create_tween().tween_property(light, "energy", 3, 1)
	#if light.energy>=3:return
	
	#light.energy=light.energy+9*delta;
	pass
	
func de_highlight(delta):
	if GameState.gameState.phase == GameState.GamePhase.BATTLE: return
	globlight = false;
	melight = false;
	pass
	
func checkLight(delta):
	if GameState.gameState.phase == GameState.GamePhase.BATTLE: return
	
	if !placed:
		lightamount = GameState.gameState.lightThresholds.getLight(global_position.y)

	pass ;

var waitingForMinions = false;



func do(delta):

	#größter pfusch auf erden. wenn ein block in der hand ist soll er seine range anzeigen, wenn nicht dann nicht.
	#der turm weiß nur nie ob er in der hand ist oder nicht -> card intercepten
	#if !placed:
		#if Card.contemplatingInterrupt: $Button.mouse_filter = 2
		#else:
			#$Button.mouse_filter = 0;
			
	if GameState.gameState == null or not placed: return
	base.do(delta)
	
	pass ;



func levelup(lvl: int=1):
	lightamount = lightamount / level
	level = lvl;
	lightamount = lightamount * level
	
	setUpTower()
	$LVL.text = str(level)
	base.setLevel(level)
	pass ;



var infobox
var show_box=false;
func show_infobox():
	if not show_box:return;
	infobox=InfoBox.create(["Im a turret","damage dealt: "+str(int(base.damagedealt)),
		"kills: "+ str(int(base.killcount)),
		"damage: "+str(base.damage),
		"cooldown:"+str(base.cooldown)])
	if infobox!=null:$LVL.add_child(infobox)
	pass;
func on_hover():

	base.showRangeOutline()
	for t in cardBuddys:
		t.showRangeOutline()
	if placed:
		show_box=true;
		show_infobox()
		
		
	#elif extension != 1:
	#	GameState.gameState.ui.showDescription(Stats.getDescription(Turret.Extension.keys()[extension - 1]))
	#else:
	#	GameState.gameState.ui.showDescription(Stats.getDescription(util.getStringFromEnum(color)))
	
	GameState.gameState.showCount(base.killcount, base.damagedealt)
	
	pass # Replace with function body.
var detectorvisible = false;

var m = 0;

func on_moved():
	collisionReference.unregister_turret(self)
	pass;

func on_unhover():
	show_box=false;
	GameState.gameState.ui.hideDescription()
	detectorvisible = false;
	GameState.gameState.hideCount()
	GameState.gameState.gameBoard.clear_range_outline()
	if infobox!=null:
		infobox.delayed_delete()
	pass # Replace with function body.


func _on_visible_on_screen_notifier_2d_screen_exited():
	checkPosition(true)
	pass # Replace with function body.

func _on_visible_on_screen_notifier_2d_screen_entered():
	checkPosition(false)
	pass # Replace with function body.
