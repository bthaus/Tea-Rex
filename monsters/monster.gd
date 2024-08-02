extends GameObject2D
class_name Monster;
enum MonsterMovingType { GROUND, AIR, }
var moving_type: MonsterMovingType
enum Monstertype {REGULAR=0,BOSS=1}
var sizemult = 1;
var maxHp;
var monstertype:Monstertype

var damage:
	get:return core.damage
	set(val):core.damage=val
var speed:
	get:return core.speed
	set(val):core.speed=clamp(val,0,10000)
var hp:
	get:return core.hp
	set(val):core.hp=val
var default_speed
var minionExp;
var currentMinionPower = 1;
var path=[]
@export var color: Turret.Hue = Turret.Hue.BLUE
var died = false;
var oldpos=Vector2(0,0)
var core:MonsterCore:
	set(value):
		core=value
		add_child(value)
@export var target: Node2D # goal

signal monster_died(monster: Monster)
signal reached_spawn(monster: Monster)
var maxGlow = 5;
# Called when the node enters the scene tree for the first time.
func _ready():
	default_speed=speed
	core.death_animation_done.connect(queue_free)
	core.on_spawn()
	maxHp = core.hp
	$Health.max_value = maxHp
	$Health.value = core.hp
	GameState.gameState.player_died.connect(func(): free())
	pass # Replace with function body.
static func create(type, target: Node2D, wave: int=1) -> Monster:
	var en = load("res://monsters/monster.tscn").instantiate() as Monster
	en.core=MonsterFactory.createMonster(type)
	en.target = target;
	en.currentMinionPower = wave
	en.monstertype=en.core.type
	
	return en

func hit(color: Turret.Hue, damage, type="default", noise=true):
	$Health.value = core.hp;
	if noise: $hurt.play()
	if core.hit(color,damage,type,noise):
		$VisibleOnScreenNotifier2D.queue_free()
		$AudioStreamPlayer.play()
		return true;
	return false;


# Called every frame. 'delta' is the elapsed time since the previous frame.


var distance_travelled=0;
var distance_to_next_edge=-1;
var travel_index=0;
var ignore_next_portal=false;
func trigger_teleport():
	if not _is_next_step_portal(): return
	distance_travelled=distance_to_next_edge
	global_position=path[travel_index+1]
	translateTowardEdge(0.16)
	pass;
func _is_next_step_portal():
	var current=path[travel_index]
	var next=path[travel_index+1]
	return abs(current.x-next.x)>GameboardConstants.TILE_SIZE+4 or abs(current.y-next.y)>GameboardConstants.TILE_SIZE+4
		
var direction
func do(delta):
	translateTowardEdge(delta)
	core.do(delta)
	pass;	

func translateTowardEdge(delta):
	
	if core.hp<=0:return;
	
	if distance_to_next_edge<=distance_travelled:
		travel_index=travel_index+1;
		distance_travelled=0;
		if travel_index>path.size()-1:return;
		distance_to_next_edge=global_position.distance_to(path[travel_index])
		
	if travel_index>path.size()-1:return;
	direction=(path[travel_index]-global_position).normalized()
	var distance=core.speed*delta
	distance_travelled=distance_travelled+distance
	translate(direction*distance)
	pass;
func cell_traversed():
	core.on_cell_traversal()
	pass;
func _on_visible_on_screen_notifier_2d_screen_exited():
	core.visible=false;
	pass # Replace with function body.

func _on_visible_on_screen_notifier_2d_screen_entered():
	core.visible=true;
	pass # Replace with function body.
