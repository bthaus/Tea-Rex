extends Node2D
class_name Monster;
@export var sizemult=1;
var hp=Stats.enemy_base_HP;
var damage=Stats.enemy_base_damage;
var speedfactor=Stats.enemy_base_speed;
var color:Stats.TurretColor=Stats.TurretColor.GREY


# Called when the node enters the scene tree for the first time.
func _ready():
	$Hitbox/Hitboxshape.apply_scale(Vector2(sizemult,sizemult));
	
	
	
	$HP.text=str(hp)
	pass # Replace with function body.
func create(type:Stats.TurretColor):
	var en=load("res://monster.tscn").instantiate() as Monster
	en.damage=Stats.getEnemyProperty(color,"damage")
	en.color=type;
	en.speedfactor=Stats.getEnemyProperty(color,"speed")
	en.hp=Stats.getEnemyProperty(color,"HP")
	
	pass;
func hit(color:Stats.TurretColor,damage,type="default"):
	var mod=1;
	if color==self.color:
		mod=1.5
	hp=hp-damage*mod;
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
