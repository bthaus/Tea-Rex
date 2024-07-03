extends GameObject2D
class_name Poison
var stacks = 0;
var decay;
var enemy;
var associate;

var effect;

func _ready():
	var parent = get_parent();
	if parent is Monster:
		enemy = parent;
	setupPropagation()
	process_mode=Node.PROCESS_MODE_ALWAYS
	effect = load("res://effects/poison_effect.tscn").instantiate()
	add_child(effect)
		
pass # Replace with function body.
func setupPropagation():
	get_tree().create_timer(3).timeout.connect(propagate)

	pass ;
static func create(stacks, associate, decay: int=Stats.poison_dropoff_rate):
	var poison = Poison.new()
	poison.stacks = stacks;
	poison.decay = decay
	poison.associate = associate
	return poison;
	
func propagate():
	if enemy==null || !is_instance_valid(enemy):return;
	for m in GameState.gameState.collisionReference.getMinionsAroundPosition(enemy.global_position):
		if !is_instance_valid(m):continue
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
var timer=0;
func _process(delta):
	timer=timer+delta;
	if timer>=1:
		timer=0
	else:
		return;
	effect.global_position = enemy.global_position
	#detector.global_position = enemy.global_position
	stacks = stacks - decay ;
	if stacks < 0 || enemy.hp<=0:
		queue_free()
		return;
	if enemy.hit(Stats.TurretColor.GREY, stacks , 0, false):
		if associate != null: associate.addKill()
		queue_free()
	if associate != null: associate.addDamage(stacks )
	pass
