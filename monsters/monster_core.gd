extends AnimatedSprite2D
class_name MonsterCore
signal death_animation_done
@export var hp:float = 1;
@export var damage:float = 1;
@export var speed:float = 1;
@export var type:Monster.Monstertype

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func on_move():
	
	pass;
func on_death():
	play("die")
	animation_finished.connect(func():death_animation_done.emit())
	pass;
func on_spawn():
	play("spawn")
	pass;
func on_cell_traversal():
	pass;
func on_hit():
	play("hit")
	pass;



