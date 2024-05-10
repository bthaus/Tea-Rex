extends Node2D
class_name Explosion
static var cache=[]

# Called when the node enters the scene tree for the first time.
func _ready():
	if noise:
		sound=AudioStreamPlayer2D.new()
		add_child(sound)
		sound.stream=Sounds.explosionSounds.pick_random().duplicate()
		#temp.sound.stream=load("res://Sounds/Soundeffects/FIREBALL_sound.wav")
		sound.play(0.10)
	pass # Replace with function body.
var damage;
var type
var associate;
var sound;
var cam
var noise;
static func create(type,damage, position, root,scale=1,noise=true):
	var temp;

	if cache.size()==0:
		temp=load("res://TurretScripts/Projectiles/Explosion.tscn").instantiate() as Explosion;
		temp.type=type;
		temp.scale=Vector2(scale,scale)
		#temp.apply_scale(Vector2(scale,scale));
		temp.damage=damage;
		GameState.gameState.call_deferred("add_child",temp);
		temp.visible=true;
		
	else:
		temp=cache.pop_back();
		root.add_child(temp);
		temp.scale=Vector2(scale,scale)
		temp.visible=true;
		
	temp.get_node("Area2D").monitoring=true;
	temp.get_node("AnimatedSprite2D").visible=true	
	temp.global_position=position;
	temp.get_node("AnimatedSprite2D").play("default")
	temp.get_node("AnimationPlayer").play("lightup")
	temp.associate=root;
	temp.noise=noise
	#GameState.gameState.getCamera().shake(0.3,0.1,position,1)
	
	temp.cam=GameState.gameState.getCamera()
	
	
	
	
	
	
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if  cam!=null and  sound!=null:
		var mod=cam.zoom.y-3;
		sound.volume_db=20+mod*15

	pass

var num=0;
func _on_area_2d_area_entered(area):
	if(area.get_parent() is Monster):
		
		num=num+1;
		if area.get_parent().hit(type,damage) &&associate!=null:
			associate.addKill()
		if associate!=null && associate.has_method("addDamage"):
			associate.addDamage(damage)
		
	
	pass # Replace with function body.

func _on_animated_sprite_2d_animation_finished():
	$AnimatedSprite2D.visible=false;
	$Area2D.monitoring=false;
	pass # Replace with function body.


func _on_sound_finished():
	get_parent().remove_child(self)
	cache.push_back(self)

	pass # Replace with function body.
