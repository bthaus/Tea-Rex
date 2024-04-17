extends CharacterBody2D
class_name Monster;
@export var sizemult=1;
var hp=Stats.enemy_base_HP;
var damage=Stats.enemy_base_damage;
var speedfactor=Stats.enemy_base_speed_factor;
var speed = Stats.enemy_base_speed;
var accel = Stats.enemy_base_acceleration;
@export var color:Stats.TurretColor=Stats.TurretColor.BLUE
var died=false;
@export var target: Node2D #goal
@onready var nav: NavigationAgent2D = $NavigationAgent2D
signal monster_died

# Called when the node enters the scene tree for the first time.
func _ready():
	$Hitbox/Hitboxshape.apply_scale(Vector2(sizemult,sizemult));
	damage=Stats.getEnemyProperty(color,"damage")
	
	speedfactor=Stats.getEnemyProperty(color,"speed")
	hp=Stats.getEnemyProperty(color,"HP")
	if color==Stats.TurretColor.GREEN:
		$Sprite2D.self_modulate=Color(0,1,0,1);
	if color==Stats.TurretColor.RED:
		$Sprite2D.self_modulate=Color(1,0,0,1);
	if color==Stats.TurretColor.YELLOW:
		$Sprite2D.self_modulate=self_modulate

	get_node(Stats.getStringFromEnum(color)).visible=false;
	
	$HP.text=str(hp)
	pass # Replace with function body.
static func create(type:Stats.TurretColor,target:Node2D)->Monster:
	var en=load("res://monster.tscn").instantiate() as Monster
	en.color=type;
	en.target=target;
	
	return en
	pass;
func hit(color:Stats.TurretColor,damage,type="default"):
	var mod=1;
	if color==self.color:
		mod=1.5
	hp=hp-damage*mod;
	$HP.text=str(hp)
	if hp<=0 and not died:
		died=true
		monster_died.emit()
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
