extends Node2D
class_name Explosion
static var cache=[]
# Called when the node enters the scene tree for the first time.
func _ready():
	$PointLight2D.visible=true;
	$PointLight2D2.visible=true
	pass # Replace with function body.
var damage;
var type
static var sounds=0;
static func create(type,damage, position, root,scale=1):
	var temp;
	if cache.size()==0:
		temp=load("res://TurretScripts/Projectiles/Explosion.tscn").instantiate() as Explosion;
		temp.type=type;
		temp.scale=Vector2(scale,scale)
		#temp.apply_scale(Vector2(scale,scale));
		temp.damage=damage;
		root.add_child(temp);
		temp.visible=true;
		
	else:
		temp=cache.pop_back();
		root.add_child(temp);
		temp.scale=Vector2(scale,scale)
		temp.visible=true;
		
	temp.global_position=position;
	temp.get_node("AnimatedSprite2D").play("default")
	temp.get_node("AnimationPlayer").play("lightup")
	if sounds<25:
		temp.get_node("sound").play();
		sounds=sounds+1;
	
	
	
	
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if $sound.playing:
		var mod=getCam().zoom.y-3;
		$sound.volume_db=mod*10
	pass

var num=0;
func _on_area_2d_area_entered(area):
	if(area.get_parent() is Monster):
		
		num=num+1;
		area.get_parent().hit(type,damage);
	
	
	pass # Replace with function body.

static var cam;
func getCam():
	if cam == null:
		cam=get_tree().get_root().get_node("MainScene").getCamera()
	return cam;
	pass;
func _on_animated_sprite_2d_animation_finished():
	get_parent().remove_child(self)
	cache.push_back(self)
	pass # Replace with function body.


func _on_sound_finished():
	
	sounds=sounds-1
	pass # Replace with function body.
