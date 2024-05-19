extends Node
class_name Poison
var stacks = 0;
var decay;
var enemy;
var associate;
var detector: EnemyDetector;
var effect;
static var detectorscene = load("res://enemy_detector.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent();
	if parent is Monster:
		enemy = parent;
	#setupPropagation()
	#effect = load("res://poison_effect.tscn").instantiate()
	#add_child(effect)
		
pass # Replace with function body.
func setupPropagation():
	get_tree().create_timer(3).timeout.connect(propagate)
	detector = detectorscene.instantiate()
	add_child(detector)
	detector.visible = false
	detector.apply_scale(Vector2(Stats.poison_propagation_range, Stats.poison_propagation_range));
	
	pass ;
static func create(stacks, associate, decay: int=Stats.poison_dropoff_rate):
	var poison = Poison.new()
	poison.stacks = stacks;
	poison.decay = decay
	poison.associate = associate
	return poison;
	
func propagate():
	for m in detector.enemiesInRange:
		var temp = false;
		for a in m.get_children():
			if a is Poison&&a.decay == decay:
				temp = true;
				if a.stacks < stacks:
					a.stacks = stacks
		if !temp:
			m.add_child(Poison.create(stacks, associate, decay));
		
	get_tree().create_timer(3).timeout.connect(propagate)
	pass ;
func apply(amount):
	stacks = stacks + amount;
	pass ;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#effect.global_position = enemy.global_position
	#detector.global_position = enemy.global_position
	stacks = stacks - decay * delta;
	if stacks < 0:
		queue_free()
	if enemy.hit(Stats.TurretColor.GREY, stacks * delta, 0, false):
		if associate != null: associate.addKill()
		queue_free()
	if associate != null: associate.addDamage(stacks * delta)
	pass
