extends Node2D

var colors=Stats.TurretColor.values()
# Called when the node enters the scene tree for the first time.
var healthstart=0;
func _ready():
	Engine.time_scale=100;
	Engine.physics_ticks_per_second=20*60
	var turret=Turret.create(colors[1],1);
	$TurretPoint.add_child(turret)
	
	
	var m=Monster.create(colors[1],$Target)
	$Spawnpoint.add_child(m)
	healthstart=m.hp
	
	
	
	
	pass # Replace with function body.
var enemy;
func spawn():
	

	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass


func _on_enemy_detector_enemy_entered(enemy):
	print("damage dealt: "+str(healthstart-enemy.hp))
	var m=Monster.create(colors[1],$Target)
	$Spawnpoint.add_child(m)
	healthstart=m.hp
	enemy.queue_free()
	
	pass # Replace with function body.
