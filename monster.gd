extends Node2D
class_name Monster;
var sizemult = 1;
var hp = Stats.enemy_base_HP;
var maxHp;
var damage = Stats.enemy_base_damage;
var speedfactor = Stats.enemy_base_speed_factor;
var speed = Stats.enemy_base_speed;
var accel = Stats.enemy_base_acceleration;
var minionExp;
var currentMinionPower = 1;
@export var color: Stats.TurretColor = Stats.TurretColor.BLUE
var died = false;
enum TurretColor {GREY = 1, GREEN = 2, RED = 3, YELLOW = 4, BLUE = 5};

static var healthbar = [load("res://Assets/Monsters/minion_healthbar/minionhealthbar_green.png"),
	load("res://Assets/Monsters/minion_healthbar/minionhealthbar_white.png"),
	load("res://Assets/Monsters/minion_healthbar/minionhealthbar_green.png"),
		load("res://Assets/Monsters/minion_healthbar/minionhealthbar_red.png"),
			load("res://Assets/Monsters/minion_healthbar/minionhealthbar_yellow.png"),
				load("res://Assets/Monsters/minion_healthbar/minionhealthbar_blue.png")
]
var camera;
@export var target: Node2D # goal
@onready var nav: NavigationAgent2D = $NavigationAgent2D
signal monster_died(monster: Monster)
signal reached_spawn(monster: Monster)
var maxGlow = 5;
# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Hitbox/Hitboxshape.apply_scale(Vector2(sizemult, sizemult));
	damage = Stats.getEnemyProperty(color, "damage")
	camera = GameState.gameState.getCamera()
	speedfactor = Stats.getEnemyProperty(color, "speed")
	var mod = 1 + (currentMinionPower * Stats.enemy_scaling)
	hp = Stats.getEnemyProperty(color, "HP") * mod
	maxHp = hp
	
	$Health.texture_progress = healthbar[color]
	$Health.max_value = maxHp
	$Health.value = hp
	minionExp = Stats.enemy_base_exp;
	GameState.gameState.player_died.connect(func(): free())
	$Sprite2D.texture = load("res://Assets/Monsters/Monster_" + Stats.getStringFromEnum(color) + ".png")
	maxGlow = GameState.gameState.lightThresholds.getGlow(global_position.y) * 2.5
	maxGlow = clamp(maxGlow, 1, 5)
	modulate = Color(maxGlow, maxGlow, maxGlow, maxGlow)
	#get_node(Stats.getStringFromEnum(color)).visible=false;
	move()
	$HP.text = str(hp)
	pass # Replace with function body.
static func create(type: Stats.TurretColor, target: Node2D, wave: int=1) -> Monster:
	var en = load("res://monster.tscn").instantiate() as Monster
	if type == Stats.TurretColor.GREY:
		type = Stats.TurretColor.BLUE
	en.color = type;
	en.target = target;
	en.currentMinionPower = wave
	return en
	pass ;
func getExp():
	return currentMinionPower * minionExp / 3;
	pass ;
static var xptext = load("res://Assets/UI/CARDMAX.png");

func hit(color: Stats.TurretColor, damage, type="default", noise=true):
	
	var mod = 1;
	if color == self.color:
		mod = 1.5
	hp = hp - damage * mod;
	$Health.value = hp;
	hp = int(hp)
	$HP.text = str(hp)
	if !camera.isOffCamera(global_position):
		var t = remap(hp, 0, maxHp, 1, maxGlow)
		t = clamp(t, 1, maxGlow)
		modulate = Color(t, t, t)
	if camera != null:
		var s = camera.zoom.y - 3;
		$hurt.volume_db = s * 10
		$AudioStreamPlayer.volume_db = 10 * s
	if noise: $hurt.play()
		
	if hp <= 0 and not died:
		#spawnEXP()
		died = true
		tw.kill()
		monster_died.emit(self)
		$Hitbox.queue_free()
		$Sprite2D.queue_free()
		$VisibleOnScreenNotifier2D.queue_free()
		$DeathAnim.visible = true;
		$AudioStreamPlayer.play()
		$DeathAnim.play(Stats.getStringFromEnum(self.color))
		return true;
	return false;
func spawnEXP():
	var sprite = Sprite2D.new();
	sprite.texture = xptext
	GameState.gameState.add_child(sprite);
	sprite.global_position = global_position
	var tween = get_tree().create_tween()
	
	tween.finished.connect(func(idx):
		var a=get_tree().create_tween()
		a.tween_property(sprite, "global_position", global_position + ((GameState.gameState.get_node("Camera2D/EXPtarget").global_position - global_position) / (10 - idx + 1)), 0.3)
		)
	tween.tween_property(sprite, "global_position", global_position + ((GameState.gameState.get_node("Camera2D/EXPtarget").global_position - global_position) / 10), 0.3)
	
	#tweener(10,sprite)
	pass ;
	
func tweener(iteration, sprite):
	
	if iteration == 0:
		sprite.queue_free()
		return
	var tween = get_tree().create_tween()
	tween.finished.connect(tweener.bind(iteration - 1, sprite))
	tween.tween_property(sprite, "global_position", global_position + ((GameState.gameState.get_node("Camera2D/EXPtarget").global_position - global_position) / iteration), 0.3)
	
	pass ;
# Called every frame. 'delta' is the elapsed time since the previous frame.

var tw
func move():
	var direction = Vector3()
	nav.target_position = target.global_position
	var goal = nav.get_next_path_position()
	tw = create_tween()
	var length = (global_position - goal).length()
	length = remap(length, 0, 600, 0, 7 * 10 / (speedfactor * 2))
	tw.tween_property(self, "global_position", goal, length)
	tw.finished.connect(move)

	pass ;
func resetTween():
	if tw.is_running():
		tw.kill()
	move()
	pass ;
func moveAndSlide():
	#move_and_slide()
	
	pass ;
	
func _on_death_anim_animation_finished():
	queue_free()
	pass # Replace with function body.

func _on_visible_on_screen_notifier_2d_screen_exited():
	$Sprite2D.visible = false;
	pass # Replace with function body.

func _on_visible_on_screen_notifier_2d_screen_entered():
	$Sprite2D.visible = true;
	pass # Replace with function body.
