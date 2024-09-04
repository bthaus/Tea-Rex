extends Node2D
class_name Simulation

@export var turret_position=Vector2(11,4)
@export var map_name:String="sim_debug"
@export var auto_start=true
var gameState:GameState

var mods=[]
#enum Hue {WHITE=1, GREEN=2, RED=3, YELLOW=4, BLUE=5, MAGENTA=6};

var color_index=6
var mod_set_index=0
@export var sim_speed=1
var results=""

static var instance
var test_start=0
# Called when the node enters the scene tree for the first time.
func _ready():
	instance=self
	gameState=load("res://Game/simulation_scene.tscn").instantiate()
	var map=MapDTO.new()
	map.restore(map_name)
	gameState.map_dto=map
	add_child(gameState)
	
	for s in gameState.spawners:
		s._is_simulation=true
	gameState.game_speed
	gameState.start_build_phase.connect(_next_test)
	if auto_start:
		spawn_monster()
		_setup_mods()
		_next_test()
	pass # Replace with function body.
func _setup_mods():
	GameplayConstants.register_mods_for_sim()
	for i in TurretBaseMod.implemented_mods.size():
		for mod in TurretBaseMod.implemented_mods.values()[i]:
			for j in TurretBaseMod.implemented_mods.size():
				if i!=j:
					for other_mod in TurretBaseMod.implemented_mods.values()[j]:
						mods.append([mod,other_mod])
				
	pass;
func _next_test():
	
	running=true
	remove_current_turret()
		#get_tree().create_timer(5).timeout.connect(_test_turret.bind(color_index,mods[mod_set_index]))
		#return
	if mod_set_index>=mods.size():
		mod_set_index=0
		color_index=color_index+1
	if color_index>Turret.Hue.size():
		_finish_simulation()
		return		
		
	_test_turret(color_index,mods[mod_set_index])
	mod_set_index=mod_set_index+1
	pass;
func remove_current_turret():
	if current_turret!=null:
		current_turret.queue_free()
		var res=current_turret.get_info()+"\n"
		print(res)
		results=results+res+"\n"
	average_dps=0
	dps_sum=0
	frame_count=0	
	pass;	
func _finish_simulation():
	var time=Time.get_datetime_string_from_system()
	time=time.replace(":","_")
	time=time.replace("-","_")
	GameSaver.save(results,"t_"+time,"","tests")
	get_tree().quit()
	pass;
static func wave_done():
	
	instance._next_test()
	pass;	
var current_turret:Turret=null
func _test_turret(color:Turret.Hue, mod_names):
	remove_current_turret()
	
	test_start=Time.get_ticks_msec()
	
	var mods=[]
	for mod in mod_names:
		mods.append(mod.new())
	var turret=Turret.create(color,1,Turret.Extension.DEFAULT,true,mods)
	turret.global_position=gameState.board.map_to_local(turret_position)
	add_child(turret)
	turret.base.turret_mods=mods
	for mod in mods:
		mod.initialise(turret.base)
	current_turret=turret
	GameState.game_speed=sim_speed
	Engine.time_scale=sim_speed
	gameState.wave=0
	gameState.HP=10000
	pass;
var running=false
# Called every frame. 'delta' is the elapsed time since the previous frame.
var dps_sum=0
var frame_count=0
var average_dps=0
func _process(delta):
	if Input.is_action_just_pressed("save"):
		_next_test()
	if current_turret==null:return
	var current_time=Time.get_ticks_msec()
	var elapsed_test_time=current_time-test_start
	
	elapsed_test_time/=1000
	if elapsed_test_time<1:return
	var damage_dealt=current_turret.base.damagedealt
	var dps=damage_dealt/elapsed_test_time
	frame_count+=1
	dps_sum+=dps
	average_dps=dps_sum/frame_count
	
	pass
func spawn_monster():
	var mo=Monster.create(Monster.MonsterName.MINION)
	mo.monster_died.connect(spawn_monster)
	mo.reached_spawn.connect(spawn_monster)
	gameState.spawners[0].spawnEnemy(mo)
	pass
