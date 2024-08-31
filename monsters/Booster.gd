extends MonsterCore
@export var speed_buff:float=100
var refresh_rate
func _ready():
	refresh_rate=special_cooldown*1.2
	super()
func do_special():
	var ms=GameState.collisionReference.getMinionsAroundPosition(global_position)
	ms.erase(holder)
	for m in ms:
		if !util.valid(m):continue
		var boost=SpeedBuff.new(speed_buff,refresh_rate)
		boost.register(m)
	pass;
