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
signal reached_spawn(monster:Monster)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Hitbox/Hitboxshape.apply_scale(Vector2(sizemult,sizemult));
	damage=Stats.getEnemyProperty(color,"damage")
	
	speedfactor=Stats.getEnemyProperty(color,"speed")
	var mod=1+(currentMinionPower*Stats.enemy_scaling)
	hp=Stats.getEnemyProperty(color,"HP")*mod
	minionExp=Stats.enemy_base_exp;
	GameState.gameState.player_died.connect(func():free())
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
static var xptext=load("res://Assets/UI/CARDMAX.png");
func hit(color:Stats.TurretColor,damage,type="default"):
	var mod=1;
	if color==self.color:
		mod=1.5
	hp=hp-damage*mod;
	hp=int(hp)
	$HP.text=str(hp)
	if hp<=0 and not died:
		#spawnEXP()
		died=true
		monster_died.emit(self)
		$Hitbox.queue_free()
		$Sprite2D.queue_free()
		$DeathAnim.visible=true;
		$AudioStreamPlayer.play()
		$DeathAnim.play(Stats.getStringFromEnum(self.color))
		return true;
	return false;
func spawnEXP():
	var sprite=Sprite2D.new();
	sprite.texture=xptext
	GameState.gameState.add_child(sprite);
	sprite.global_position=global_position
	var tween = get_tree().create_tween()
	print(GameState.gameState.menu.get_node("CanvasLayer/UI/ExpTarget").global_position)
	tween.set_loops(10)
	tween.tween_property(sprite,"global_position",(global_position+(GameState.gameState.get_node("Camera2D/EXPtarget").global_position-global_position))/10,0.3)
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if died: return;
	var direction = Vector3()
	nav.target_position = target.global_position  
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = velocity.lerp(direction * (speedfactor * speed),accel * delta)
	move_and_slide()


func _on_death_anim_animation_finished():
	queue_free()
	pass # Replace with function body.
