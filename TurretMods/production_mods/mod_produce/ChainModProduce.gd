extends ModProduce
@export var base_lifetime=2


# Called when the node enters the scene tree for the first time.
func trigger_minion(monster:Monster):
	var debuff=TiedDebuff.new(base_lifetime*associate.associate.level)
	debuff.register(monster)
	super(monster)
	pass;
