extends BaseEntity
class_name BurningVolcanoEntity

@export var explosion_time_min:float=4
@export var explosion_time_max:float=12

@export var fire_damage:float=10
@export var fire_duration:float=4
#lifetime,associate,str,tick_damage
var debuff:FireDebuff=FireDebuff.new(GameplayConstants.DEBUFF_STANDART_LIFETIME,self,1,fire_damage)
var explosion_timer=0
var running=false

func on_battle_phase_started():
	running=true
	set_timer()
	pass;
func set_timer():
	explosion_timer=randf_range(explosion_time_min,explosion_time_max)
	stop=true
	pass;	
func on_build_phase_started():
	running=false
	pass;	
func do(delta):
	if not running:return
	explosion_timer-=delta
	if explosion_timer<0:
		trigger_volcano()
		set_timer()
		get_tree().create_timer(fire_duration).timeout.connect(stop_fire)
		
	pass;
var stop=false;
func stop_fire():
	if not stop:return
	$cell_fire.emitting=false;
	for fire in fires:
		fire.remove()
		fire.queue_free()
	fires.clear()	
	pass;
var fires=[]	
func trigger_volcano():
	stop=false;
	$cell_fire.emitting=true
	var arr=[]
	for fire in fires:
		fire.remove()
		fire.queue_free()
	fires.clear()	
	GameState.collisionReference.getNeighbours(get_global(),arr)
	for h in arr:
		var fire = CellFireEntity.new(debuff,h,fire_duration)
		fire.place_on_board()
		
	pass;
func on_target_killed(m):
	pass
