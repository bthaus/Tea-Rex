extends CharacterBody2D
class_name Monster;
var sizemult=1;
var hp=Stats.enemy_base_HP;
var damage=Stats.enemy_base_damage;
var speedfactor=Stats.enemy_base_speed_factor;
var speed = Stats.enemy_base_speed;
var accel = Stats.enemy_base_acceleration;
var minionExp;
var currentMinionPower=1;
@export var color:Stats.TurretColor=Stats.TurretColor.BLUE
var died=false;
@export var target: Node2D #goal
@onready var nav: NavigationAgent2D = $NavigationAgent2D
signal monster_died(monster:Monster)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Hitbox/Hitboxshape.apply_scale(Vector2(sizemult,sizemult));
	damage=Stats.getEnemyProperty(color,"damage")
	
	speedfactor=Stats.getEnemyProperty(color,"speed")
	var mod=1+(currentMinionPower*Stats.enemy_scaling)
	hp=Stats.getEnemyProperty(color,"HP")*mod
	minionExp=Stats.enemy_base_exp;
	
	$Sprite2D.texture=load("res://Assets/Monsters/Monster_"+Stats.getStringFromEnum(color)+".png")

	#get_node(Stats.getStringFromEnum(color)).visible=false;
	
	$HP.text=str(hp)
	pass # Replace with function body.
static func create(type:Stats.TurretColor,target:Node2D,wave:int=1)->Monster:
	var en=load("res://monster.tscn").instantiate() as Monster
	if type==Stats.TurretColor.GREY:
		type=Stats.TurretColor.BLUE
	en.color=type;
	en.target=target;
	en.currentMinionPower=wave
	return en
	pass;
func getExp():
	return currentMinionPower*minionExp;
	pass;
func hit(color:Stats.TurretColor,damage,type="default"):
	var mod=1;
	if color==self.color:
		mod=1.5
	hp=hp-damage*mod;
	$HP.text=str(hp)
	if hp<=0 and not died:
		died=true
		monster_died.emit(self)
		queue_free()
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var direction = Vector3()
	nav.target_position = target.global_position  
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = velocity.lerp(direction * (speedfactor * speed),accel * delta)
	move_and_slide()
