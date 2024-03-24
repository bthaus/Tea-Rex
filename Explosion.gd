extends Node2D
class_name Explosion

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
var damage;
var type
static func create(type,damage, position, root,scale=1):
	var temp=load("res://TurretScripts/Projectiles/Explosion.tscn").instantiate() as Explosion;
	temp.type=type;
	temp.apply_scale(Vector2(scale,scale));
	temp.damage=damage;
	root.add_child(temp);
	temp.global_position=position;
	temp.get_node("AnimatedSprite2D").play("default");
	
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_area_entered(area):
	if(area.get_parent().name!="Monster"):
		return;
	area.get_parent().hit(type,damage);
	
	pass # Replace with function body.


func _on_animated_sprite_2d_animation_finished():
	queue_free()
	pass # Replace with function body.
