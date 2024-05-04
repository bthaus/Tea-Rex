extends Node
class_name Poison
var stacks=0;
var decay;
var enemy;

var detector:EnemyDetector;
# Called when the node enters the scene tree for the first time.
func _ready():
	var parent=get_parent();
	if parent is Monster:
		enemy=parent;
	get_tree().create_timer(3).timeout.connect(propagate)
	detector=load("res://enemy_detector.tscn").instantiate()
	add_child(detector)
	detector.visible=false
	detector.apply_scale(Vector2(Stats.poison_propagation_range,Stats.poison_propagation_range));
	pass # Replace with function body.

static func create(stacks,decay:int=Stats.poison_dropoff_rate):
	var poison=Poison.new()
	poison.stacks=stacks;
	poison.decay=decay
	return poison;
	
func propagate():
	for m in detector.enemiesInRange:
		var temp=false;
		for a in m.get_children():
			if a is Poison&&a.decay==decay:
				temp=true;
				if a.stacks<stacks:
					a.stacks=stacks
		if !temp:
			m.add_child(Poison.create(stacks,decay));
		
	get_tree().create_timer(3).timeout.connect(propagate)
	pass;	
func apply(amount):
	stacks=stacks+amount;
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	detector.global_position=enemy.global_position
	stacks=stacks-decay*delta;
	if stacks<0:
		queue_free()
	enemy.hit(Stats.TurretColor.GREY,stacks*delta)
	pass
