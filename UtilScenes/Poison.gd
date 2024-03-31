extends Node
class_name Poison
var stacks=0;
var enemy;
# Called when the node enters the scene tree for the first time.
func _ready():
	var parent=get_parent();
	if parent is Monster:
		enemy=parent;
	pass # Replace with function body.

static func create(stacks):
	var poison=Poison.new()
	poison.stacks=stacks;
	return poison;
	
func apply(amount):
	stacks=stacks+amount;
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	stacks=stacks-Stats.poison_dropoff_rate*delta;
	if stacks<0:
		queue_free()
	enemy.hit(Stats.TurretColor.GREY,stacks*delta)
	pass
