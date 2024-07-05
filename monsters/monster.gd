extends GameObject2D
class_name Monster;
enum MonsterMovingType { GROUND, AIR }
var moving_type: MonsterMovingType

var sizemult = 1;
var hp = Stats.enemy_base_HP;
var maxHp;
var damage = Stats.enemy_base_damage;
var speedfactor = Stats.enemy_base_speed_factor;
var speed = Stats.enemy_base_speed;
var accel = Stats.enemy_base_acceleration;

var minionExp;
var currentMinionPower = 1;
var path=[]
@export var color: Stats.TurretColor = Stats.TurretColor.BLUE
var died = false;
var oldpos=Vector2(0,0)
var appearance:MonsterCore:
	set(value):
		appearance=value
		add_child(value)
@export var target: Node2D # goal

signal monster_died(monster: Monster)
signal reached_spawn(monster: Monster)
var maxGlow = 5;
# Called when the node enters the scene tree for the first time.
func _ready():
	appearance.death_animation_done.connect(queue_free)
	appearance.on_spawn()
	
	damage = Stats.getEnemyProperty(color, "damage")
	speedfactor = Stats.getEnemyProperty(color, "speed")
	var mod = 1 + (currentMinionPower * Stats.enemy_scaling)
	hp = Stats.getEnemyProperty(color, "HP") * mod
	maxHp = hp
	$Health.max_value = maxHp
	$Health.value = hp
	GameState.gameState.player_died.connect(func(): free())
	pass # Replace with function body.
static func create(type, target: Node2D, wave: int=1) -> Monster:
	var en = load("res://monsters/monster.tscn").instantiate() as Monster
	en.appearance=MonsterFactory.createMonster(type)
	en.target = target;
	en.currentMinionPower = wave
	
	return en
	


func hit(color: Stats.TurretColor, damage, type="default", noise=true):
	if hp<=0: return;
	appearance.on_hit()
	var mod = 1;
	if color == self.color:
		mod = 1.5
	hp = hp - damage #* mod;
	$Health.value = hp;
	hp = int(hp)
	if noise: $hurt.play()
	print(hp)	
	if hp <= 0 and not died:
		died = true
		GameState.gameState.collisionReference.removeMonster(self)
		monster_died.emit(self)
		appearance.on_death()
		$VisibleOnScreenNotifier2D.queue_free()
		$AudioStreamPlayer.play()
		
		return true;
	return false;


# Called every frame. 'delta' is the elapsed time since the previous frame.

var tw
var distance_travelled=0;
var distance_to_next_edge=-1;
var travel_index=0;
func translateTowardEdge(delta):
	
	if hp<=0:return;
	if distance_to_next_edge<=distance_travelled:
		travel_index=travel_index+1;
		distance_travelled=0;
		if travel_index>path.size()-1:return;
		distance_to_next_edge=global_position.distance_to(path[travel_index])
		
	if travel_index>path.size()-1:return;
	var direction=(path[travel_index]-global_position).normalized()
	var distance=Stats.enemy_base_speed*delta*speedfactor
	distance_travelled=distance_travelled+distance
	translate(direction*distance)
	pass;
func cell_traversed():
	appearance.on_cell_traversal()
	pass;
func _on_visible_on_screen_notifier_2d_screen_exited():
	appearance.visible=false;
	pass # Replace with function body.

func _on_visible_on_screen_notifier_2d_screen_entered():
	appearance.visible=true;
	pass # Replace with function body.
