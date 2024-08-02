extends MonsterCore
@export var range:int
@export var collides=true
@export var projectile_speed=700
var bullets=[]
@onready var ball=$Snowball

func _ready():
	ball.pool=bullets
	ball.reparent(GameState.gameState.bulletHolder)
	ball.shot=false
	ball.speed=projectile_speed
	pass;
func do_special():
	#var turrets_in_range=GameState.gameState.collisionReference.get_cells_around_pos(global_position,range,collides)
	var turretornot=GameState.gameState.collisionReference.get_random_turret_in_range(global_position,range,collides)
	if turretornot==null:return
	$Animation.play("shoot")
	shoot(turretornot)
	#$Animation.animation_finished.connect(shoot.bind(turretornot))
	pass;
func shoot(turret):
	ball.global_position = global_position
	ball.shoot(turret);
	
	
	
