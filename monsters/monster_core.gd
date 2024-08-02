extends GameObject2D
class_name MonsterCore
signal death_animation_done
@export var hp:float = 1;
@export var damage:float = 1;
@export var speed:float = 1;
@export var type:Monster.Monstertype



var died=false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func on_move():
	
	pass;
func on_death():
	$Animation.play("die")
	$Animation.animation_finished.connect(func():death_animation_done.emit())
	pass;
func on_spawn():
	$Animation.play("spawn")
	pass;
func on_cell_traversal():
	pass;
func on_hit():
	$Animation.play("hit")
	pass;
	
func do(delta):
	apply_status_effects(delta)
	pass;

func hit(color: Turret.Hue, damage, type="default", noise=true):
	if hp<=0: return false;
	on_hit()
	hp = hp - damage #* mod;
	if hp <= 0 and not died:
		died = true
		GameState.gameState.collisionReference.removeMonster(self)
		on_death()
		return true;
	return false;


