extends Node2D
class_name Monster;
@export var sizemult=1;
@export var hp=Stats.enemyHP;
var speedfactor=1;


# Called when the node enters the scene tree for the first time.
func _ready():
	$Hitbox/Hitboxshape.apply_scale(Vector2(sizemult,sizemult));
	hp=Stats.enemyHP;
	$HP.text=str(hp)
	pass # Replace with function body.

func hit(color:Stats.TurretColor,damage,type="default"):
	hp=hp-damage;
	$HP.text=str(hp)
	if hp<=0:
		queue_free()
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input.is_action_pressed("testright")):
		translate(Vector2(500*speedfactor*delta,0))
	if(Input.is_action_pressed("testleft")):
		translate(Vector2(-500*speedfactor*delta,0))
	if(Input.is_action_pressed("testdown")):
		translate(Vector2(0,500*speedfactor*delta))
	if(Input.is_action_pressed("testup")):
		translate(Vector2(0,-500*speedfactor*delta))
	pass
